/*
    Copyright (C) 2009 Modelon AB

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, version 3 of the License.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/
package org.jmodelica.ide.outline;

import org.eclipse.jface.viewers.Viewer;
import org.eclipse.jface.viewers.ViewerSorter;
import org.jmodelica.modelica.compiler.ASTNode;
import org.jmodelica.modelica.compiler.BaseClassDecl;
import org.jmodelica.modelica.compiler.InstClassDecl;

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