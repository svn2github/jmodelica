package org.jmodelica.util.exceptions;

/**
 * Exception to be thrown when the Modelica class to instantiate is not
 * found.
 */
public class ModelicaClassNotFoundException extends ModelicaException {
    private static final long serialVersionUID = 1;
	private String className;

	public ModelicaClassNotFoundException(String className) {
		super("Class " + className + " not found");
		this.className = className;
	}

	public String getClassName() {
		return className;
	}

}
