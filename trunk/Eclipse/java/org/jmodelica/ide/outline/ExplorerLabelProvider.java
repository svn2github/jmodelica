package org.jmodelica.ide.outline;

import org.eclipse.swt.graphics.Image;
import org.jastadd.plugin.ui.view.JastAddLabelProvider;
import org.jmodelica.ide.outline.ExplorerContentProvider.LibrariesList;
import org.jmodelica.ide.ui.ImageLoader;

public class ExplorerLabelProvider extends JastAddLabelProvider {

	@Override
	public Image getImage(Object element) {
		if (element instanceof LibrariesList)
			return ImageLoader.getImage(ImageLoader.LIBRARY_IMAGE);
		return super.getImage(element);
	}

}
