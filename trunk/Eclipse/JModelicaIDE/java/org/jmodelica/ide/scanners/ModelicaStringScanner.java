package org.jmodelica.ide.scanners;

import org.eclipse.jface.text.rules.IToken;

public class ModelicaStringScanner extends StupidScanner {

	@Override
	protected IToken getToken() {
		return STRING;
	}

}
