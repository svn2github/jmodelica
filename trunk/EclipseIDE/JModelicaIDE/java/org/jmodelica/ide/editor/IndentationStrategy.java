/*
    Copyright (C) 2009 Modelon AB

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, version 3 of the License.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/
package org.jmodelica.ide.editor;

import org.eclipse.jface.text.BadLocationException;
import org.eclipse.jface.text.DefaultIndentLineAutoEditStrategy;
import org.eclipse.jface.text.DocumentCommand;
import org.eclipse.jface.text.IDocument;
import org.eclipse.jface.text.IRegion;
import org.eclipse.jface.text.ITypedRegion;
import org.eclipse.jface.text.Region;
import org.eclipse.jface.text.TextUtilities;
import org.jmodelica.ide.helpers.Util;
import org.jmodelica.ide.scanners.generated.BackwardClassFinder;
import org.jmodelica.ide.scanners.generated.IndentationKeywordScanner;
import org.jmodelica.ide.scanners.generated.Modelica22PartitionScanner;


class IndentationStrategy extends DefaultIndentLineAutoEditStrategy {
	
	protected static final IndentationKeywordScanner iks = new IndentationKeywordScanner();
	protected static final BackwardClassFinder backwDefnFinder = new BackwardClassFinder();
	protected static final int TABSTOP = 4;
	protected static final int INDENT = TABSTOP;
	
	/**
	 * Check if region <code>reg</code> is a
	 * C-style comment, i.e. on the form /* comment *\/ 
	 */
	protected static boolean isCStyleComment(IDocument d, ITypedRegion reg) 
			throws BadLocationException {
		return reg.getType() == Modelica22PartitionScanner.COMMENT_PARTITION &&
			d.get(reg.getOffset(), reg.getLength()).startsWith("/*");	
	}
	
	/**
	 * Check if region <code>reg</code> is normal code
	 */
	protected static boolean isNormal(IDocument d, ITypedRegion reg) throws BadLocationException {
		return !isCStyleComment(d, reg) && !isAnnotation(reg);
	}
	
	/**
	 * Check if region <code>reg</code> is an annotation
	 */
	protected static boolean isAnnotation(ITypedRegion reg) {
		return reg.getType() == Modelica22PartitionScanner.ANNOTATION_PARTITION;
	}
	
	/**
	 * Check if region <code>reg</code> is code that shouldn't have any indentation support
	 */
	protected static boolean isNotToBeIndented(ITypedRegion reg) {
		return reg.getType() == Modelica22PartitionScanner.QIDENT_PARTITION ||
			reg.getType() == Modelica22PartitionScanner.STRING_PARTITION;
	}

	/** 
	 * Get indentation string of line containing offset <code>refStart</code>
	 */
	protected String getIndentation(IDocument d, DocumentCommand c, int refStart)
			throws BadLocationException {
		IRegion refLine  = d.getLineInformationOfOffset(refStart);
		int start = refLine.getOffset();
		return d.get(start, beginningOfLineText(d, refLine) - start);
	}		

	protected int beginningOfLineText(IDocument d, IRegion lineInfo)
			throws BadLocationException {
		int begOfLineText = findEndOfWhiteSpace(d, lineInfo.getOffset(), 
				lineInfo.getOffset() + lineInfo.getLength());
		return begOfLineText;
	}	
	
	protected static ITypedRegion getPartitionPreferNormal(IDocument d, int offset) throws BadLocationException {
		ITypedRegion r = d.getPartition(offset);
		if (!isNormal(d, r) && r.getOffset() == offset && offset > 0) {
			ITypedRegion r2 = d.getPartition(offset - 1);
			if (isNormal(d, r2))
				return r2;
		}
		return r;
	}

	protected void handleLineBreak(IDocument d, DocumentCommand c) 
			throws BadLocationException {
	
		ITypedRegion partition = getPartitionPreferNormal(d, c.offset);
		IRegion lineInfo = d.getLineInformationOfOffset(c.offset);
		int start = lineInfo.getOffset();
		int end = start + lineInfo.getLength();
		ITypedRegion startPart = getPartitionPreferNormal(d, start);
		while (isCStyleComment(d, startPart) || isNotToBeIndented(startPart)) {
			start = d.getLineInformationOfOffset(startPart.getOffset()).getOffset();
			startPart = getPartitionPreferNormal(d, start);
		}
		if (start != lineInfo.getOffset())
			lineInfo = new Region(start, end - start);
		
		String line = d.get(lineInfo.getOffset(), lineInfo.getLength());
		int begOfLineText = beginningOfLineText(d, lineInfo);
		/* don't keep indentation after pointer when making new line */
		c.offset = Math.max(c.offset, begOfLineText);	
		
		iks.match(line);
		int indent = countWSWidth(line);
		
		if (isCStyleComment(d, partition)) {
			IRegion refLine = d.getLineInformationOfOffset(partition.getOffset());
			line = d.get(refLine.getOffset(), refLine.getLength());
			indent = countWidth(line, partition.getOffset() - refLine.getOffset()) + 3;
		} else if (isAnnotation(partition)) {
			int curLine = d.getLineOfOffset(c.offset);
			int startLine = d.getLineOfOffset(partition.getOffset());
			if (curLine == startLine)
				indent += INDENT;
		} else if (iks.matchesEndBlock()) {
			adjustThisLine(d, c, iks.getId(), lineInfo);	
		} else if (iks.matchesBeginBlock() &&
				   c.offset >= begOfLineText + iks.getKeyword().length()) { 
			indent += INDENT;
		} 
		c.text += makeWS(indent);	
	}

	private void handleLineTerminator(IDocument d, DocumentCommand c) 
			throws BadLocationException {
		int reference = c.offset;
		IRegion lineInfo = d.getLineInformationOfOffset(reference);
		String line = d.get(lineInfo.getOffset(), lineInfo.getLength());
		
		iks.match(line);
		if (iks.matchesEndBlock()) 
			this.adjustThisLine(d, c, iks.getId(), lineInfo);
	}

	private void adjustThisLine(IDocument d, DocumentCommand c, String id,
			IRegion targetLine) throws BadLocationException {
	
		System.out.println(id);
		/* NOTE:defnOffset is the offset counting _backwards_ from _reference_ */
		int defnOffset = backwDefnFinder.findIndent(d, c.offset, id);		
		if (defnOffset < 0) 
			return; 
		
		int referenceLineOffset = Math.max(0, c.offset - defnOffset + c.text.length());
		IRegion l = d.getLineInformationOfOffset(referenceLineOffset);
		System.out.println(d.get(l.getOffset(), 10));
		
		c.addCommand(targetLine.getOffset(),
				getIndentation(d, c, targetLine.getOffset()).length(),
				getIndentation(d, c, referenceLineOffset),
				null);
		c.caretOffset = c.offset; //needed for added command to be run 
	}

	private void handlePastedBlock(IDocument d, DocumentCommand c) 
			throws BadLocationException {
		IRegion lineInfo = d.getLineInformationOfOffset(c.offset);
		String line = d.get(lineInfo.getOffset(), lineInfo.getLength());
		int begOfLineText = beginningOfLineText(d, lineInfo);
		if (c.offset <= begOfLineText) {
			int wsPaste = countWSWidth(c.text);
			int wsLine = countWSWidth(line);
			String[] arr = c.text.split("\n|\r|\r\n", -1);
			arr[0] = changeWS(arr[0], -wsPaste);
			for (int i = 1; i < arr.length; i++)
				arr[i] = changeWS(arr[i], wsLine - wsPaste);
			String delim = TextUtilities.getDefaultLineDelimiter(d);
			c.text = Util.implode(delim, arr);
		}
	}
	
	protected String changeWS(String str, int change) {
		int len = Math.max(0, countWSWidth(str) + change);
		return makeWS(len) + str.trim();
	}

	protected static String makeWS(int len) {
		StringBuilder buf = new StringBuilder();
		for (int i = 0; i < len / TABSTOP; i++)
			buf.append('\t');
		for (int i = 0; i < len % TABSTOP; i++)
			buf.append(' ');
		String string = buf.toString();
		return string;
	}

	private static int countWidthOrWsWidth(String s, int len) {
		int w = 0, i = 0;
		while (i < s.length() && (i < len || (len == 0 && isWS(s.charAt(i))))) {
			if (s.charAt(i) == '\t')
				w += TABSTOP - w % TABSTOP;
			else	
				w++;
			i++;
		}
		return w;		
	}
	
	protected static int countWidth(String s, int len) {
		return countWidthOrWsWidth(s, len);
	}

	protected static int countWSWidth(String s) {
		return countWidth(s, 0);
	}

	protected static boolean isWS(char c) {
		return (c == ' ' || c == '\t');
	}
	
	@Override
	public void customizeDocumentCommand(IDocument d, DocumentCommand c) {
		try {
			if (!isNotToBeIndented(getPartitionPreferNormal(d, c.offset))) {
				if (TextUtilities.indexOf(d.getLegalLineDelimiters(), c.text, 0)[0] != -1)
					handlePastedBlock(d, c);
				if (TextUtilities.endsWith(d.getLegalLineDelimiters(), c.text) != -1)
					handleLineBreak(d, c);
				else if (c.text.endsWith(";"))
					handleLineTerminator(d, c);
			}
		} catch (BadLocationException e) {
			System.out.println("BadLocation calculating indent");
			e.printStackTrace();
//		} catch (Error e) {
//			e.printStackTrace();
		}
	}
}


