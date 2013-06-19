package org.jmodelica.devel.setup;

import org.eclipse.core.resources.IFile;
import org.eclipse.core.resources.IResource;
import org.eclipse.core.runtime.CoreException;
import org.eclipse.core.runtime.IPath;
import org.eclipse.core.runtime.Path;

public class FileDef {

	private IPath path;
	private FileCreator creator;

	public FileDef(String path, FileCreator creator) {
		this.path = new Path(path);
		this.creator = creator;
	}

	public boolean checkSetup(ProjectDef proj) {
		IFile file = proj.getIProject().getFile(path);
		try {
			file.refreshLocal(IResource.DEPTH_ZERO, null);
		} catch (CoreException e) {
			// Not critical, so don't care
		}
		return file.exists();
	}

	public boolean trySetup(ProjectDef proj) {
		System.out.println("FileDef.trySetup(): start");
		if (checkSetup(proj)) {
			System.out.println("FileDef.trySetup(): file ok");
			return true;
		}
		System.out.println("FileDef.trySetup(): create files");
		creator.createFiles(proj);
		System.out.println("FileDef.trySetup(): check if it worked");
		return checkSetup(proj);
	}

}
