package org.jmodelica.ide.indent;

/**
 * Anchor point in text, providing indentation hints. 
 * @author philip
 */
public class Anchor {
	
	public final static Anchor BOTTOM = new Anchor(0, 0, Indent.SAME, "#", false); 

	public int reference;
	public int offset;
	public Indent indent;
	public String id;
	public boolean modifiesCurrentLine;
			
	/** Create an Anchor at <code>offset</code>. Indent in region after anchor
	 * should be the same as at offset <code>reference</code>, adjusted
	 * with <code>indent</code>. 
	 * @param offset offset of anchor
	 * @param reference reference offset for indentation 
	 * @param indent adjust from reference 
	 * @param id name of anchor to identify where it came from
	 * @param modifiesCurrentLine if anchor changes indentation of current
	 * line rather than the following text
	 */
	public Anchor(int offset, int reference, Indent indent, String id,
	        boolean modifiesCurrentLine) {
		this.reference = reference; 
		this.offset = offset;
		this.indent = indent;
		this.id = id; 
		this.modifiesCurrentLine = modifiesCurrentLine;
	}
	
	public Anchor(int offset, int reference) { 
		this(offset, reference, Indent.SAME, null, false); 
	}
	
	public String toString() {
	    return "^" + offset + ", " + indent + "^";
	}
		
}

