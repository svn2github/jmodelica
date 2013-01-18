package org.jastadd.ed.core.model.node;

import java.util.HashSet;

import org.eclipse.core.resources.IFile;
import org.eclipse.core.resources.IProject;
import org.eclipse.core.runtime.jobs.ILock;
import org.eclipse.core.runtime.jobs.Job;
import org.eclipse.swt.widgets.Display;
import org.jastadd.ed.core.model.IGlobalRootRegistry;

public class LocalRootHandle implements ILocalRootHandle {

	
	// Project AST lock from registry
	protected ILock fLock;
	// Spare lock used before a project is known
	private ILock fSpareLock;
	
	
	// File connected to local root node
	protected IFile fFile;
	
	protected boolean fInCompilableProject = false;
	
	// Local root node
	protected ILocalRootNode fLocalRoot;
	
	// AST registry
	protected IGlobalRootRegistry fRegistry;
	
	// Listeners
	private HashSet<ILocalRootNodeListener> fListenerSet = 
					new HashSet<ILocalRootNodeListener>();
	
	
	
	public LocalRootHandle(IGlobalRootRegistry registry) {
		fRegistry = registry;
	}
	
	/*
	public LocalRootHandle(IGlobalRootRegistry registry, IFile file) {
		this(registry);
		setFile(file);
	}
	
	public LocalRootHandle(IGlobalRootRegistry registry, IFile file, ILocalRootNode node) {
		this(registry);
		fFile = file;
		fLocalRoot = node;
		if (fFile != null) {
			IProject project = file.getProject();
			fLock = fRegistry.getGlobalLock(project);
		}
	}
	*/
	
	
	
	public void setLock(ILock lock) {
		fLock = lock;
	}
	
	@Override
	public ILock getLock() {
		if (fLock == null) {
			if (fSpareLock == null) {
				fSpareLock = Job.getJobManager().newLock();
			}
			return fSpareLock;
		}
		return fLock;
	}
	
	@Override
	public void setFile(IFile file, boolean withInCompilableProject) {
		if (file != null) {
			fFile = file;
			fInCompilableProject = withInCompilableProject;
			
			// Look up compiled local root
			if (fInCompilableProject) {
				ILocalRootNode[] res = fRegistry.doLookup(file);
				if (res.length == 1) {
					fLocalRoot = res[0];
				}
			}
			
			// Get lock for project, this works for all projects
			IProject project = file.getProject();
			fLock = fRegistry.getGlobalLock(project);
			
		}
	}
	
	@Override
	public boolean isInCompilableProject() {
		return fInCompilableProject;
	}


	@Override
	public IFile getFile() {
		return fFile;
	}

	@Override
	public ILocalRootNode getLocalRoot() {
		return fLocalRoot;
	}
		
	@Override
	public void setLocalRoot(ILocalRootNode node) {
		fLocalRoot = node;
		if (fInCompilableProject) {
			fRegistry.doUpdate(fFile, fLocalRoot);
		}
	}
	
	@Override
	public void setLocalRootQuietly(ILocalRootNode node) {
		fLocalRoot = node;
	}
	
	
	@Override
	public void addListener(ILocalRootNodeListener listener) {
		fListenerSet.add(listener);
	} 
	@Override
	public void removeListener(ILocalRootNodeListener listener) {
		if (fListenerSet.contains(listener)) {
			fListenerSet.remove(listener);
		}
	}
	@Override
	public void notifyListeners() {
		for (ILocalRootNodeListener l : fListenerSet) {
			final ILocalRootNodeListener listener = l;
			Display.getDefault().syncExec(new Runnable() {
				public void run() {
					listener.localRootChanged();
				}
			});
		}
	}
	
}
