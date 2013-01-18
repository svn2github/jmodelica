package org.jastadd.ed.core.model;

import org.eclipse.core.resources.IFile;
import org.eclipse.core.resources.IProject;
import org.eclipse.core.runtime.jobs.ILock;
import org.jastadd.ed.core.model.node.IGlobalRootNode;
import org.jastadd.ed.core.model.node.ILocalRootNode;

public interface IGlobalRootRegistry {
	
	public boolean doDiscard(IProject project);
	public boolean doUpdate(IProject project, IGlobalRootNode rootNode);
	public ILock getGlobalLock(IProject project);
	
	public ILocalRootNode[] doLookup(IFile file);
	public boolean doUpdate(IFile file, ILocalRootNode node);
	public boolean doDiscard(IFile file);
	
	public void addListener(IASTChangeListener l);
	public void removeListener(IASTChangeListener l);
	
}
