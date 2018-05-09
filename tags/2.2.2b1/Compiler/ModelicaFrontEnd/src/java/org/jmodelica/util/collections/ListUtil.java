package org.jmodelica.util.collections;

import java.util.ArrayList;

/**
 * Utility methods for {@link java.util.List List}s.
 */
public final class ListUtil {

    /**
     * Hidden default constructor to prevent instantiation.
     */
    private ListUtil() {}

    /**
     * Creates a new list with initial list elements.
     * 
     * @param <T>       the type of elements the list contains.
     * @param elements  the elements.
     * @return          a {@link java.util.List List} containing {@code elements}.
     */
    @SafeVarargs
    public static <T> java.util.List<T> create(T... elements) {
        java.util.List<T> list = new ArrayList<T>();
        for (T element : elements) {
            list.add(element);
        }
        return list;
    }

    /**
     * Creates a list of strings from the string representation of elements.
     * 
     * @param <T>       the type of elements the list contains.
     * @param elements  the elements.
     * @return          a {@link java.util.List List} containing the string representation of {@code elements}.
     */
    @SafeVarargs
    public static <T> java.util.List<String> stringList(T... elements) {
        java.util.List<String> strings = new ArrayList<String>();
        for (T element : elements) {
            strings.add(element.toString());
        }
        return strings;
    }
}
