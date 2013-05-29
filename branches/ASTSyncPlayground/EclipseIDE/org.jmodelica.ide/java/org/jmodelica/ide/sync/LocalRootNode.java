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
		return getFile().equals(node.getFile());
	}

	@Override
	public void discardFromTree() {
		System.err
				.println("LocalRootNode->discardFromTree() should never be called.");
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
		System.err.println("LocalRootNode->getChild() should never be called.");
		return null;
	}

	@Override
	public int getNumChild() {
		System.err
				.println("LocalRootNode->getNumChild() should never be called.");
		return 0;
	}

	@Override
	public IASTNode getParent() {
		System.err
				.println("LocalRootNode->getParent() should never be called.");
		return null;
	}

	@Override
	public void setFile(IFile file) {
		System.err.println("LocalRootNode->setFile() should never be called.");
	}

	public StoredDefinition getDef() {
		return def;
	}

	@Override
	public IFile getFile() {
		return def.getFile();
	}
}