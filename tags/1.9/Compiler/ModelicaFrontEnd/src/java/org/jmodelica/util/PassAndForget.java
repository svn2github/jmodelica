package org.jmodelica.util;

public class PassAndForget<T> {
	private T obj;
	
	public PassAndForget(T o) {
		obj = o;
	}
	
	public T pass() {
		T o = obj;
		obj = null;
		return o;
	}
}
