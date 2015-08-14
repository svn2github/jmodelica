package org.jmodelica.util;

import java.util.Iterator;

public class FilteredIterator<T> implements Iterator<T> {
	
	private T next;
	private Iterator<T> parent;
	private Criteria<? super T> criteria;
	
	public FilteredIterator(Iterator<T> parent, Criteria<? super T> criteria) {
		this.parent = parent;
		this.criteria = criteria;
		next();
	}

	public boolean hasNext() {
		return next != null;
	}

	public T next() {
		T res = next;
		boolean found = false;
		while (!found && parent.hasNext()) {
			next = parent.next();
			found = criteria.test(next);
		}
		if (!found)
			next = null;
		return res;
	}

	public void remove() {
		throw new UnsupportedOperationException();
	}

}
