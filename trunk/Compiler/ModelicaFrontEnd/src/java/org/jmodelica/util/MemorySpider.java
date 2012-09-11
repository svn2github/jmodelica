package org.jmodelica.util;

import java.lang.reflect.Field;
import java.security.AccessController;
import java.security.PrivilegedAction;
import java.security.PrivilegedExceptionAction;
import java.util.HashSet;
import java.util.LinkedList;
import java.util.Set;

public class MemorySpider {
	
	public interface Visitor {
		void visit(Object o);
	}
	
	public static abstract class ClassFilteredVisitor<T> implements Visitor {
		
		private Class<T> filter;

		public ClassFilteredVisitor(Class<T> cls) {
			filter = cls;
		}

		public void visit(Object o) {
			if (filter.isAssignableFrom(o.getClass()))
				visitFiltered((T) o);
		}
		
		protected abstract void visitFiltered(T o);
		
	}
    
    private static class GetFieldsAction implements PrivilegedAction {
    	
    	private Class cls;
    	
    	public Field[] perform(Class cl) {
    		cls = cl;
    		return (Field[]) AccessController.doPrivileged(this);
    	}

		public Object run() {
			return cls.getDeclaredFields();
		}
    	
    }
    
    private static class GetValueAction implements PrivilegedAction {
    	
    	private Field field;
    	
    	public Object perform(Field f, Object o) {
    		field = f;
    		if (!f.isAccessible())
    			AccessController.doPrivileged(this);
    		try {
				return f.get(o);
			} catch (IllegalAccessException e) {
				return null;
			}
    	}

		public Object run() {
			field.setAccessible(true);
			return null;
		}
    	
    }
    
    public MemorySpider(Visitor v) {
		visitor = v;
		visited = new HashSet<Object>(2000);
	}
    
	private static GetFieldsAction getFields = new GetFieldsAction();
	private static GetValueAction  getValue  = new GetValueAction();

	private Set<Object> visited;
	private Visitor visitor;
	
	public void traverse(Object o) {
		if (o == null || visited.contains(o))
			return;
		visited.add(o);
		visitor.visit(o);
		
		Class type = o.getClass();
		if (type.isArray()) {
			int len = java.lang.reflect.Array.getLength(o);
			if (!type.getComponentType().isPrimitive()) 
				for (int i = 0; i < len; i++) 
					traverse(java.lang.reflect.Array.get(o, i));
		} else if (o instanceof LinkedList) { // Special case for linked lists for efficiency
			for (Object o2 : (LinkedList) o)
				traverse(o2);
		} else {
			for (; type != null; type = type.getSuperclass())
				for (Field f : getFields.perform(type)) 
					traverse(getValue.perform(f, o));
		}
	}
}
