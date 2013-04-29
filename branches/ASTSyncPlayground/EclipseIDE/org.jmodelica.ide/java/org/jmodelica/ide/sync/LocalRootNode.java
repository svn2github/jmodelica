package org.jmodelica.ide.sync;

import org.eclipse.core.resources.IFile;
import org.jastadd.ed.core.model.node.IASTNode;
import org.jastadd.ed.core.model.node.ILocalRootNode;
import org.jmodelica.modelica.compiler.StoredDefinition;

public class LocalRootNode implements ILocalRootNode {
	private StoredDefinition def;

	public LocalRootNode(StoredDefinition def) {
		this.def = def;
	}

	@Override
	public boolean correspondsTo(ILocalRootNode node) {
		return getFile().equals(node.getFile()); // TODO works?
	}

	@Override
	public void discardFromTree() {
		// TODO Auto-generated method stub

	}

	@Override
	public boolean shouldBeUpdatedWith(ILocalRootNode newNode) {
		return false;
	}

	@Override
	public void updateWith(ILocalRootNode newNode) {
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
	public void setFile(IFile file) {
		// TODO Auto-generated method stub
	}

	public StoredDefinition getDef() {
		return def;
	}

	@Override
	public IFile getFile() {
		return def.getFile();
	}
}
