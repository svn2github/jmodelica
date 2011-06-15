package org.jmodelica.ide.error;

import org.eclipse.core.resources.IMarker;
import org.jmodelica.modelica.compiler.ASTNode;

public class InstanceWarning extends InstanceProblem {

	public InstanceWarning(String msg, ASTNode<?> n) {
		super(msg, n);
	}

	public int getSeverity() {
		return IMarker.SEVERITY_WARNING;
	}

	public boolean isError() {
		return false;
	}

	public String getSeverityString() {
		return "String";
	}

}
