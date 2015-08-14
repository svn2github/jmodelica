package org.jmodelica.util;

import java.util.Iterator;

public class ChainedIterable<T> implements Iterable<T> {
    private Iterable<? extends T>[] its;
    public ChainedIterable(Iterable<? extends T> ... its) {
        this.its = its;
    }

    @Override
    public Iterator<T> iterator() {
        Iterator<? extends T>[] iterators = new Iterator[its.length];
        for (int i = 0; i < its.length; i++)
            iterators[i] = its[i].iterator();
        return new ChainedIterator(iterators);
    }
}
