package org.jastadd.ed.core.model;

public interface ITaskObject {
	/* Task types */
	static final int REMOVE_COMPONENT = 1;
	static final int ADD_COMPONENT = 2;
	static final int RENAME_NODE = 3;
	static final int UPDATE = 4;
	static final int CACHE = 5;
	static final int ADD_CONNECTCLAUSE = 6;
	static final int REMOVE_CONNECTCLAUSE = 7;
	static final int UNDO_REMOVE = 8;
	static final int UNDO_ADD = 9;
	static final int RECOMPILE_FILE = 10;
	static final int GRAPHICAL_AESTHETIC = 11;
	static final int GENERATE_DOCUMENTATION = 12;

	/* Task priorities */
	static final int PRIORITY_HIGHEST = 3;
	static final int PRIORITY_HIGH = 2;
	static final int PRIORITY_MEDIUM = 1;
	static final int PRIORITY_LOW = 0;

	abstract void doJob();

	abstract int getJobType();

	abstract int getJobPriority();

	abstract int getListenerID();
}