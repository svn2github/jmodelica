package org.jmodelica.ide.editor.editingstrategies;

import java.util.HashMap;
import java.util.HashSet;
import java.util.Map;
import java.util.Set;

import org.eclipse.jface.text.BadLocationException;
import org.eclipse.jface.text.DefaultIndentLineAutoEditStrategy;
import org.eclipse.jface.text.DocumentCommand;
import org.eclipse.jface.text.IAutoEditStrategy;
import org.eclipse.jface.text.IDocument;
import org.eclipse.jface.text.ITypedRegion;
import org.eclipse.jface.text.TextUtilities;
import org.jmodelica.generated.scanners.CurrentIndentationScanner;
import org.jmodelica.generated.scanners.Modelica32PartitionScanner;
import org.jmodelica.generated.scanners.NextIndentationScanner;
import org.jmodelica.ide.IDEConstants;

/**
 * Auto-edit strategy for indentation support.
 * 
 * Delegates to different auto-edit strategies for different partition types. 
 * The specialized strategies are inner classes in this class.
 * 
 * @author jmattsson
 */
public class IndentationStrategy implements IAutoEditStrategy {
	
	// Note: CommentIndentationStrategy depends on these values
	public static final int COMMENT_STYLE_INDENT = 3;
	public static final int COMMENT_STYLE_FLUSH  = 0;
	public static final int COMMENT_STYLE_STAR   = 1;
	
	// TODO: Read from preferences
	// TODO: Add preference listener(s) to update settings
	/** The tab length. */
	protected static int TAB_LEN = 4;
	/** The length of one indentation step. */
	protected static int INDENT_STEP = 4;
	/** Prefer tabs over spaces in indentation strings. */
	protected static boolean PREFER_TAB = true;
	/** 
	 * Style to use for indentation of C style comments, 
	 * must be one of the COMMENT_STYLE_* constants. 
	 */
	protected static int COMMENT_STYLE = COMMENT_STYLE_INDENT;
	
	/** Map from partition type to indentation strategy for that partition type. */
	protected Map<String, IAutoEditStrategy> perPartition; 
	
	/** Size of cache for indentation strings. */
	private static final int INDENTATION_CACHE_SIZE = 33;
	
	/** Cache for indentation strings. */
	// TODO: Must be reset if TAB_LEN or PREFER_TAB is changed.
	private static String[] indentationCache = new String[INDENTATION_CACHE_SIZE];
	
	/** 
	 * Set of the partition types that are considered to include the surrounding 
	 * spaces between characters. 
	 */
	protected static final Set<String> openPartitionTypes = new HashSet<String>();
	static {
		openPartitionTypes.add(Modelica32PartitionScanner.NORMAL_PARTITION);
		openPartitionTypes.add(IDocument.DEFAULT_CONTENT_TYPE);
		openPartitionTypes.add(IDEConstants.CONTENT_TYPE_ID);
	}
	
	/**
	 * Creates a new delegating indentation strategy.
	 * 
	 * Creates and fills the map of the specialized strategies.
	 */
	public IndentationStrategy() {
		perPartition = new HashMap<String, IAutoEditStrategy>();
		IAutoEditStrategy aes = new NormalIndentationStrategy();
		perPartition.put(Modelica32PartitionScanner.NORMAL_PARTITION, aes);
		perPartition.put(IDocument.DEFAULT_CONTENT_TYPE, aes);
		perPartition.put(IDEConstants.CONTENT_TYPE_ID, aes);
		aes = new AnnotationIndentationStrategy();
		perPartition.put(Modelica32PartitionScanner.ANNOTATION_PARTITION, aes);
		aes = new CommentIndentationStrategy();
		perPartition.put(Modelica32PartitionScanner.COMMENT_PARTITION, aes);
	}

	/**
	 * Adjust indentation for commands that creates a new line.
	 * 
	 * Delegates to the specialized strategy for the current partition.
	 */
	@Override
	public void customizeDocumentCommand(IDocument d, DocumentCommand c) {
		try {
			String partitionType = getPartition(d, c.offset).getType();
			IAutoEditStrategy aes = perPartition.get(partitionType);
			if (aes != null)
				aes.customizeDocumentCommand(d, c);
			if (c.getCommandCount() > 1)
				c.caretOffset = c.offset; //needed for added command to be run
		} catch (BadLocationException e) {
		}
	}
	
	/**
	 * Get the partition to do indentation in for the given document and offset.
	 * 
	 * If offset is in a partition boundary, then partitions of a type in 
	 * {@link #openPartitionTypes} are given priority, and if both are same 
	 * priority, the one after the offset is chosen.
	 */
	public static ITypedRegion getPartition(IDocument d, int offset) throws BadLocationException {
		ITypedRegion res = d.getPartition(offset);
		if (res.getOffset() == offset && !openPartitionTypes.contains(res.getType())) {
			ITypedRegion before = d.getPartition(offset - 1);
			if (openPartitionTypes.contains(before.getType()))
				res = before;
		}
		return res;
	}
	
	/**
	 * Create an indentation string for the given indentation level.
	 * 
	 * The strings are cached.
	 */
	public static String indentString(int level) {
		if (level < 0)
			level = 0;
		if (level < INDENTATION_CACHE_SIZE && indentationCache[level] != null)
			return indentationCache[level];
		
		StringBuilder buf = new StringBuilder();
		int l = 0;
		if (PREFER_TAB) 
			for (; l + TAB_LEN <= level; l += TAB_LEN)
				buf.append('\t');
		for (; l < level; l++)
			buf.append(' ');
		String res = buf.toString();
		
		if (level < INDENTATION_CACHE_SIZE)
			indentationCache[level] = res;
		return res;
	}
	
