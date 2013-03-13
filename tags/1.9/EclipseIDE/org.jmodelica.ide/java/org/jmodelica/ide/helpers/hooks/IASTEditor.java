package org.jmodelica.ide.helpers.hooks;

import org.jmodelica.modelica.compiler.ClassDecl;

public interface IASTEditor {

	public ClassDecl getClassContainingCursor();
	
}
