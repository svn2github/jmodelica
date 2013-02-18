package org.jmodelica.ide.compiler;

import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;

import org.eclipse.core.resources.IFile;
import org.eclipse.core.resources.IProject;
import org.jastadd.ed.core.model.node.IASTNode;
import org.jastadd.ed.core.model.node.IGlobalRootNode;
import org.jastadd.ed.core.model.node.ILocalRootNode;
import org.jmodelica.modelica.compiler.SourceRoot;
import org.jmodelica.modelica.compiler.StoredDefinition;

public class GlobalRootNode implements IGlobalRootNode {
	private ILocalRootNode[] files;;
	private SourceRoot sourceRoot;

	public GlobalRootNode(SourceRoot sroot) {
		this.sourceRoot = sroot;
	}

	public SourceRoot getSourceRoot() {
		return sourceRoot;
	}

	@Override
	public List<ILocalRootNode> lookupFileNode(IFile file) {
		ArrayList newList = new ArrayList<ILocalRootNode>();
		for (ILocalRootNode node : this.files) {
			newList.add(node);
		}
		return newList;
	}

	@Override
	public ILocalRootNode[] lookupAllFileNodes() {
		return files;
	}

	@Override
	public void addFileNode(ILocalRootNode newNode) {
		// TODO Auto-generated method stub

	}

	public void addFiles(
			org.jmodelica.modelica.compiler.List<StoredDefinition> files) {
		this.files = new ILocalRootNode[files.length()];
		Iterator<StoredDefinition> itr = files.iterator();
		int count = 0;
		while (itr.hasNext()) {
			LocalRootNode fileNode = new LocalRootNode(sourceRoot, itr.next());
			this.files[count] = fileNode;
			count++;
		}
	}

	@Override
	public IASTNode getChild(int i) {
		// TODO Auto-generated method stub
		return null;
	}

	@Override
	public int getNumChild() {
		// TODO Auto-generated method stub
		return 0;
	}

	@Override
	public IASTNode getParent() {
		// TODO Auto-generated method stub
		return null;
	}

	@Override
	public IProject getProject() {
		// TODO Auto-generated method stub
		return null;
	}
}
