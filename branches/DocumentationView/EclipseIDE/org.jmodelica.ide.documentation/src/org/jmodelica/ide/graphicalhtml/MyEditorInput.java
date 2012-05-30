package org.jmodelica.ide.graphicalhtml;

import java.io.File;

import org.eclipse.core.resources.IFile;
import org.eclipse.core.resources.IProject;
import org.eclipse.core.resources.ResourcesPlugin;
import org.eclipse.jface.resource.ImageDescriptor;
import org.eclipse.jface.util.Util;
import org.eclipse.ui.IEditorInput;
import org.eclipse.ui.IMemento;
import org.eclipse.ui.IPersistableElement;
import org.jastadd.plugin.Activator;
import org.jmodelica.modelica.compiler.ASTNode;
import org.jmodelica.modelica.compiler.ClassDecl;
import org.jmodelica.modelica.compiler.FullClassDecl;
import org.jmodelica.modelica.compiler.Program;
import org.jmodelica.modelica.compiler.SourceRoot;
import org.jmodelica.modelica.compiler.VisibilityType;

public class MyEditorInput implements IEditorInput, IPersistableElement{

	private String className;
	private IProject project;
	private FullClassDecl fullClassDecl;

	public MyEditorInput(FullClassDecl fullClassDecl){
		VisibilityType vt = fullClassDecl.getVisibilityType();
//		ASTNode parent = fullClassDecl.getParent();
//		
//		if (parent instanceof FullClassDecl){
//			if (((FullClassDecl) parent).getRestriction().getNodeName().equals("MPackage")){
//				
//			}
//		}
		className = fullClassDecl.name();
		project = lookupIProject(new File(fullClassDecl.containingFileName()));
		this.fullClassDecl = fullClassDecl;
	}
	
	public MyEditorInput(String name, IProject iProject) {
		className = name;
		project = iProject;
		Program program = ((SourceRoot) Activator.getASTRegistry().lookupAST(null, project)).getProgram();
		ClassDecl cd = program.simpleLookupClassDefaultScope(className);
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
	
	@Override
	public Object getAdapter(@SuppressWarnings("rawtypes") Class adapter) {
		// TODO Auto-generated method stub
		return null;
	}

	@Override
	public boolean exists() {
		// TODO Auto-generated method stub
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
		MyEditorInputFactory.save(memento, this);
	}

	@Override
	public String getFactoryId() {
		return MyEditorInputFactory.ID_FACTORY;
	}

}
