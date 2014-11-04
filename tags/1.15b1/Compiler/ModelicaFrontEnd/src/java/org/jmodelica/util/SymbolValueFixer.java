package org.jmodelica.util;

import java.lang.reflect.Field;
import java.security.AccessController;
import java.security.PrivilegedAction;

import beaver.Symbol;

/**
 * Changes value of <code>value</code> field of beaver.Symbol to refer to itself.
 * Needed to work around bug where fullCopy() copies <code>value</code> field as well.
 */
public class SymbolValueFixer {
	private final static Field VALUE;

	static {
		Field f = null;
		try {
			f = beaver.Symbol.class.getField("value");
		} catch (Exception e) {
			throw (e instanceof RuntimeException) ? (RuntimeException) e : new RuntimeException(e);
		}
		VALUE = f;
		AccessEnabler.enable(VALUE);
	}

	public static void fix(Symbol s) {
		try {
			VALUE.set(s, s);
		} catch (Exception e) {
			throw (e instanceof RuntimeException) ? (RuntimeException) e : new RuntimeException(e);
		}
	}

	private static class AccessEnabler implements PrivilegedAction {

		public static void enable(Field f) {
			AccessController.doPrivileged(new AccessEnabler(f));
		}

		private Field field;

		private AccessEnabler(Field f) {
			field = f;
		}

		public Object run() {
			field.setAccessible(true);
			return null;
		}

	}

}
