package org.jmodelica.ide.namecomplete;



/**
 * This doesn't exist in Java? WTF
 * @author philip
 *
 * @param <A>
 * @param <B>
 */
public class Pair<A,B> { 

final A a; 
final B b; 

public Pair(A ia, B ib) { a = ia; b = ib; } 

public A fst() { return a; } 

public B snd() { return b; } 

public boolean equals(Object other) { 
    Pair<?,?> p2 = (Pair<?,?>)other; 
    return a.equals(p2.fst()) && b.equals(p2.snd());
}

public String toString() { 
    return String.format("(%s,%s)", a, b); 
}

}