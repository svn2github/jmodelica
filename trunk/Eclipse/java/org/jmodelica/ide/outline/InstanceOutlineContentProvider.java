package org.jmodelica.ide.outline;

import java.util.ArrayList;

import org.jastadd.plugin.ui.view.JastAddContentProvider;
import org.jmodelica.ast.ClassDecl;
import org.jmodelica.ast.Element;
import org.jmodelica.ast.InstClassDecl;
import org.jmodelica.ast.InstProgramRoot;
import org.jmodelica.ast.Program;
import org.jmodelica.ast.SourceRoot;
import org.jmodelica.ast.StoredDefinition;

public class InstanceOutlineContentProvider extends JastAddContentProvider {

	@Override
	public Object[] getElements(Object element) {
		if (element instanceof StoredDefinition) {
			try {
				StoredDefinition def = (StoredDefinition) element;
				Program program = ((SourceRoot) def.root()).getProgram();
				ArrayList<ClassDecl> classes = new ArrayList<ClassDecl>();
				for (Element e : def.getElements()) 
					classes.add((ClassDecl) e);
				ArrayList<InstClassDecl> instClasses = program.getInstProgramRoot().instClassDecls();
				ArrayList<InstClassDecl> list = new ArrayList<InstClassDecl>();
				for (InstClassDecl inst : instClasses) {
					if (classes.contains(inst.getClassDecl()))
						list.add(inst);
				}
				return list.toArray();
			} catch (Exception e) {
				return new Object[0];
			}
		}
		return super.getElements(element);
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
