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

import org.jastadd.plugin.ui.view.JastAddContentProvider;
import org.jmodelica.modelica.compiler.InstClassDecl;
import org.jmodelica.modelica.compiler.InstProgramRoot;
import org.jmodelica.modelica.compiler.SourceRoot;
import org.jmodelica.modelica.compiler.StoredDefinition;

public class InstanceOutlineContentProvider extends JastAddContentProvider {

	@Override
	public Object[] getElements(Object element) {
	
	    if (!(element instanceof StoredDefinition)) 
		    return 
		        super.getElements(element);
		
	    try {
	        
			StoredDefinition def = 
			    (StoredDefinition) element;
			
			SourceRoot root = 
			    (SourceRoot) def.root();
			
			ArrayList<?> classDecls = 
			    root
			    .getProgram()
			    .getInstProgramRoot()
			    .instClassDecls();
			
			return 
			    def
			    .getElements()
			    .retainAll(classDecls)
			    .toArray();
			
		} catch (Exception e) {
			return 
			    new Object[0];
		}
	}

	@Override
	public Object getParent(Object element) {
		Object parent = super.getParent(element);
		if (parent instanceof InstProgramRoot) {
			InstClassDecl icd = (InstClassDecl) element;
			parent = icd.getClassDecl().getParent();
		}
		return parent;
	}

}
