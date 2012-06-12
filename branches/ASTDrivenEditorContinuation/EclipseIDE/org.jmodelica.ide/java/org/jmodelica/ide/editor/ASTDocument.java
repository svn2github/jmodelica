package org.jmodelica.ide.editor;

import java.io.FileNotFoundException;

import org.eclipse.jface.text.BadLocationException;
import org.eclipse.jface.text.BadPositionCategoryException;
import org.eclipse.jface.text.Document;
import org.eclipse.jface.text.DocumentEvent;
import org.eclipse.jface.text.Position;
import org.jmodelica.modelica.compiler.ASTNode;
import org.jmodelica.modelica.compiler.BaseNode;
import org.jmodelica.modelica.compiler.Element;
import org.jmodelica.modelica.compiler.ParserException;
import org.jmodelica.modelica.compiler.ParserHandler;
import org.jmodelica.util.FormattingItem;
import org.jmodelica.util.ScannedFormattingItem;


public class ASTDocument extends Document {
	private boolean verbose;
	private ASTNode<?> ast;

	public ASTDocument() {
		super();
		verbose = false;
		ast = null;
		printLog("Default constructor for ASTDocument called.");
	}
	
	public ASTDocument(String initialContent) {
		super(initialContent);
		verbose = false;
		ast = null;
		printLog("Constructor for ASTDocument called with argument [initialContent = \"" + initialContent + "\"].");
	}
	
	void printLog(String string, boolean doPrint) {
		if (doPrint) {
			System.out.println(string);
		}
	}
	
	void printLog(String string) {
		printLog(string, verbose);
	}

	@Override
	public void addPosition(String category, Position position)
			throws BadLocationException, BadPositionCategoryException {
		super.addPosition(category, position);
		printLog("addPosition([category = " + category + ", position = " + position + "])");
	}

	@Override
	public void addPosition(Position position) throws BadLocationException {
		super.addPosition(position);
		printLog("addPosition([position = " + position + "])");
	}

	@Override
	public void replace(int pos, int length, String text, long modificationStamp) throws BadLocationException {
		super.replace(pos, length, text, modificationStamp);
		printLog("replace([pos = " + pos + "], [length = " + length + "], [text = " + text + "], [modificationStamp = " + modificationStamp + "])");
	}

	@Override
	public void replace(int pos, int length, String text) throws BadLocationException {
		super.replace(pos, length, text);
		printLog("replace([pos = " + pos + "], [length = " + length + "], [text = " + text + "])");
	}

	@Override
	public char getChar(int pos) throws BadLocationException {
		char result =  super.getChar(pos);
		printLog("getChar([pos = " + pos + "]) -> [" + result + "]");
		return result;
	}

	@Override
	public int getLength() {
		int result = super.getLength();
		printLog("getLength() -> [" + result + "]");
		return result;
	}

	@Override
	public String get() {
		if (ast == null) {
			printLog("Nothing to get.");
			return "";
		}

		String result = ast.prettyPrintFormatted();
		printLog("get() -> [" + result + "]");
		return result;
	}

	@Override
	protected void fireDocumentChanged(DocumentEvent event) {
		super.fireDocumentChanged(event);
		printLog("fireDocumentChanged([event = " + event + "])");
	}

