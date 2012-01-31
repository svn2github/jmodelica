package org.jmodelica.icons.listeners;

import java.util.Collections;
import java.util.LinkedList;
import java.util.List;


public class Observable<T> {
	private LinkedList<T> listeners = null;
	
	public void addlistener(T listener) {
		if (listeners == null) {
			listeners = new LinkedList<T>();
		}
		listeners.add(listener);
	}
	
	public void removeListener(T listener) {
		if (listeners == null)
			return;
		listeners.remove(listener);
	}
	
	protected List<T> getListeners() {
		if (listeners == null)
			return Collections.emptyList();
		else
			return listeners;
	}
	
}
