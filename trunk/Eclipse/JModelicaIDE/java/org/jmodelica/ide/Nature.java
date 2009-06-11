package org.jmodelica.ide;

import org.eclipse.core.resources.IProject;
import org.eclipse.core.resources.IProjectNature;
import org.eclipse.core.runtime.CoreException;

public class Nature implements IProjectNature {

	public static final String NATURE_ID = Constants.NATURE_ID;
	
	private IProject project;
	
	public void configure() throws CoreException {
		// Add things like configuration files required for a project with this nature
	}

	public void deconfigure() throws CoreException {
		// Remove things added in configure()
	}

	public IProject getProject() {
		return project;
	}

	public void setProject(IProject project) {
		this.project = project;
	}

}
