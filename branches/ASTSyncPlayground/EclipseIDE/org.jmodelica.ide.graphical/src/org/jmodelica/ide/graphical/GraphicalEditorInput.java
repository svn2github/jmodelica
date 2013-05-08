package org.jmodelica.ide.graphical;

import java.io.File;

import org.eclipse.core.resources.IFile;
import org.eclipse.core.resources.IProject;
import org.eclipse.core.resources.ResourcesPlugin;
import org.eclipse.jface.resource.ImageDescriptor;
import org.eclipse.ui.IEditorInput;
import org.eclipse.ui.IMemento;
import org.eclipse.ui.IPersistableElement;
import org.jmodelica.ide.sync.CachedClassDecl;

public class GraphicalEditorInput implements IEditorInput, IPersistableElement {

	private String className;
	private IProject project;
	private boolean editIcon;
	private String sourceFileName;
	private String filePath;

	public GraphicalEditorInput(String className, String filePath,
			boolean editIcon) {
		this.className = className;
		this.project = lookupIProject(new File(filePath));
		this.editIcon = editIcon;
		this.sourceFileName = new File(filePath).getName();
		this.filePath = filePath;
	}

	public GraphicalEditorInput(CachedClassDecl classDecl, boolean editIcon) {
		this(classDecl.name(), classDecl.containingFileName(), editIcon);
	}

	public String getClassName() {
		return className;
	}

	public String getFilePath() {
		return filePath;
	}

	public IProject getProject() {
		return project;
	}

	public boolean editIcon() {
		return editIcon;
	}

	@Override
	public Object getAdapter(@SuppressWarnings("rawtypes") Class adapter) {
		return null;
	}

	@Override
	public boolean exists() {
		return true;
	}

	@Override
	public ImageDescriptor getImageDescriptor() {
		return ImageDescriptor.getMissingImageDescriptor();
	}

	@Override
	public String getName() {
		return className + (editIcon ? " - Icon" : "");
	}

	@Override
	public IPersistableElement getPersistable() {
		return this;
	}

	@Override
	public String getToolTipText() {
		return project.getFullPath() + ":" + getName();
	}

	private static IProject lookupIProject(File file) {
		IFile[] files = ResourcesPlugin.getWorkspace().getRoot()
				.findFilesForLocationURI(file.toURI());

		for (IFile f : files) {
			return f.getProject();
		}

		return null;
	}

	@Override
	public void saveState(IMemento memento) {
		GraphicalEditorInputFactory.save(memento, this);
	}

	@Override
	public String getFactoryId() {
		return GraphicalEditorInputFactory.ID_FACTORY;
	}

	public String getSourceFileName() {
		return sourceFileName;
	}
}