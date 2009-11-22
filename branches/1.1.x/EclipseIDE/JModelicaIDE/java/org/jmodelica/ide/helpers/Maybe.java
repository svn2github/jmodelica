package org.jmodelica.ide.helpers;

/**
 * 
 * Class to use instead of returning null as a special value. Contains one value
 * that can be null or not null;
 * 
 * @author philip
 * 
 * @param <E>
 */
public class Maybe<E> { 

final protected E value;

public static <T> Maybe<T> Just(T t) {

    assert t != null;

    return new Maybe<T>(t);
}

public static <T> Maybe<T> Nothing() {
    return new Maybe<T>();
}

/**
 * Sets the contained value to null.
 */
public Maybe() {
    this.value = null;
}

/**
 * Sets the contained value to <code>e</code>
 * 
 * @param e value to use
 */
public Maybe(E e) {
    this.value = e;
}

/**
 * returns true iff. contained value is null.
 * 
 * @return true iff. contained value is null.
 */
public boolean isNothing() {
    return value == null;
}

/**
 * returns true iff. contained value is non-null.
 * 
 * @return true iff. contained value is non-null.
 */
public boolean hasValue() {
    return !isNothing();
}

public E value() {
    return value;
}

/**
 * Returns contained value unless null, <code>defaulValue</code> otherwise.
 * 
 * @param defaultValue default value
 * @return contained value unless null, <code>defaulValue</code> otherwise.
 */
public E defaultTo(E defaultValue) {
    return hasValue() ? value() : defaultValue;
}

/**
 * Left biased or on Maybe.
 * 
 * @param other other Maybe
 * @return this, iff. this.hasValue(). other otherwise.
 */
public Maybe<E> orElse(Maybe<? extends E> other) {
    return hasValue() ? this : new Maybe<E>(other.value);
}

/**
 * Returns Just value if <code> guard </code> is true, o.w. Nothing.
 * 
 * @param value value to bind
 * @param guard guard for binding
 * @return Just value if <code> guard </code> is true, o.w. Nothing.
 */
public static <E> Maybe<E> guard(E value, boolean guard) {
    return guard ? Just(value) : new Maybe<E>();
}

@Override
public String toString() {
    return isNothing() 
        ? "Nothing" 
        : String.format("Just(%s)", value());
}

/**
 * While this class is immutable and thus clearly could be co-variant in the
 * type parameter, this is not possible to declare in Java. This creates a new
 * Maybe<T>, with T <: E.
 * 
 * Technically this method can be used to perform an arbitrary cast, since the
 * java type system doesn't allow specifying the T <: E boundary either.
 * 
 * @param <T> Super type to subsume to
 * @param c Class of super type
 * @return this, with <code>value</code> subsumed to T.
 */
@SuppressWarnings({"unchecked"})

public <T> Maybe<T> subsume(Class<T> c) {
    return new Maybe<T>((T) value);
}

}
