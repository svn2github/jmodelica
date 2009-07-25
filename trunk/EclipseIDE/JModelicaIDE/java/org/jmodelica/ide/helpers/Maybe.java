package org.jmodelica.ide.helpers;

/**
 * 
 * Class to use instead of returning null as a special value.
 * Contains one value that can be null or not null;
 * 
 * @author philip
 *
 * @param <E>
 */
public class Maybe<E> {

    private E value;
    
    /**
     * Sets the contained value to null.
     */
    public Maybe() {
        this.value = null;
    }
    
    /**
     * Sets the contained value to <code>e</code>
     * @param e value to use
     */
    public Maybe(E e) {
        this.value = e;
    }
    
    public boolean isNull() {
        return value == null;
    }
    
    public boolean hasValue() {
        return !isNull();
    }

    public E value() {
        return value;
    }

    /**
     * Returns contained value unless null, <code>defaulValue</code> otherwise.
     * @param defaultValue default value
     * @return contained value unless null, <code>defaulValue</code> otherwise.
     */
    public E fromMaybe(E defaultValue) {
        return hasValue() ? value() : defaultValue;
    }
}
