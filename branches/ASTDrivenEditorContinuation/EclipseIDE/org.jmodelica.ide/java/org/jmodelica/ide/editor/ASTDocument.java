package org.jmodelica.ide.editor;

import org.eclipse.jface.text.BadLocationException;
import org.eclipse.jface.text.BadPositionCategoryException;
import org.eclipse.jface.text.Document;
import org.eclipse.jface.text.Position;
import org.jmodelica.modelica.compiler.ASTNode;


public class ASTDocument extends Document {
	private boolean verbose;
	private ASTNode<?> ast;

	ASTDocument() {
		super();
		verbose = false;
		ast = null;
		printLog("Default constructor for ASTDocument called.");
	}
	
	ASTDocument(String initialContent) {
		super(initialContent);
		verbose = false;
		ast = null;
		printLog("Constructor for ASTDocument called with argument [initialContent = \"" + initialContent + "\"].");
	}
	
	void printLog(String string, boolean force) {
		if (verbose || force) {
			System.out.println(string);
		}
	}
	
	void printLog(String string) {
		printLog(string, false);
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
			printLog("[" + result + "] :: " + result.length() + " characters.");
			printLog("Number of DefaultFormattingItems in the AST: " + ast.numberOfDefaultFormattingItems() + ".");
		} else {
			result = ast.printPart(startLine, startColumn, endLine, endColumn, length);
		}
		if (result == null) {
			StringBuilder sb = new StringBuilder();
			for (int i = 0; i < length; i++) {
				sb.append((char) ('A' + (startColumn + i) % ('Z' - 'A' + 1)));
			}
			result = sb.toString();
			printLog("get([pos = " + pos + ", length = " + length + "]): AST lookup failed.", true);
			printLog("Middle result: [startLine = " + startLine + ", startColumn = " + startColumn + ", endLine = " + endLine + ", endColumn = " + endColumn + "]", true);
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
	
	public void setAST(CompilationResult compilationResult) {
		this.ast = compilationResult.root();
		ast.propagateFormatting();
	}
}
