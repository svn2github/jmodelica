package org.jmodelica.ide.helpers;

import org.jmodelica.ide.helpers.CachedClassDecl;

public interface ICurrentClassListener {

	//void setCurrentClass(BaseClassDecl selected);
	void setCurrentClass(CachedClassDecl selected);

}
