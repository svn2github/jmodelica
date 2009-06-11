package org.jmodelica.ide.editor;

import org.eclipse.jface.text.BadLocationException;
import org.eclipse.jface.text.DocumentCommand;
import org.eclipse.jface.text.IAutoEditStrategy;
import org.eclipse.jface.text.IDocument;
import org.eclipse.jface.text.IRegion;
import org.eclipse.jface.text.ITypedRegion;
import org.eclipse.jface.text.Region;
import org.jmodelica.ide.scanners.generated.AfterStatementScanner;
import org.jmodelica.ide.scanners.generated.BackwardClassFinder;
import org.jmodelica.ide.scanners.generated.IndentationKeywordScanner;
import org.jmodelica.ide.scanners.generated.Modelica22PartitionScanner;

public class IndentationStrategy implements IAutoEditStrategy {
	// TODO: read TAB & STEP from preferences
	/* TODO: Handle pasting: 
	 * 		   + if no new line is formed, don't adjust before or indent after
	 *         + indent based on last line in pasted code if a new line is formed
	 *         + indent all lines beginning in pasted text based on previous line
	 */
	/* TODO: Possible new strategy?
	 * 		 In normal partition: iterate backward through partitions until a line that 
	 *       starts in a normal partition is found, measure indent of that line, scan 
	 *       forward to current pos, counting things that should change indent.
	 */

	private static final int TAB = 4;
	private static final int STEP = 4;
	private static final int INDENT = IndentationKeywordScanner.INDENT;
	private static final int ADJUST = IndentationKeywordScanner.ADJUST;
	
	private BackwardClassFinder classFinder;
	private AfterStatementScanner afterStatementScanner;
	private IndentationKeywordScanner indentationKeywordScanner;

	public void customizeDocumentCommand(IDocument document,
			DocumentCommand command) {
		if (isNewLine(command.text)) {
			Command cmd = new Command(document, command);
			if (cmd.ok) {
				adjustLine(cmd);
				String type = cmd.partition.getType();
				if (isNormal(type))
					newlineInNormal(cmd);
				else if (isAnnotation(type))
					newlineInAnnotation(cmd);
				else if (isTraditionalComment(cmd))
					newlineInComment(cmd);
				markForUpdate(cmd);
			}
		}
	}

	private void adjustLine(Command cmd) {
		int indent = -1;
		int lineOffset = cmd.linePos.getOffset();
		ITypedRegion linePartition;
		try {
			linePartition = cmd.document.getPartition(lineOffset);
		} catch (BadLocationException e1) {
			return;
		}
		String type = linePartition .getType();
		if (isNormal(type)) {
			cmd.setAdjust();
			if (cmd.adjust != null && cmd.cur.chars == cmd.adjust.pos) 
				indent = getClassFinder().findIndent(cmd.document, lineOffset, cmd.adjust.id, TAB);
		} else if (isAnnotation(type) && !linePartition.equals(cmd.partition)) {
			try {
				int offset = linePartition.getOffset();
				IRegion linePos = cmd.document.getLineInformationOfOffset(offset);
				String line = cmd.document.get(linePos.getOffset(), linePos.getLength());
				Indent ind = getIndent(line, 0);
				indent = ind.spaces;
			} catch (BadLocationException e) {
			}
		}
		if (indent >= 0) {
			changeIndent(cmd, lineOffset, indent);
			cmd.cur.spaces = indent;
		}
	}

	private boolean isNormal(String type) {
		return type == Modelica22PartitionScanner.NORMAL_PARTITION || 
			type == Modelica22PartitionScanner.DEFINITION_PARTITION || 
			type == IDocument.DEFAULT_CONTENT_TYPE;
	}

	private boolean isAnnotation(String type) {
		return type == Modelica22PartitionScanner.ANNOTATION_PARTITION;
	}

	private boolean isTraditionalComment(Command cmd) {
		return cmd.partition.getType() == Modelica22PartitionScanner.COMMENT_PARTITION && 
			!commentIsLine(cmd.document, cmd.partition.getOffset());
	}
 
