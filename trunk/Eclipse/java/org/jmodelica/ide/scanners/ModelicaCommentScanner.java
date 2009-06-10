package org.jmodelica.ide.scanners;

import org.eclipse.jface.text.rules.IToken;

public class ModelicaCommentScanner extends StupidScanner {

	@Override
	protected IToken getToken() {
		return COMMENT;
	}

}
