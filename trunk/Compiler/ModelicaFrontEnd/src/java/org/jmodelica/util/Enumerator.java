package org.jmodelica.util;

/**
 * A simple class that can be used when calculating indexes to nodes
 * 
 * @author jsten
 *
 */
public class Enumerator {
	
	private int count;
	
	/**
	 * Default constructor with start value of zero.
	 */
	public Enumerator() {
		this(0);
	}
	
	/**
	 * Constructor allows for custom start value when enumerating.
	 * 
	 * @param start The start value
	 */
	public Enumerator(int start) {
		count = start;
	}
	
	/**
	 * Returns the current index and increments it.
	 * @return current index
	 */
	public int next() {
		return count++;
	}
	
	/**
	 * Returns the current index without incrementing.
	 * @return current index
	 */
	public int peek() {
		return count;
	}

}