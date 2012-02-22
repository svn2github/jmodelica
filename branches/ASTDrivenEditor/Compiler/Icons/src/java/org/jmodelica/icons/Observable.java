package org.jmodelica.icons;

import java.util.Vector;


public class Observable {
	private Vector<Observer> observers = null;
	
	public void addObserver(Observer observer) {
		if (observers == null) {
			observers = new Vector<Observer>();
		}
		if (!observers.contains(observer))
			observers.add(observer);
	}
	
	public void removeObserver(Observer observer) {
		if (observers == null)
			return;
		observers.remove(observer);
	}
	
	protected void notifyObservers(Object flag) {
		notifyObservers(flag, null);
	}
	
	protected void notifyObservers(Object flag, Object additionalInfo) {
		if (observers == null)
			return;
		for (Observer o : observers)
			o.update(this, flag, additionalInfo);
	}
	
}
