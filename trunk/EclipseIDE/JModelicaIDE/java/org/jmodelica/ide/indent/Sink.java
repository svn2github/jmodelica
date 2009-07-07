package org.jmodelica.ide.indent;

/** 
 * Sink tokens, used to "sink" lines containing 'end' and 'equation' etc
 * to a reference Anchor 
 * @author philip */
public class Sink {
	
	public final static Sink BOTTOM = new Sink(0, Anchor.BOTTOM);

	public int offset;
	public Anchor reference;
	public Sink(int offset, Anchor reference) { 
		this.reference = reference;
		this.offset = offset;
	}
}