	/**
	 * Check if the command is one that should prompt indentation.
	 */
	public static boolean shouldIndent(IDocument d, DocumentCommand c) {
		return c.text != null && TextUtilities.endsWith(d.getLegalLineDelimiters(), c.text) != -1;
	}
	
	/**
	 * Change the indentation of the current line.
	 * 
	 * @param c       the command to alter
	 * @param oldInd  the current indentation
	 * @param newInd  the new indentation level
	 */
	public static void changeIndent(DocumentCommand c, Indent oldInd, int newInd) {
		try {
			if (oldInd.level != newInd) {
				String indStr = indentString(newInd);
				if (indStr.equals(""))
					indStr = null;
				c.addCommand(oldInd.offset, oldInd.length, indStr, c.owner);
				if (c.caretOffset == -1)
					c.caretOffset = c.offset; //needed for added command to be run
			}
		} catch (BadLocationException e) {
		}
	}

	/**
	 * Get the indentation level of a given line.
	 */
	public static int getIndentOfLine(IDocument d, int line) {
		try {
			int res = 0;
			char c;
			for (int i = d.getLineOffset(line); isWhitespace(c = d.getChar(i)); i++) {
				if (c == ' ')
					res++;
				else if (c == '\t')
					res += TAB_LEN - res % TAB_LEN;
				else
					return (line > 0) ? getIndentOfLine(d, line - 1) : res;
			}
			return res;
		} catch (BadLocationException e) {
			return 0;
		}
	}
	
	/**
	 * Check if a character is whitespace as defined by Modelica.
	 */
	private static boolean isWhitespace(char c) {
		return c == ' ' || c == '\t' || c == '\n' || c == '\r';
	}

	/**
	 * Describes an indentation.
	 */
	public static class Indent {
		/**
		 * The number of spaces the indent is equivalent to.
		 */
		public int level;
		
		/**
		 * The position in the file of the start of the indent.
		 */
		public int offset;
		
		/**
		 * The length in characters of the indent.
		 */
		public int length;
	}
	
	/**
	 * Indentation strategy for normal partitions.
	 * 
	 * Uses scanners to calculate what indentation to use.
	 */
	protected class NormalIndentationStrategy implements IAutoEditStrategy {
		
		/** Scanner for calculating the current and wanted indentation of the current line. */
		protected CurrentIndentationScanner curScanner;
		/** Scanner to calculate the wanted indentation of the next line. */
		protected NextIndentationScanner nextScanner;
		
		public NormalIndentationStrategy() {
			curScanner = new CurrentIndentationScanner();
			nextScanner = new NextIndentationScanner();
			curScanner.setOptions(TAB_LEN, INDENT_STEP);
			nextScanner.setOptions(TAB_LEN, INDENT_STEP);
		}

		@Override
		public void customizeDocumentCommand(IDocument d, DocumentCommand c) {
			if (!shouldIndent(d, c))
				return;
			
			// Get indentation info
			int curCh = curScanner.findIndentChange(d, c.offset - 1);
			int nextCh = nextScanner.findIndentChange(d, c.offset - 1);
			Indent ind = curScanner.getCurrentIndent();
			int cur = ind.level + curCh;
			
			// Add indentation for next line
			int next = cur + nextCh;
			if (next > 0)
				c.text += indentString(next);
			
			// Adjust indentation for current line
			if (curCh != 0)
				changeIndent(c, ind, cur);
		}
	}
	
	/**
	 * Base class for indentation strategies where indentation depends only on 
	 * the indentation level of the current line and if the current line is the first 
	 * line in the partition.
	 */
	protected abstract class LineIndentationStrategy implements IAutoEditStrategy {

		@Override
		public void customizeDocumentCommand(IDocument d, DocumentCommand c) {
			if (!shouldIndent(d, c))
				return;
			
			try {
				// Get line and indent info
				int cur = d.getLineOfOffset(c.offset - 1);
				int beg = d.getLineOfOffset(getPartition(d, c.offset).getOffset());
				int indent = getIndentOfLine(d, cur);
				
				// Perform indentation
				doIndentation(c, cur == beg, indent);
			} catch (BadLocationException e) {
			}
		}

		/**
		 * Perform the indentation change.
		 * 
		 * @param c       the command to alter
		 * @param first   true if the current line is the fist line in the partition
		 * @param indent  the indentation level of the current line
		 */
		protected abstract void doIndentation(DocumentCommand c, boolean first, int indent);
		
	}
	
	/**
	 * Indentation strategy for annotation partitions.
	 */
	protected class AnnotationIndentationStrategy extends LineIndentationStrategy {

		protected void doIndentation(DocumentCommand c, boolean first, int indent) {
			// Indent second line of annotation (i.e. if current line is first line)
			if (first)
				indent += INDENT_STEP;
			
			// Add indentation for next line
			if (indent > 0)
				c.text += indentString(indent);
		}
		
	}
	
	/**
	 * Indentation strategy for comment partitions.
	 */
	protected class CommentIndentationStrategy extends LineIndentationStrategy {

		@Override
		protected void doIndentation(DocumentCommand c, boolean first, int indent) {
			// Indent second line of comment (i.e. if current line is first line)
			if (first)
				indent += COMMENT_STYLE;
			
			// Add indentation for next line
			if (indent > 0)
				c.text += indentString(indent);
			
			// Add a * at start of each line if option active
			if (COMMENT_STYLE == COMMENT_STYLE_STAR)
				c.text += "* ";
		}
		
	}
	
}
