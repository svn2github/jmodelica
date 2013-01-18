package org.jastadd.ed.core.service.errors;

import java.util.Collection;

public interface IErrorFeedbackNode {

	public Collection<IError> syntaxErrors();
	public Collection<IError> semanticErrors();

}