//
//public class IndentationStrategy implements IAutoEditStrategy {
//	// TODO: read TAB & STEP from preferences
//	/* TODO: Handle pasting: 
//	 * 		   + if no new line is formed, don't adjust before or indent after
//	 *         + indent based on last line in pasted code if a new line is formed
//	 *         + indent all lines beginning in pasted text based on previous line
//	 */
//	/* TODO: Possible new strategy?
//	 * 		 In normal partition: iterate backward through partitions until a line that 
//	 *       starts in a normal partition is found, measure indent of that line, scan 
//	 *       forward to current pos, counting things that should change indent.
//	 */
//
//	private static final int TAB = 4;
//	private static final int STEP = 4;
//	private static final int INDENT = IndentationKeywordScanner.INDENT;
//	private static final int ADJUST = IndentationKeywordScanner.ADJUST;
//	
//	private BackwardClassFinder classFinder;
//	
//	private AfterStatementScanner afterStatementScanner;
//	private IndentationKeywordScanner indentationKeywordScanner;
//
//	
//	public void customizeDocumentCommand(IDocument document,
//			DocumentCommand command) {
//			new Indentor().customizeDocumentCommand(document, command);
//	}
//
//	private boolean isNormal(String type) {
//		return type == Modelica22PartitionScanner.NORMAL_PARTITION || 
//			type == Modelica22PartitionScanner.DEFINITION_PARTITION || 
//			type == IDocument.DEFAULT_CONTENT_TYPE;
//	}
//
//	private boolean isAnnotation(String type) {
//		return type == Modelica22PartitionScanner.ANNOTATION_PARTITION;
//	}
//
//	private boolean isTraditionalComment(Command cmd) {
//		return cmd.partition.getType() == Modelica22PartitionScanner.COMMENT_PARTITION && 
//			!commentIsLine(cmd.document, cmd.partition.getOffset());
//	}
// 
//	private boolean commentIsLine(IDocument document, int offset) {
//		try {
//			char ch = document.getChar(offset + 1);
//			return ch == '/';
//		} catch (BadLocationException e) {
//			return true;
//		}
//	}
//
//	private void newlineInNormal(Command cmd) {
//		if (isNewLevel(cmd) || isInStatement(cmd, cmd.command.offset)) 
//			cmd.cur.spaces += STEP;
//		indentNext(cmd);
//	}
//
//	private void newlineInComment(IDocument doc, DocumentCommand command, Command cmd) throws BadLocationException {
//		ITypedRegion partition = doc.getPartition(command.offset);
//		int partitionLineNbr = doc.getLineOfOffset(partition.getOffset());		
//		IRegion partitionLinePos = doc.getLineInformation(partitionLineNbr);
//		String partitionLine = doc.get(partitionLinePos.getOffset(), partitionLinePos.getLength());
//		//cmd.cur = getIndent(partitionLine, -1);
//		
//		int editLineNbr = doc.getLineOfOffset(command.offset);		
//		IRegion editLinePos = doc.getLineInformation(editLineNbr);
//		String editLine = doc.get(editLinePos.getOffset(), editLinePos.getLength());
//		
//		System.out.println(editLine);
//		System.out.println(editLine.trim().endsWith("*/"));
//		if (!editLine.trim().endsWith("*/")){
////			cmd.cur.spaces += 3;
////			cmd.cur.chars += 3;
//		} 
//		indentNext(cmd);
//	}
//
//	private void newlineInAnnotation(Command cmd) {
//		if (cmd.editLineNbr == cmd.partLineNbr)
//			cmd.cur.spaces += STEP;
//		indentNext(cmd);
//	}
//
//	private void markForUpdate(Command cmd) {
//		if (cmd.command.caretOffset < 0)
//			cmd.command.caretOffset = cmd.command.offset;
//		else 
//			cmd.command.doit = false;
//	}
//
//	private IRegion narrowRegionToNormalPart(Command cmd, int offset)
//			throws BadLocationException {
//		IRegion res = cmd.document.getLineInformationOfOffset(offset);
//		int start = res.getOffset();
//		int end = start + res.getLength();
//		boolean make = false;
//		ITypedRegion sPart = cmd.document.getPartition(start);
//		if (!isNormal(sPart.getType())) {
//			start = sPart.getOffset() + sPart.getLength();
//			make = true;
//		}
//		ITypedRegion ePart = cmd.document.getPartition(end);
//		if (!isNormal(ePart.getType())) {
//			end = ePart.getOffset();
//			make = true;
//		}
//		if (make)
//			res = new Region(start, end - start);
//		return res;
//	}
//
//	private boolean isInStatement(Command cmd, int offset) {
//		try {
//			if (afterStatement(cmd, offset))
//				return false;
//			int prevEnd = cmd.document.getLineInformationOfOffset(offset).getOffset() - 1;
//			IRegion prevPos = narrowRegionToNormalPart(cmd, prevEnd);
//			String prev = cmd.document.get(prevPos.getOffset(), prevPos.getLength());
//			// Exclude line delimiter
//			prevEnd = prevPos.getOffset() + prevPos.getLength();
//			if (findWords(prev, INDENT) != null || afterStatement(cmd, prevEnd))
//				return true;
//		} catch (BadLocationException e) {
//		}
//		return false;
//	}
//
//	private boolean afterStatement(Command cmd, int offset) {
//		if (afterStatementScanner == null)
//			afterStatementScanner = new AfterStatementScanner();
//		return afterStatementScanner.isAfterStatement(cmd.document, offset - 1);
//	}
//
//	private boolean isNewLevel(Command cmd) {
//		Word indentWord = findWords(cmd.findLine, INDENT);
//		if (indentWord == null)
//			return false;
//		if (cmd.adjust == null)
//			return true;
//		return cmd.adjust.word.equals(indentWord.word) || !cmd.adjust.id.equals(indentWord.id); 
//	}
//
//	private void changeIndent(Command cmd, int lineOffset, int target) {
//		int delete = 0, add = 0;
//		if (target > cmd.cur.spaces) {
//			add = target - cmd.cur.spaces;
//		} else {
//			int len = 0;
//			int change = cmd.cur.spaces - target;
//			for (int p = cmd.cur.chars - 1; p >= 0 && len < change; p--, delete++) {
//				switch (cmd.line.charAt(p)) {
//				case ' ':
//					len++;
//					break;
//				case '\t':
//					len += TAB;
//					break;
//				}
//			}
//			add = len - change;
//		}
//		try {
//			String str = indentStr("", add);
//			cmd.command.addCommand(lineOffset + cmd.cur.chars - delete, delete, str, null);
//		} catch (BadLocationException e) {
//		}
//	}
//	
//	private void indentNext(Command cmd) {
//		cmd.command.text = indentStr(cmd.command.text, cmd.cur.spaces);
//		int pos = cmd.command.offset + cmd.command.length;
//		int len = 0;
//		try {
//			char ch = cmd.document.getChar(pos + len);
//			while (ch == ' ' || ch == '\t') {
//				ch = cmd.document.getChar(pos + ++len);
//			}
//		} catch (BadLocationException e) {
//		} 
//		try {
//			if (len > 0)
//				cmd.command.addCommand(pos, len, "", null);
//		} catch (BadLocationException e) {
//		}
//	}
//
//	private String indentStr(String prefix, int length) {
//		// TODO: use preferences to decide between using spaces and tabs
//		StringBuilder buf = new StringBuilder(prefix);
//		for (int i = 0; i < length; i++) 
//			buf.append(' ');
//		return buf.toString();
//	}
//
//	private BackwardClassFinder getClassFinder() {
//		if (classFinder == null)
//			classFinder = new BackwardClassFinder();
//		return classFinder;
//	}
//	
//	// TODO: use IDocument instead of string & skip empty lines (take previous)
//	// TODO: create getNormalIndent(): find indent of last line that starts in normal partition
//	private Indent getIndent(String line, int max) {
//		Indent ind = new Indent();
//		ind.chars = 0;
//		ind.spaces = 0;
//		boolean stop = false;
//		boolean stopOnNonWS = max <= 0;
//		max = stopOnNonWS ? line.length() : Math.min(max, line.length());
//		for (int i = 0; !stop && i < max; i++) {
//			switch (line.charAt(i)) {
//			case '\t':
//				int tab = ind.spaces % TAB;
//				ind.spaces += (tab == 0) ? TAB : tab;
//				ind.chars++;
//				break;
//			case ' ':
//				ind.spaces++;
//				ind.chars++;
//				break;
//			case '\n':
//			case '\r':
//				ind.chars = 0;
//				ind.spaces = 0;
//				break;
//			default:
//				if (stopOnNonWS) {
//					stop = true;
//				} else {
//					ind.spaces++;
//					ind.chars++;
//				}
//			break;
//			}
//		}
//		return ind;
//	}
//
//	private Word findWords(String line, int type) {
//		if (indentationKeywordScanner == null)
//			indentationKeywordScanner = new IndentationKeywordScanner();
//		return indentationKeywordScanner.findWord(line, type);
//	}
//
//	public class Command {
//		public IDocument document;
//		public DocumentCommand command;
//		public IRegion linePos;
//		public String line;
//		public int editLineNbr;
//		public Indent cur;
//		public ITypedRegion partition;
//		public int partLineNbr;
//		public Word adjust;
//		public String findLine;
//
//		public Command(IDocument document, DocumentCommand command) {
//			this.document = document;
//			this.command = command;
//			try {
//				editLineNbr = document.getLineOfOffset(command.offset);
//				linePos = document.getLineInformation(editLineNbr);
//				line = document.get(linePos.getOffset(), linePos.getLength());
//				cur = getIndent(line, 0);
//				partition = document.getPartition(Math.max(0, command.offset - 1));
//				partLineNbr = document.getLineOfOffset(partition.getOffset());
//			} catch (BadLocationException e) {
//			}
//			if (isNormal(partition.getType())) {
//				try {
//					IRegion pos = narrowRegionToNormalPart(this, command.offset);
//					findLine = document.get(pos.getOffset(), pos.getLength());
//				} catch (BadLocationException e) {
//				}
//			} else {
//				findLine = line;
//			}
//		}
//		
//		public void setAdjust() {
//			adjust = findWords(line, ADJUST);
//		}
//		
//		void adjustLine() {
//			int indent = -1;
//			int lineOffset = linePos.getOffset();
//			ITypedRegion linePartition;
//			try {
//				linePartition = document.getPartition(lineOffset);
//			} catch (BadLocationException e1) {
//				return;
//			}
//			String type = linePartition .getType();
//			if (isNormal(type)) {
//				setAdjust();
//				if (adjust != null && cur.chars == adjust.pos) 
//					indent = getClassFinder().findIndent(document, lineOffset, adjust.id, TAB);
//			} else if (isAnnotation(type) && !linePartition.equals(partition)) {
//				try {
//					int offset = linePartition.getOffset();
//					IRegion linePos = document.getLineInformationOfOffset(offset);
//					String line = document.get(linePos.getOffset(), linePos.getLength());
//					Indent ind = getIndent(line, 0);
//					indent = ind.spaces;
//				} catch (BadLocationException e) {
//				}
//			}
//			if (indent >= 0) {
//				changeIndent(this, lineOffset, indent);
//				cur.spaces = indent;
//			}
//		}
//	}
//
//	private class Indent {
//		public int spaces = 0;
//		public int chars = 0;
//	}
//	
//	public static class Word {
//		public String id;
//		public String word;
//		public int pos;
//		
//		public Word(String word, String id, int pos) {
//			this.word = word;
//			this.id = id;
//			this.pos = pos;
//		}
//	}
//}