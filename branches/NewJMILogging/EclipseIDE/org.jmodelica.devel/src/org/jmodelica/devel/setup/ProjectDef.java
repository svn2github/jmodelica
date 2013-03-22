package org.jmodelica.devel.setup;

import java.lang.reflect.InvocationTargetException;

import org.eclipse.core.resources.IProject;
import org.eclipse.core.resources.IResource;
import org.eclipse.core.resources.ResourcesPlugin;
import org.eclipse.core.runtime.CoreException;
import org.eclipse.core.runtime.NullProgressMonitor;
import org.eclipse.jdt.core.IJavaProject;
import org.eclipse.jdt.core.JavaCore;
import org.eclipse.jdt.launching.IVMInstall;
import org.eclipse.jdt.launching.JavaRuntime;
import org.eclipse.swt.widgets.Shell;
import org.eclipse.ui.PlatformUI;
import org.tigris.subversion.subclipse.core.ISVNRemoteFolder;
import org.tigris.subversion.subclipse.core.ISVNRepositoryLocation;
import org.tigris.subversion.subclipse.core.SVNException;
import org.tigris.subversion.subclipse.core.repo.SVNRepositoryLocation;
import org.tigris.subversion.subclipse.ui.actions.CheckoutAsProjectAction;
import org.tigris.subversion.subclipse.ui.operations.CheckoutAsProjectOperation;

public class ProjectDef {

	private String name;
	private String repo;
	private String path;
	private FileDef[] files;

	private IProject iproj = null;

	public ProjectDef(String name, String repo, String path, FileDef[] files) {
		this.name = name;
		this.repo = repo;
		this.path = path;
		this.files = files;
	}

	public boolean checkSetup() {
		if (!projectExists())
			return false;
		for (FileDef file : files)
			if (!file.checkSetup(this))
				return false;
		return true;
	}

	private boolean projectExists() {
		return getIProject().exists();
	}

	public void ensureSetup() {
		System.out.println("ProjectDef.ensureSetup(): about to check project");
		if (!projectExists())
			checkoutProject();
		System.out.println("ProjectDef.ensureSetup(): about to check files");
		for (FileDef file : files)
			if (!file.trySetup(this))
				throw new RuntimeException("Project " + name + " not set up properly!");
		System.out.println("ProjectDef.ensureSetup(): done");
	}

	private void checkoutProject() {
		try {
			ISVNRepositoryLocation repoLoc = SVNRepositoryLocation.fromString(repo);
			ISVNRemoteFolder[] remote = new ISVNRemoteFolder[] { repoLoc.getRemoteFolder(path) };
			IProject[] local = new IProject[] { getIProject() };
			CheckoutAsProjectOperation co = new CheckoutAsProjectOperation(null, remote, local);
			co.execute(new NullProgressMonitor());
			getIProject().refreshLocal(IResource.DEPTH_INFINITE, null);
		} catch (SVNException e) {
			throw new RuntimeException("Project " + name + " not set up properly!", e);
		} catch (InterruptedException e) {
			throw new RuntimeException("Project " + name + " not set up properly!", e);
		} catch (CoreException e) {
			throw new RuntimeException("Project " + name + " not set up properly!", e);
		}
	}

	public IProject getIProject() {
		if (iproj == null) 
			iproj = ResourcesPlugin.getWorkspace().getRoot().getProject(name);
		return iproj;
	}

	public String getName() {
		return name;
	}

	public IVMInstall getVM() throws CoreException {
		IJavaProject jproj = JavaCore.create(getIProject());
		return JavaRuntime.getVMInstall(jproj);
	}

}
