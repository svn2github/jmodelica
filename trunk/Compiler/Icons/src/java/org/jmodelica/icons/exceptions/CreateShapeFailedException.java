package org.jmodelica.icons.exceptions;

/* exception used if a FilledShape fails when it is created */

public class CreateShapeFailedException extends FailedConstructionException {
	
	public CreateShapeFailedException(String primitiveType) {
		super(primitiveType);
	}
	
	public String getMessage() {
		return "Failed to create a Shape for primitive of type " + type + ".";
	}
}