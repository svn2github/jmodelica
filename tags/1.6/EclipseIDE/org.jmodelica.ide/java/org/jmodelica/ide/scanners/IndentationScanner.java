package org.jmodelica.ide.scanners;

import java.io.IOException;
import java.io.Reader;

import org.eclipse.jface.text.IDocument;
import org.jmodelica.ide.helpers.BackwardsDocumentReader;

public abstract class IndentationScanner extends DocumentScanner {
    
	/** The length of a tab. */
    protected int tabLen;
    /** The indentation step length. */
    protected int stepLen;
    /** The offset in the document of the first character scanned. */
    protected int offset;
    
	protected BackwardsDocumentReader createReader() {
		return new BackwardsDocumentReader();
	}
	
	/**
	 * Set the options for the indentation.
	 * 
	 * @param tab   the length of a tab
	 * @param step  the indentation step length
	 */
	public void setOptions(int tab, int step) {
		tabLen = tab;
		stepLen = step;
	}
    
	/**
	 * Initialize and scan though the document to fine the proper indentation.
	 * 
	 * @return  the amount the indentation should change compared to current line.
	 */
	protected abstract int scan() throws IOException;
	
	/**
	 * Find the amount the indentation should change compared to current line, 
	 * given that enter is pressed with the caret at <code>offset</code> in 
	 * <code>document</code>.
	 */
	public int findIndentChange(IDocument document, int offset) {
		reset(document, offset);
		this.offset = offset;
        try {
			return scan();
		} catch (IOException e) {
			return 0;
		}
    }
}
