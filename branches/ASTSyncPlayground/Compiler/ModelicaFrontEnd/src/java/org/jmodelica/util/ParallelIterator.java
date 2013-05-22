package org.jmodelica.util;

import java.util.Iterator;

/**
 * Iterator that iterates over several iterators in parallel.
 */
public class ParallelIterator<T> implements Iterator<T[]> {
	
	private T[] elems;
	private Iterator<T>[] iters;
	private boolean max;
	
	public ParallelIterator(T[] res, Iterator<T>... iterators) {
		this(res, false, iterators);
	}
	
	public ParallelIterator(T[] res, boolean max, Iterator<T>... iterators) {
		iters = iterators;
		elems = res;
		this.max = max;
		if (elems.length < iters.length)
			throw new IllegalArgumentException();
		for (int i = iters.length; i < elems.length; i++)
			elems[i] = null;
	}
	
	public boolean hasNext() {
		for (Iterator<T> it : iters)
			if (it.hasNext() == max)
				return max;
		return !max;
	}
	
	public T[] next() {
		for (int i = 0; i < iters.length; i++)
			elems[i] = iters[i].hasNext() ? iters[i].next() : null;
		return elems;
	}

	public void remove() {
		for (Iterator<T> it : iters)
			it.remove();
	}
	
}
