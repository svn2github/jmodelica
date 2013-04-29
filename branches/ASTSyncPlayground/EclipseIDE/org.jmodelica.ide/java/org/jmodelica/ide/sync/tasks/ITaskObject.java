package org.jmodelica.ide.sync.tasks;

public interface ITaskObject {
	/* Task types */
	public static final int REMOVE_COMPONENT = 1;
	public static final int ADD_COMPONENT = 2;
	public static final int RENAME_NODE = 3;
	public static final int UPDATE = 4;
	public static final int CACHE = 5;
	public static final int ADD_CONNECTCLAUSE = 6;
	public static final int REMOVE_CONNECTCLAUSE = 7;
	public static final int UNDO_REMOVE = 8;
	public static final int UNDO_ADD = 9;
	public static final int RECOMPILE_FILE = 10;
	public static final int GRAPHICAL_AESTHETIC = 11;

	/* Task priorities */
	public static final int PRIORITY_HIGHEST = 3;
	public static final int PRIORITY_HIGH = 2;
	public static final int PRIORITY_MEDIUM = 1;
	public static final int PRIORITY_LOW = 0;

	public abstract void doJob();

	public abstract int getJobType();
	
	public abstract int getJobPriority();

	public abstract int getListenerID();
}
