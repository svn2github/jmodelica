package org.jmodelica.devel.launch;

import org.eclipse.core.resources.IFile;
import org.eclipse.core.resources.IResource;
import org.eclipse.core.runtime.CoreException;

public class Refresh implements Runnable {

	private IResource resource;
	private int depth;

	public Refresh(IResource resource) {
		this(resource, IResource.DEPTH_INFINITE);
	}

	public Refresh(IResource resource, int depth) {
		this.resource = resource;
		this.depth = depth;
	}

	public void run() {
		System.out.println("Refresh.run(): start");
		try {
			resource.refreshLocal(depth, null);
		} catch (CoreException e) {
			System.out.println("Refresh.run(): exception");
			// Swallow silently - this is best-effort
		}
		System.out.println("Refresh.run(): done");
	}

}