	private boolean commentIsLine(IDocument document, int offset) {
		try {
			char ch = document.getChar(offset + 1);
			return ch == '/';
		} catch (BadLocationException e) {
			return true;
		}
	}

	private void newlineInNormal(Command cmd) {
		if (isNewLevel(cmd) || isInStatement(cmd, cmd.command.offset)) 
			cmd.cur.spaces += STEP;
		indentNext(cmd);
	}

	private void newlineInComment(Command cmd) {
		if (cmd.lineNo == cmd.partLineNo) {
			int partCol = cmd.partition.getOffset() - cmd.linePos.getOffset();
			cmd.cur = getIndent(cmd.line, partCol + 3);
		}
		indentNext(cmd);
	}

	private void newlineInAnnotation(Command cmd) {
		if (cmd.lineNo == cmd.partLineNo)
			cmd.cur.spaces += STEP;
		indentNext(cmd);
	}

	private void markForUpdate(Command cmd) {
		if (cmd.command.caretOffset < 0)
			cmd.command.caretOffset = cmd.command.offset;
		else 
			cmd.command.doit = false;
	}

	private IRegion getNormalLine(Command cmd, int offset)
			throws BadLocationException {
		IRegion res = cmd.document.getLineInformationOfOffset(offset);
		int start = res.getOffset();
		int end = start + res.getLength();
		boolean make = false;
		ITypedRegion sPart = cmd.document.getPartition(start);
		if (!isNormal(sPart.getType())) {
			start = sPart.getOffset() + sPart.getLength();
			make = true;
		}
		ITypedRegion ePart = cmd.document.getPartition(end);
		if (!isNormal(ePart.getType())) {
			end = ePart.getOffset();
			make = true;
		}
		if (make)
			res = new Region(start, end - start);
		return res;
	}

	private boolean isNewLine(String text) {
		int len = text.length();
		char last = len > 0 ? text.charAt(len - 1) : '\0';
		return last == '\n' || last == '\r';
	}

	private boolean isInStatement(Command cmd, int offset) {
		try {
			if (afterStatement(cmd, offset))
				return false;
			int prevEnd = cmd.document.getLineInformationOfOffset(offset).getOffset() - 1;
			IRegion prevPos = getNormalLine(cmd, prevEnd);
			String prev = cmd.document.get(prevPos.getOffset(), prevPos.getLength());
			// Exclude line delimiter
			prevEnd = prevPos.getOffset() + prevPos.getLength();
			if (findWords(prev, INDENT) != null || afterStatement(cmd, prevEnd))
				return true;
		} catch (BadLocationException e) {
		}
		return false;
	}

	private boolean afterStatement(Command cmd, int offset) {
		if (afterStatementScanner == null)
			afterStatementScanner = new AfterStatementScanner();
		return afterStatementScanner.isAfterStatement(cmd.document, offset - 1);
	}

	private boolean isNewLevel(Command cmd) {
		Word indentWord = findWords(cmd.findLine, INDENT);
		if (indentWord == null)
			return false;
		if (cmd.adjust == null)
			return true;
		return cmd.adjust.word.equals(indentWord.word) || !cmd.adjust.id.equals(indentWord.id); 
	}

	private void changeIndent(Command cmd, int lineOffset, int target) {
		int delete = 0, add = 0;
		if (target > cmd.cur.spaces) {
			add = target - cmd.cur.spaces;
		} else {
			int len = 0;
			int change = cmd.cur.spaces - target;
			for (int p = cmd.cur.chars - 1; p >= 0 && len < change; p--, delete++) {
				switch (cmd.line.charAt(p)) {
				case ' ':
					len++;
					break;
				case '\t':
					len += TAB;
					break;
				}
			}
			add = len - change;
		}
		try {
			String str = indentStr("", add);
			cmd.command.addCommand(lineOffset + cmd.cur.chars - delete, delete, str, null);
		} catch (BadLocationException e) {
		}
	}
	