	@Override
	protected void fireDocumentAboutToBeChanged(DocumentEvent event) {
		super.fireDocumentAboutToBeChanged(event);		
		if (event.getText().matches("[ \t\f\r\n]*")) {
			try {
				int startLine = getLineOfOffset(event.getOffset()) + 1;
				int startColumn = event.getOffset() - getLineInformationOfOffset(event.getOffset()).getOffset() + 1;
				int endLine = getLineOfOffset(event.getOffset() + event.getLength()) + 1;
				int endColumn = (event.getOffset() + event.getLength()) - getLineInformationOfOffset(event.getOffset() + event.getLength()).getOffset() + 1;
				FormattingItem.Type type = FormattingItem.Type.NON_BREAKING_WHITESPACE;
				if (event.getText().matches("[\r\n]*")) {
					type = FormattingItem.Type.LINE_BREAK;
				}
				printLog("Adding formatting item with the position (" + startLine + ", " + startColumn + "; " + endLine + ", " + endColumn + ")...", true);
				ScannedFormattingItem newItem = new ScannedFormattingItem(type, event.getText(),
						startLine, startColumn, endLine, endColumn);
				BaseNode match = ast.insertMoreFormatting(newItem);
				if (match != null) {
					printLog("Done!", true);
					int newLines = newItem.spanningLines();
					if (event.getText().endsWith("\n")) {
						++newLines;
					}
					printLog("Offsetting trailing AST nodes by (" + newItem.spanningLines() + newLines + ", " + newItem.spanningColumnsOnLastLine() + ")...", true);
					long start = System.currentTimeMillis();
					ast.offsetNodesAfter(startLine, startColumn, newLines, newItem.spanningColumnsOnLastLine());
					long time = System.currentTimeMillis() - start;
					printLog("Done after " + (time / 1000) + "." + ((((time % 1000) < 100) ? ((time % 1000) < 10) ? "00" : "0" : "") + (time % 1000)) + " seconds.", true);
					printLog(ast.prettyPrintFormatted(), true);
				} else {
					printLog("Unable to find anywhere to place the formatting item.", true);
				}
			} catch (BadLocationException badLocationException) {
				System.err.println(badLocationException.getMessage());
			}
		} else {
			ParserHandler parserHandler = new ParserHandler();
			try {
				Element element = parserHandler.parseElementString(event.getText());
				ast.addNewElement(element, event.getOffset(), this);
			} catch (ParserException e) {
				e.printStackTrace();
			} catch (FileNotFoundException e) {
				e.printStackTrace();
			} catch (Exception e) {
				e.printStackTrace();
			}
		}
		printLog("fireDocumentAboutToBeChanged([event = " + event + "])");
	}

	@Override
	public String get(int pos, int length) throws BadLocationException {
		if (ast == null || length == 0) {
			return "";
		}

		int startLine = getLineOfOffset(pos) + 1;
		int startColumn = pos - getLineInformationOfOffset(pos).getOffset() + 1;
		int endLine = getLineOfOffset(pos + length) + 1;
		int endColumn = (pos + length) - getLineInformationOfOffset(pos + length).getOffset();
		String result = null;
		if (length == getLength()) {
			result = ast.prettyPrintFormatted();
		} else {
			result = ast.printPart(startLine, startColumn, endLine, endColumn, length);
		}
//		return getFallback(result, pos, length, startLine, startColumn, endLine, endColumn);

		return result;
	}

	@SuppressWarnings("unused")
	private String getFallback(String result, int pos, int length, int startLine, int startColumn, int endLine, int endColumn) {
		if (result == null) {
			StringBuilder sb = new StringBuilder();
			for (int i = 0; i < length; i++) {
				sb.append((char) ('A' + (startColumn + i) % ('Z' - 'A' + 1)));
			}
			result = sb.toString();
			printLog("get([pos = " + pos + ", length = " + length + "]): AST lookup failed.");
			printLog("Middle result: [startLine = " + startLine + ", startColumn = " + startColumn + ", endLine = " + endLine + ", endColumn = " + endColumn + "]");
		} else if (result.length() != length) {
			printLog("get([pos = " + pos + "], [length = " + length + "]) returns a string with illegal length. The length should be " + length + ", but is " + result.length() + ". -> [" + result + "]");
			printLog("Middle result: [startLine = " + startLine + ", startColumn = " + startColumn + ", endLine = " + endLine + ", endColumn = " + endColumn + "]");
		} else {
			printLog("get([pos = " + pos + ", length = " + length + "]) -> [" + result + "]");
		}

		return result;
	}

	@Override
	public void set(String text) {
		super.set(text);
		printLog("set([text = " + text + "])");
	}

	@Override
	public void set(String text, long modificationStamp) {
		super.set(text, modificationStamp);
		printLog("set([text = " + text + ", modificationStamp = " + modificationStamp + "])");
	}
	
	public void setAST(ASTNode<?> ast) {
		this.ast = ast;
		ast.propagateFormatting();
	}
}
