package org.jmodelica.util;

import java.util.Iterator;

/**
 * \brief Generic iterator over constant array.
 */
public class ConstArrayIterator<T> implements Iterator<T> {
	
	protected T[] elems;
	protected int i;
	
	public ConstArrayIterator(T[] arr) {
		elems = arr;
		i = 0;
	}
	
	public boolean hasNext() {
		return i < elems.length;
	}
	
	public T next() {
		return elems[i++];
	}
	
	public void remove() {
		throw new UnsupportedOperationException();
	}
	
}
