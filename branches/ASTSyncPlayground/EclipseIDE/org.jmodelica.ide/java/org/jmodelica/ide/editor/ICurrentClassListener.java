package org.jmodelica.ide.editor;

import org.jmodelica.ide.outline.cache.CachedClassDecl;

public interface ICurrentClassListener {

	//void setCurrentClass(BaseClassDecl selected);
	void setCurrentClass(CachedClassDecl selected);

}
