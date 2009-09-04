/*
    Copyright (C) 2009 Modelon AB

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, version 3 of the License.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/
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
