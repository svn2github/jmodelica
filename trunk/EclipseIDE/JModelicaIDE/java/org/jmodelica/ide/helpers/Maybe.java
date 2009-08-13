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

    protected E value;

    public static <E> Maybe<E> Just(E e) { return new Maybe<E>(e); }
    @SuppressWarnings("unused") public static <E> Maybe<E> Nothing(Class<E> c) { return new Maybe<E>(); }
    
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
    
    /**
     * returns true iff. contained value is null.
     * @return true iff. contained value is null.
     */
    public boolean isNull() {
        return value == null;
    }
    
    /**
     * returns true iff. contained value is non-null.
     * @return true iff. contained value is non-null.
     */
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
    
    @Override
    public String toString() {
        return isNull() 
            ? "Nothing" 
            : String.format("Just(%s)", value().toString());
    }
    
    /**
     * Left biased or on Maybe.
     * @param other other Maybe
     * @return this, iff. this.hasValue(). other otherwise.
     */
    public Maybe<E> orElse(Maybe<? extends E> other) {
        return hasValue() ? this : new Maybe<E>(other.value);
    }
}
