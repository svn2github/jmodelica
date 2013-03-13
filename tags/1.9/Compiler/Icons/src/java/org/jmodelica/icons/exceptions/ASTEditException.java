package org.jmodelica.icons.exceptions;

/**
 * An exception that is thrown when inserting/removing/altering an AST node.
 */
@SuppressWarnings("serial")
public class ASTEditException extends RuntimeException {

	public ASTEditException() {
		super();
	}

	public ASTEditException(String s) {
		super(s);
	}

}
