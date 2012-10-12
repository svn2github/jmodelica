package org.jmodelica.ide.graphical.util;

import org.jmodelica.icons.Component;
import org.jmodelica.icons.Diagram;
import org.jmodelica.modelica.compiler.InstComponentDecl;
import org.jmodelica.modelica.compiler.InstNode;

/**
 * Base class for retrieving information about the model that is open in the
 * editor.
 * 
 * @author jsten
 * 
 */
public abstract class ASTResourceProvider {

	/**
	 * Retrieves the component with the name <code>componentName</code>. If it
	 * is not found null will be returned.
	 * 
	 * @param componentName Name of the component to find
	 * @return the component
	 */
	public Component getComponentByName(String componentName) {
		InstComponentDecl icd = getInstComponentDeclByName(componentName);
		if (icd != null)
			return icd.getComponent();
		else
			return null;
	}

	/**
	 * Returns the current diagram object.
	 * 
	 * @return diagram object
	 */
	public Diagram getDiagram() {
		return getRoot().diagram();
	}

	/**
	 * Retrieves the component declaration with the name
	 * <code>componentName</code>. If it is not found null will be returned.
	 * 
	 * @param componentName name of the component to look for
	 * @return the component declaration
	 */
	public InstComponentDecl getInstComponentDeclByName(String componentName) {
		for (Object o : getRoot().memberInstComponent(componentName)) {
			if (o instanceof InstComponentDecl)
				return (InstComponentDecl) o;
		}
		System.err.println("SubComponentASTResourceProvider.getInstComponentDeclByName(): Unable to find component \"" + componentName + "\"");
		return null;
	}

	/**
	 * Internal method for retrieving the node that is currently shown in the
	 * editor.
	 * 
	 * @return the node
	 */
	protected abstract InstNode getRoot();

}
