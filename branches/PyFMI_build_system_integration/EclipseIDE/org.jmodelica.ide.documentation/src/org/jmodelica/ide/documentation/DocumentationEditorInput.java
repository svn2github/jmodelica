package org.jmodelica.ide.documentation;

import java.io.File;
import java.util.ArrayList;

import org.eclipse.core.resources.IFile;
import org.eclipse.core.resources.IProject;
import org.eclipse.core.resources.ResourcesPlugin;
import org.eclipse.jface.resource.ImageDescriptor;
import org.eclipse.ui.IEditorInput;
import org.eclipse.ui.IMemento;
import org.eclipse.ui.IPersistableElement;
import org.jastadd.plugin.Activator;
import org.jmodelica.modelica.compiler.BaseClassDecl;
import org.jmodelica.modelica.compiler.FullClassDecl;
import org.jmodelica.modelica.compiler.Program;
import org.jmodelica.modelica.compiler.SourceRoot;

public class DocumentationEditorInput implements IEditorInput, IPersistableElement{

	private String className;
	private IProject project;
	private FullClassDecl fullClassDecl;
	private boolean genDoc;

	public DocumentationEditorInput(FullClassDecl fullClassDecl, boolean genDoc){
		this.genDoc = genDoc;
		ArrayList<String> path = new ArrayList<String>();
		String name = fullClassDecl.name();
		StringBuilder sb = new StringBuilder();
		BaseClassDecl tmp = fullClassDecl;
		do{
			path.add(tmp.name());
			tmp = tmp.enclosingClassDecl();

		}while(tmp != null && !name.equals(tmp.name()));
		for (int i = path.size() - 1; i >= 0; i--){
			sb.append(path.get(i));
			if (i != 0){
				sb.append(".");
			}
		}
		className = sb.toString();
		project = lookupIProject(new File(fullClassDecl.containingFileName()));
		this.fullClassDecl = fullClassDecl;
	}

	public DocumentationEditorInput(String name, IProject iProject) {
		className = name;
		project = iProject;
		Program program = ((SourceRoot) Activator.getASTRegistry().lookupAST(null, project)).getProgram();
		fullClassDecl = (FullClassDecl)(program.simpleLookupClassDotted(className));
	}

	public String getClassName() {
		return className;
	}

	public IProject getProject() {
		return project;
	}

	public FullClassDecl getFullClassDecl(){
		return fullClassDecl;
	}
	
	public boolean getGenDoc(){
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
		return className;
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
		IFile[] files = ResourcesPlugin.getWorkspace().getRoot().findFilesForLocationURI(file.toURI());
		for (IFile f : files) {
			return f.getProject();
		}
		return null;
	}

	@Override
	public void saveState(IMemento memento) {
		DocumentationEditorInputFactory.save(memento, this);
	}

	@Override
	public String getFactoryId() {
		return DocumentationEditorInputFactory.ID_FACTORY;
	}

}
