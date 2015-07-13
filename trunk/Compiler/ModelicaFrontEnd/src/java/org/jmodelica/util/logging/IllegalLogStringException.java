package org.jmodelica.util.logging;

import org.jmodelica.util.exceptions.ModelicaException;

@SuppressWarnings("serial")
public class IllegalLogStringException extends ModelicaException {
	
	private final ModelicaLogger logger;
	
	public IllegalLogStringException(String message, ModelicaLogger logger) {
		super(message);
		this.logger = logger;
	}
	
	public ModelicaLogger getLogger() {
		return logger;
	}

}
