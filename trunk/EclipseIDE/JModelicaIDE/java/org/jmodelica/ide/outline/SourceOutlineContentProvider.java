package org.jmodelica.ide.outline;

import java.util.ArrayList;

import org.eclipse.jface.viewers.ITreeContentProvider;
import org.eclipse.jface.viewers.Viewer;
import org.jastadd.plugin.compiler.ast.IOutlineNode;
import org.jmodelica.modelica.compiler.ASTNode;
import org.jmodelica.modelica.compiler.ClassDecl;
import org.jmodelica.modelica.compiler.StoredDefinition;

public class SourceOutlineContentProvider implements ITreeContentProvider {

	public Object[] getChildren(Object element) {
		if (element instanceof StoredDefinition) {
			return getVisible(((StoredDefinition) element).getElements());
		} else if (element instanceof ClassDecl) {
			ClassDecl decl = (ClassDecl) element;
			ArrayList list = new ArrayList();
			list.addAll(decl.classes());
			list.addAll(decl.components());
			return getVisible(list);
		}
		return null;
	}

	private Object[] getVisible(Iterable elements) {
		ArrayList<Object> list = new ArrayList<Object>();
		for (Object e : elements) {
			if (e instanceof IOutlineNode && ((IOutlineNode) e).showInContentOutline())
				list.add(e);
		}
		return list.toArray();
	}

	public Object getParent(Object element) {
		if (element instanceof ASTNode) {
			ASTNode node = ((ASTNode) element).getParent();
			while (!node.showInContentOutline() && !(node instanceof StoredDefinition))
				node = node.getParent();
			return node;
		}
		return null;
	}

	public boolean hasChildren(Object element) {
		if (element instanceof StoredDefinition) {
			return hasVisible(((StoredDefinition) element).getElements());
		} else if (element instanceof ClassDecl) {
			ClassDecl decl = (ClassDecl) element;
			return hasVisible(decl.classes()) || hasVisible(decl.components());
		}
		return false;
	}

	private boolean hasVisible(Iterable elements) {
		for (Object e : elements) 
			if (e instanceof IOutlineNode && ((IOutlineNode) e).showInContentOutline())
				return true;
		return false;
	}

	public Object[] getElements(Object element) {
		return getChildren(element);
	}

	public void dispose() {
	}

	public void inputChanged(Viewer viewer, Object oldInput, Object newInput) {
	}

}
