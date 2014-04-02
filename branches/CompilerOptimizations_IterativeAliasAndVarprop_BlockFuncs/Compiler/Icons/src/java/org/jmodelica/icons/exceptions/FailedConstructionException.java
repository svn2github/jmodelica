package org.jmodelica.icons.exceptions;

/**
 * Thrown when the construction of a component or parameter fails.
 * @author P408-NADS
 *
 */
@SuppressWarnings("serial")
public class FailedConstructionException extends ModelicaIconsException {
	
	String type;
	
	public FailedConstructionException() {
		
	}
	
	public FailedConstructionException(String type) {
		this.type = type;
	}	
	
	public String getPrimitiveType() {
		return type;
	}
	
	public String getMessage() {
		return "Failed to construct " + type + " primitive/parameter.";
	}
}