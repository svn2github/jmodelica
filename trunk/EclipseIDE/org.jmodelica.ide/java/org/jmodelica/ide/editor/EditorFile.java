package org.jmodelica.ide.editor;

import java.util.ArrayList;

import mock.MockFile;

import org.eclipse.core.resources.IFile;
import org.eclipse.core.resources.IProject;
import org.eclipse.core.resources.IResource;
import org.eclipse.core.runtime.CoreException;
import org.eclipse.jface.text.Position;
import org.eclipse.ui.IEditorInput;
import org.eclipse.ui.IFileEditorInput;
import org.eclipse.ui.IURIEditorInput;
import org.jmodelica.ide.IDEConstants;
import org.jmodelica.ide.folding.IFilePosition;
import org.jmodelica.ide.helpers.EclipseUtil;
import org.jmodelica.ide.helpers.Util;

/**
 * File opened in Editor. Wraps different input methods.
 * 
 * @author philip
 * 
 */
public class EditorFile {

	private final IFile file;
	private final String path;

	/**
	 * Create new EditorFile from IEditorInput
	 * 
	 * @param input
	 *            file input
	 */
	public EditorFile(IEditorInput input) {

		if (input instanceof IFileEditorInput) {

			IFileEditorInput i = (IFileEditorInput) input;
			file = i.getFile();
			path = file.getLocation().toOSString();

		} else if (input instanceof IURIEditorInput) {

			IURIEditorInput i = (IURIEditorInput) input;

			path = i.getURI().getPath();
			file = EclipseUtil.getFileForPath(path).value();

		} else {
			throw new IllegalArgumentException();
		}
	}

	/**
	 * Returns true if file is located in the workspace
	 * 
	 * @return true if file is located in the workspace
	 */
	public boolean inWorkspace() {
		return file != null;
	}

	protected boolean nullFile(IFile f) {
		return f == null || f instanceof MockFile;
	}

	/**
	 * Returns true if file is located in the library
	 * 
	 * @return true if file is located in the library
	 */
	public boolean inLibrary() {
		return path != null && (nullFile(file) || Util.isInLibrary(file));
	}
	
	/**
	 * Returns true if file is in a project with a Modelica nature
	 */
	public boolean inModelicaProject() {
		if (file != null) {
			try {
				IProject project = file.getProject();
				return project != null && project.hasNature(IDEConstants.NATURE_ID);
			} catch (CoreException e) {
			}
		}
		return false;
	}
	
	/**
	 * Returns path of all files in root of the project this file belongs to.
	 * 
	 * If this file does not belong to a Modelica project, only the path of this file is returned.
	 */
	public String[] getPaths() {
		if (inModelicaProject()) {
			try {
				ArrayList<String> paths = new ArrayList<String>();
				for (IResource res : file.getProject().members())
					if (res.getType() == IResource.FILE && res.getName().endsWith(".mo"))
						paths.add(res.getRawLocation().toOSString());
				return paths.toArray(new String[paths.size()]);
			} catch (CoreException e) {
			}
		}
		return new String[] { path };
	}

	/**
	 * Returns path of file
	 * 
	 * @return path of file
	 */
	public String path() {
		return path;
	}

	/**
	 * Returns file resource of file
	 * 
	 * @return file resource of file
	 */
	public IFile iFile() {
		return file;
	}

	/**
	 * Returns true if file contains folding position in <code> pos </code>
	 * 
	 * @param pos
	 *            folding position
	 * @return true if file contains folding position in <code> pos </code>
	 */
	public boolean containsFoldingPosition(Position pos) {
		return inLibrary() || ((IFilePosition) pos).getFileName().equals(path);
	}

	/**
	 * Returns a representation of this file that can be used as a key in the
	 * ASTRegistry
	 * 
	 * @return key representation
	 */
	public String toRegistryKey() {
		return inLibrary() ? (!nullFile(file) ? Util.getLibraryPath(file) : path) : file
				.getRawLocation().toOSString();
	}

	/**
	 * Returns the name of the directory containing the file.
	 */
	public String getDirName() {
		if (file != null)
			return file.getParent().getName();
		String[] parts = path.split("[\\/]");
		return parts[parts.length - 2];
	}

}
