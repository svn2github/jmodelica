package org.jmodelica.util;

import java.util.Iterator;
import java.util.NoSuchElementException;

/**
 * \brief Generic iterator over a single value.
 */
public class SingleIterator<T> implements Iterator<T> {
	
	protected T elem;
	protected boolean ok;
	
	public SingleIterator(T e) {
		elem = e;
		ok = true;
	}
	
	public boolean hasNext() {
		return ok;
	}
	
	public T next() {
		if (!ok)
			throw new NoSuchElementException();
		ok = false;
		return elem;
	}
	
	public void remove() {
		throw new UnsupportedOperationException();
	}
}
