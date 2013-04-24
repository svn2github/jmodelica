package org.jmodelica.ide.graphical;

import java.io.File;

import org.eclipse.core.resources.IFile;
import org.eclipse.core.resources.IProject;
import org.eclipse.core.resources.ResourcesPlugin;
import org.eclipse.jface.resource.ImageDescriptor;
import org.eclipse.ui.IEditorInput;
import org.eclipse.ui.IMemento;
import org.eclipse.ui.IPersistableElement;
import org.jmodelica.ide.helpers.CachedClassDecl;

public class GraphicalEditorInput implements IEditorInput, IPersistableElement {

	private static final boolean DEFAULT_EDIT_ICON = false;

	private String className;
	private IProject project;
	private boolean editIcon;

	private String sourceFileName;

	public GraphicalEditorInput(String className, IProject project) {
		this(className, project, DEFAULT_EDIT_ICON);
	}

	public GraphicalEditorInput(String className, IProject project,
			boolean editIcon) {
		this.className = className;
		this.project = project;
		this.editIcon = editIcon;
	}

	public GraphicalEditorInput(String className, File sourceFile) {
		this(className, sourceFile, DEFAULT_EDIT_ICON);
	}

	public GraphicalEditorInput(String className, File sourceFile,
			boolean editIcon) {
		this(className, lookupIProject(sourceFile), editIcon);
		this.sourceFileName = sourceFile.getName();
	}

	public GraphicalEditorInput(CachedClassDecl classDecl) {
		this(classDecl, DEFAULT_EDIT_ICON);
	}

	public GraphicalEditorInput(CachedClassDecl classDecl, boolean editIcon) {
		this(classDecl.name(), new File(classDecl.containingFileName()),
				editIcon);
	}

	public String getClassName() {
		return className;
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
