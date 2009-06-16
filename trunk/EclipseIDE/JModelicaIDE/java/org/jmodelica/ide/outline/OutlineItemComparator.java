/**
 * 
 */
package org.jmodelica.ide.outline;

import org.eclipse.jface.viewers.Viewer;
import org.eclipse.jface.viewers.ViewerSorter;
import org.jmodelica.ast.ASTNode;
import org.jmodelica.ast.BaseClassDecl;
import org.jmodelica.ast.InstClassDecl;

public class OutlineItemComparator extends ViewerSorter {
	@Override
	public int category(Object element) {
		if (element instanceof ASTNode)
			return ((ASTNode) element).outlineCategory();
		if (element instanceof ExplorerContentProvider.LibrariesList) 
			return -2;
		return super.category(element);
	}

	@Override
	public int compare(Viewer viewer, Object e1, Object e2) {
		if (e1 instanceof InstClassDecl)
			e1 = ((InstClassDecl) e1).getClassDecl();
		if (e2 instanceof InstClassDecl)
			e2 = ((InstClassDecl) e2).getClassDecl();
		if (e1 instanceof BaseClassDecl && e2 instanceof BaseClassDecl) {
			String id1 = ((BaseClassDecl) e1).getName().getID();
			String id2 = ((BaseClassDecl) e2).getName().getID();
			return getComparator().compare(id1, id2);
		}
		return super.compare(viewer, e1, e2);
	}
}