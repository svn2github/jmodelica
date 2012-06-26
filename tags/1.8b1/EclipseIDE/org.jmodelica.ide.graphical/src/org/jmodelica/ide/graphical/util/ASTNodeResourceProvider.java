package org.jmodelica.ide.graphical.util;

/**
 * 
 * Interface used by primitive EditParts for retrieving AST related information.
 * 
 * @author jsten
 * 
 */
public interface ASTNodeResourceProvider {

	/**
	 * Returns the component name of the component.
	 * 
	 * @return component name of the component
	 */
	public String getComponentName();

	/**
	 * Returns the class name of the component.
	 * 
	 * @return class name of the component
	 */
	public String getClassName();

	/**
	 * Returns the value of the parameter with the name <code>parameter</code>.
	 * If it is not found null will be returned.
	 * 
	 * @param parameter name of the parameter to look for
	 * @return value of the parameter.
	 */
	public String getParameterValue(String parameter);

}
