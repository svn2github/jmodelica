package org.jmodelica.util;

import java.util.Iterator;

/**
 * Iterator that iterates over several iterators in parallel.
 */
public class ParallelIterator<T> implements Iterator<T[]> {
	
	private T[] elems;
	private Iterator<? extends T>[] iters;
	private boolean max;
	
	public ParallelIterator(T[] res, Iterator<? extends T>... iterators) {
		this(res, false, iterators);
	}
	
	public ParallelIterator(T[] res, boolean max, Iterator<? extends T>... iterators) {
		iters = iterators;
		elems = res;
		this.max = max;
		if (elems.length < iters.length)
			throw new IllegalArgumentException();
		for (int i = iters.length; i < elems.length; i++)
			elems[i] = null;
	}
	
	public boolean hasNext() {
		for (Iterator<? extends T> it : iters)
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
		for (Iterator<? extends T> it : iters)
			it.remove();
	}
	
}
