package org.jmodelica.ide.helpers.hooks;

import org.jmodelica.modelica.compiler.ClassDecl;

public interface IASTEditor {

	public ClassDecl getClassContainingCursor();
	public ClassDecl getClassContainingMouse();
	public ClassDecl getClassContaining(int offset, int length);
	
}
