package org.jmodelica.ide.outline;

import org.jastadd.ed.core.service.view.JastAddContentProvider;
import org.jmodelica.modelica.compiler.ASTNode;

public class ASTContentProvider extends JastAddContentProvider {

	public Object[] getChildren(Object element) {
		if (element instanceof ASTNode)
			return ((ASTNode) element).cachedOutlineChildren();
		else
			return super.getChildren(element);
	}

	public Object[] getElements(Object element) {
		if (element instanceof ASTNode)
			return ((ASTNode) element).cachedOutlineChildren();
		else
			return super.getElements(element);
	}

	public boolean hasChildren(Object element) {
		if (element instanceof ASTNode)
			return ((ASTNode) element).hasVisibleChildren();
		else
			return super.hasChildren(element);
	}

}