	private void indentNext(Command cmd) {
		cmd.command.text = indentStr(cmd.command.text, cmd.cur.spaces);
		int pos = cmd.command.offset + cmd.command.length;
		int len = 0;
		try {
			char ch = cmd.document.getChar(pos + len);
			while (ch == ' ' || ch == '\t') {
				ch = cmd.document.getChar(pos + ++len);
			}
		} catch (BadLocationException e) {
		} 
		try {
			if (len > 0)
				cmd.command.addCommand(pos, len, "", null);
		} catch (BadLocationException e) {
		}
	}

	private String indentStr(String prefix, int length) {
		// TODO: use preferences to decide between using spaces and tabs
		StringBuilder buf = new StringBuilder(prefix);
		for (int i = 0; i < length; i++) 
			buf.append(' ');
		return buf.toString();
	}

	private BackwardClassFinder getClassFinder() {
		if (classFinder == null)
			classFinder = new BackwardClassFinder();
		return classFinder;
	}
	
	// TODO: use IDocument instead of string & skip empty lines (take previous)
	// TODO: create getNormalIndent(): find indent of last line that starts in normal partition
	private Indent getIndent(String line, int max) {
		Indent ind = new Indent();
		ind.chars = 0;
		ind.spaces = 0;
		boolean stop = false;
		boolean stopOnNonWS = max <= 0;
		max = stopOnNonWS ? line.length() : Math.min(max, line.length());
		for (int i = 0; !stop && i < max; i++) {
			switch (line.charAt(i)) {
			case '\t':
				int tab = ind.spaces % TAB;
				ind.spaces += (tab == 0) ? TAB : tab;
				ind.chars++;
				break;
			case ' ':
				ind.spaces++;
				ind.chars++;
				break;
			case '\n':
			case '\r':
				ind.chars = 0;
				ind.spaces = 0;
				break;
			default:
				if (stopOnNonWS) {
					stop = true;
				} else {
					ind.spaces++;
					ind.chars++;
				}
			break;
			}
		}
		return ind;
	}

	private Word findWords(String line, int type) {
		if (indentationKeywordScanner == null)
			indentationKeywordScanner = new IndentationKeywordScanner();
		return indentationKeywordScanner.findWord(line, type);
	}

	public class Command {
		public IDocument document;
		public DocumentCommand command;
		public IRegion linePos;
		public String line;
		public int lineNo;
		public Indent cur;
		public boolean ok;
		public ITypedRegion partition;
		public int partLineNo;
		public Word adjust;
		public String findLine;

		public Command(IDocument document, DocumentCommand command) {
			this.document = document;
			this.command = command;
			try {
				lineNo = document.getLineOfOffset(command.offset);
				linePos = document.getLineInformation(lineNo);
				line = document.get(linePos.getOffset(), linePos.getLength());
				cur = getIndent(line, 0);
				ok = true;
			} catch (BadLocationException e) {
				ok = false;
			}
			try {
				partition = document.getPartition(command.offset);
				if (!isNormal(partition.getType()) && partition.getOffset() == command.offset) {
					ITypedRegion prev = document.getPartition(command.offset - 1);
					if (isNormal(prev.getType()))
						partition = prev;
				}
				partLineNo = document.getLineOfOffset(partition.getOffset());
			} catch (BadLocationException e) {
			}
			if (isNormal(partition.getType())) {
				try {
					IRegion pos = getNormalLine(this, command.offset);
					findLine = document.get(pos.getOffset(), pos.getLength());
				} catch (BadLocationException e) {
				}
			} else {
				findLine = line;
			}
		}
		
		public void setAdjust() {
			adjust = findWords(line, ADJUST);
		}
	}

	private class Indent {
		public int spaces = 0;
		public int chars = 0;
	}
	
	public static class Word {
		public String id;
		public String word;
		public int pos;
		
		public Word(String word, String id, int pos) {
			this.word = word;
			this.id = id;
			this.pos = pos;
		}
	}
}