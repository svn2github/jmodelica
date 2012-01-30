package org.jmodelica.icons.exceptions;

/**
 * Thrown when creating a primitive and not enough parameters are given, 
 * eg. when no points are assigned to a MLSLine primitive.
 * @author P408-NADS
 *
 */
@SuppressWarnings("serial")
public class NotEnoughParametersException extends FailedConstructionException {

	public NotEnoughParametersException() {
		
	}
	
	public NotEnoughParametersException(String primitiveType) {
		super(primitiveType);
	}	
		
	public String getMessage() {
		return "Not enough parameters to create " + type + " primitive.";
	}
}