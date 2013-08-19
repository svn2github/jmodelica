package org.jmodelica.util;

import org.jmodelica.util.logging.ModelicaLogger;

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
