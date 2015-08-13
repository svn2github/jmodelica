package org.jmodelica.util.collections;

import java.util.Map;
import java.util.List;

/**
 * A map of lists.
 */
public interface ListMap<K, V> extends Map<K, List<V>> {

    /**
     * If there is a list mapped to key, add value to it, otherwise map a new list containing value to key.
     */
    public void add(K key, V value);

    /**
     * Get the list mapped to key, or an empty list if there is no list mapped to key.
     */
    public List<V> getList(K key);

    /**
     * Remove the first instance of value from the list mapped to key, if any.
     * 
     * @return  true if any element was removed
     */
    public boolean remove(K key, V value);
}
