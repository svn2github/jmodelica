package org.jmodelica.ide.graphical.util;

import org.jmodelica.icons.Component;
import org.jmodelica.icons.Diagram;

public interface ASTResourceProvider {

	/**
	 * Retrieves the component with the name <code>componentName</code>. If it
	 * is not found null will be returned.
	 * 
	 * @param componentName Name of the component to find
	 * @return the component
	 */
	public Component getComponentByName(String componentName);

	/**
	 * Returns the current diagram object
	 * 
	 * @return diagram object
	 */
	public Diagram getDiagram();

}
