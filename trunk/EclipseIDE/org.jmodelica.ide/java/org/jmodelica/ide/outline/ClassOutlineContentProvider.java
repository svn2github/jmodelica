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

import java.util.ArrayList;

import org.eclipse.core.resources.IProject;
import org.eclipse.jface.viewers.StructuredViewer;
import org.eclipse.jface.viewers.TreeViewer;
import org.jastadd.plugin.registry.IASTRegistryListener;
import org.jastadd.plugin.ui.view.JastAddContentProvider;
import org.jmodelica.modelica.compiler.ASTNode;
import org.jmodelica.modelica.compiler.Element;
import org.jmodelica.modelica.compiler.InstClassDecl;
import org.jmodelica.modelica.compiler.InstProgramRoot;
import org.jmodelica.modelica.compiler.List;
import org.jmodelica.modelica.compiler.SourceRoot;
import org.jmodelica.modelica.compiler.StoredDefinition;


public class ClassOutlineContentProvider extends OutlineAwareContentProvider {

	public ClassOutlineContentProvider() {
		super(OutlinePage.JASTADD_CONTENT);
	}

	public Object getParent(Object element) {
		if (element instanceof ASTNode) {
			LibrariesList libs = ((ASTNode) element).getLibrariesList();
			if (libs != null)
				return libs;
		}
		return super.getParent(element);
	}

}
