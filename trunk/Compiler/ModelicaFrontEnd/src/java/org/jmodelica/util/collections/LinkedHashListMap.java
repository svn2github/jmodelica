package org.jmodelica.util.collections;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Iterator;
import java.util.LinkedHashMap;
import java.util.List;

public class LinkedHashListMap<K, V> extends LinkedHashMap<K, List<V>> implements ListMap<K, V> {

    public LinkedHashListMap() {
        super();
    }

    public LinkedHashListMap(int initialCapacity, float loadFactor) {
        super(initialCapacity, loadFactor);
    }

    public LinkedHashListMap(int initialCapacity) {
        super(initialCapacity);
    }

    public void add(K key, V value) {
        List<V> list = get(key);
        if (list == null) {
            list = new ArrayList<V>();
            put(key, list);
        }
        list.add(value);
    }

    public List<V> getList(K key) {
        java.util.List<V> list = get(key);
        return (list == null) ? Collections.<V>emptyList() : list;
    }

    public boolean remove(K key, V value) {
        java.util.List<V> l = get(key);
        if (l != null) {
            Iterator<V> li = l.iterator();
            while (li.hasNext()) {
                if (li.next() == value) {
                    li.remove();
                    return true;
                }
            }
        }
        return false;
    }

}
