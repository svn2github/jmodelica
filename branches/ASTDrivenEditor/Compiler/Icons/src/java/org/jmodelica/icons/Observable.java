package org.jmodelica.icons;

import java.util.Vector;


public class Observable {
	private Vector<Observer> observers = null;
	
	private Vector<Observer> addList = null;
	private Vector<Observer> removeList = null;
	private int notifyCount = 0;
	
	public void addObserver(Observer observer) {
		if (observers == null) {
			observers = new Vector<Observer>();
		}
		if (!observers.contains(observer)) {
			if (notifyCount == 0) {
				observers.add(observer);
			} else {
				if (addList == null)
					addList = new Vector<Observer>();
				addList.add(observer);
			}
		}
	}
	
	public void removeObserver(Observer observer) {
		if (observers == null)
			return;
		if (notifyCount == 0) {
			observers.remove(observer);
		} else {
			if (removeList == null)
				removeList = new Vector<Observer>();
			removeList.add(observer);
		}
	}
	
	protected void notifyObservers(Object flag) {
		notifyObservers(flag, null);
	}
	
	protected void notifyObservers(Object flag, Object additionalInfo) {
		if (observers == null)
			return;
		notifyCount++;
		for (Observer o : observers)
			o.update(this, flag, additionalInfo);
		notifyCount--;
		if (notifyCount == 0) {
			if (addList != null && addList.size() > 0) {
				for (Observer o : addList)
					addObserver(o);
				addList.removeAllElements();
			}
			if (removeList != null && removeList.size() > 0) {
				for (Observer o : removeList)
					removeObserver(o);
				removeList.removeAllElements();
			}
		}
	}
	
}
