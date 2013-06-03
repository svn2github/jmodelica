package org.jmodelica.ide.documentation;

import java.io.File;
import java.util.Stack;

import org.eclipse.core.resources.IFile;
import org.eclipse.core.resources.IProject;
import org.eclipse.core.resources.ResourcesPlugin;
import org.eclipse.jface.resource.ImageDescriptor;
import org.eclipse.ui.IEditorInput;
import org.eclipse.ui.IMemento;
import org.eclipse.ui.IPersistableElement;
import org.jastadd.ed.core.model.IASTPathPart;

public class DocumentationEditorInput implements IEditorInput,
		IPersistableElement {
	private IProject project;
	private String filePath;
	private Stack<IASTPathPart> classASTPath;
	private boolean genDoc;
	private IFile file;

	public DocumentationEditorInput(String filePath,
			Stack<IASTPathPart> classASTPath, boolean genDoc) {
		this.genDoc = genDoc;
		this.filePath = filePath;
		this.classASTPath = classASTPath;
		file = getFileFromPath(filePath);
		project = file.getProject();
	}

	public DocumentationEditorInput(String filePath,
			Stack<IASTPathPart> classASTPath, IProject iProject) {
		this.filePath = filePath;
		this.classASTPath = classASTPath;
		file = getFileFromPath(filePath);
		project = iProject;
	}

	public Stack<IASTPathPart> getClassASTPath() {
		return classASTPath;
	}

	public String getFilePath() {
		return filePath;
	}

	public IFile getFile() {
		return file;
	}

	public IProject getProject() {
		return project;
	}

	public boolean getGenDoc() {
		return genDoc;
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
		return classASTPath.get(0).id().split(":")[1];
	}

	@Override
	public IPersistableElement getPersistable() {
		return this;
	}

	@Override
	public String getToolTipText() {
		return project.getFullPath() + ":" + getName();
	}

	@Override
	public void saveState(IMemento memento) {
		DocumentationEditorInputFactory.save(memento, this);
	}

	@Override
	public String getFactoryId() {
		return DocumentationEditorInputFactory.ID_FACTORY;
	}

	public IFile getFileFromPath(String filePath2) {
		IFile[] files = ResourcesPlugin.getWorkspace().getRoot()
				.findFilesForLocationURI((new File(filePath2)).toURI());
		for (IFile file : files)
			return file;
		return null;
	}
}