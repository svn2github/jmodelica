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

import org.jastadd.ed.core.service.view.JastAddContentProvider;
import org.jmodelica.modelica.compiler.ASTNode;
import org.jmodelica.modelica.compiler.InstClassDecl;
import org.jmodelica.modelica.compiler.InstProgramRoot;
import org.jmodelica.modelica.compiler.SourceRoot;
import org.jmodelica.modelica.compiler.StoredDefinition;

public class InstanceOutlineContentProvider extends JastAddContentProvider {

	@Override
	public Object[] getElements(Object element) {

		if (!(element instanceof StoredDefinition))
			return super.getElements(element);

		try {
			System.out.println("INSTANCEOUTLINECONTENTPROVIDER getElements()");
			StoredDefinition def = (StoredDefinition) element;
			InstProgramRoot iRoot = ((SourceRoot) (def.root())).getProgram()
					.getInstProgramRoot();
			ArrayList<?> classes = def.getElements().toArrayList();

			ArrayList<InstClassDecl> result = new ArrayList<InstClassDecl>();

			for (InstClassDecl inst : iRoot.instClassDecls()) {
				if (classes.contains(inst.getClassDecl()))
					result.add(inst);
				System.out.println("OUTLINE inst class: " + inst.getNodeName()
						+ " " + inst.outlineId());
				// printTree(inst, "");
				// System.out.println("DUMP instclass: ");
				if (inst.outlineId().equals("ModelB")) {
					//result.add(inst.getClassDecl().newInstReplacingClass(
						//	inst.getClassDecl(), inst));
				} else if (inst.outlineId().equals("ModelA")) {

				}
			}
			return result.toArray();

		} catch (Exception e) {
			e.printStackTrace();
			return new Object[0];
		}
	}

	//DEBUG TODO remove
	private void printTree(ASTNode<?> node, String indent) {
		System.out.println("%% " + node.getNodeName() + " " + node.outlineId());
		for (int i = 0; i < node.getNumChild(); i++)
			printTree(node.getChild(i), " " + indent);
	}

	@Override
	public Object getParent(Object element) {

		boolean parentIsInstRoot = super.getParent(element) instanceof InstProgramRoot;

		return parentIsInstRoot ? ((InstClassDecl) element).getClassDecl()
				.getParent() : super.getParent(element);
	}

}
