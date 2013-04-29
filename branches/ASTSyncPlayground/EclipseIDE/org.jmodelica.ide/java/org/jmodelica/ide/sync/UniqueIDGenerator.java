package org.jmodelica.ide.sync;

public class UniqueIDGenerator {
	private static UniqueIDGenerator instance;
	private int listenerID = 0;
	private int changeSetID = 0;
	private boolean lastSaveGraphical = false;

	private UniqueIDGenerator() {
	}

	public static synchronized UniqueIDGenerator getInstance() {
		if (instance == null)
			instance = new UniqueIDGenerator();
		return instance;
	}

	public synchronized int getListenerID() {
		listenerID++;
		return listenerID;
	}

	public synchronized int getChangeSetID() {
		changeSetID++;
		return changeSetID;
	}

	public synchronized void setLastSaveGraphical() {
		lastSaveGraphical = true;
	}

	public synchronized boolean needWeRecompile() {
		boolean toReturn = lastSaveGraphical;
		lastSaveGraphical = false;
		return !toReturn;
	}
}
