package org.jmodelica.util;

import java.util.Iterator;

/**
 * Iterable that iterates over several iterables in parallel.
 */
public class ParallelIterable<T> implements Iterable<T[]> {
	
	private T[] elems;
	private Iterable<? extends T>[] iters;
	private boolean max;
	
	public ParallelIterable(T[] res, Iterable<? extends T>... iterables) {
		this(res, false, iterables);
	}
	
	public ParallelIterable(T[] res, boolean max, Iterable<? extends T>... iterables) {
		iters = iterables;
		elems = res;
		this.max = max;
	}

	public Iterator<T[]> iterator() {
		Iterator<? extends T>[] iterators = new Iterator[iters.length];
		for (int i = 0; i < iters.length; i++)
			iterators[i] = iters[i].iterator();
		return new ParallelIterator(elems, max, iterators);
	}

}
