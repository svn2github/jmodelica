package org.jmodelica.ide.scanners;

import org.eclipse.jface.text.rules.IToken;

public class ModelicaQIdentScanner extends StupidScanner {

	@Override
	protected IToken getToken() {
		return NORMAL;
	}

}
