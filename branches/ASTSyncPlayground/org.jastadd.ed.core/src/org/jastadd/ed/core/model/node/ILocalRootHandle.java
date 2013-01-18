package org.jastadd.ed.core.model.node;

import org.eclipse.core.resources.IFile;
import org.eclipse.core.runtime.jobs.ILock;

public interface ILocalRootHandle {

	public ILock getLock();
	public IFile getFile();
	public void setFile(IFile file, boolean withInCompilableProject);
	public ILocalRootNode getLocalRoot();
	public void setLocalRoot(ILocalRootNode node);
	
	public void addListener(ILocalRootNodeListener l);
	public void removeListener(ILocalRootNodeListener l);
	public void notifyListeners();
	public boolean isInCompilableProject();
	void setLocalRootQuietly(ILocalRootNode node);
	
}
