package org.jmodelica.ide.helpers;

import org.jmodelica.ide.outline.cache.CachedClassDecl;

public interface ICurrentClassListener {

	//void setCurrentClass(BaseClassDecl selected);
	void setCurrentClass(CachedClassDecl selected);

}
