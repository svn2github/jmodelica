package org.jmodelica.util.munkres;

public interface MunkresCost<T> extends Comparable<T> {
    public int compareTo(T other);
    public void subtract(T other);
    public void add(T other);
    public boolean isZero();
    public T copy();
}
