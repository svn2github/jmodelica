package org.jastadd.ed.core;

import org.eclipse.core.resources.IFile;
import org.eclipse.core.resources.IProject;
import org.eclipse.jface.text.IDocument;
import org.jastadd.ed.core.model.node.IGlobalRootNode;
import org.jastadd.ed.core.model.node.ILocalRootNode;

public interface ICompiler {

	public boolean canCompile(IProject project);
	public IGlobalRootNode compile(IProject project);
	public ILocalRootNode compile(IFile file, IDocument document);
	public boolean canCompile(IFile file);
	public ILocalRootNode compile(IFile file);
}
