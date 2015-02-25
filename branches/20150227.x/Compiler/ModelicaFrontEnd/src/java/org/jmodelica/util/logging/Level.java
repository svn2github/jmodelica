package org.jmodelica.util.logging;

import org.jmodelica.util.Problem.Severity;


public enum Level {
	ERROR,
	WARNING,
	INFO,
	DEBUG;
	
	public Level union(Level other) {
		if (this.compareTo(other) > 0)
			return this;
		else
			return other;
	}
	
	public boolean shouldLog(Level other) {
		return this.compareTo(other) >= 0;
	}
	
	public static Level fromKind(Severity severity) {
		switch (severity) {
		case ERROR:
			return ERROR;
		case WARNING:
			return WARNING;
		}
		return ERROR; // Should never happen
	}
}
