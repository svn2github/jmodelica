package org.jmodelica.util;

/**
 * Exception to be thrown when the Modelica class to instantiate is not
 * found.
 */
@SuppressWarnings("serial")
public class ModelicaClassNotFoundException extends ModelicaException {
	private String className;

	public ModelicaClassNotFoundException(String className) {
		super("Class " + className + " not found");
		this.className = className;
	}

	public String getClassName() {
		return className;
	}

}
