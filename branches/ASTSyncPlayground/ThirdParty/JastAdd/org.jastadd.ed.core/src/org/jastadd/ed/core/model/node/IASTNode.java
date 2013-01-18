package org.jastadd.ed.core.model.node;

import org.eclipse.core.runtime.jobs.ILock;
import org.eclipse.core.runtime.jobs.Job;

public interface IASTNode {
	public IASTNode getChild(int i);
	public int getNumChild();
	public IASTNode getParent();
	
	public static final ILock LOCK = Job.getJobManager().newLock();
}
