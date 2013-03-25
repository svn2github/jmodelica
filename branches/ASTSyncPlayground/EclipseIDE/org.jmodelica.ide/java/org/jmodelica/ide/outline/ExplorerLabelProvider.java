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
import org.eclipse.swt.graphics.ImageData;
import org.jmodelica.ide.outline.cache.CachedLabelProvider;
import org.jmodelica.ide.ui.ImageLoader;

public class ExplorerLabelProvider extends CachedLabelProvider {

	private static final int SIZE = 16;
	private final Image DEFAULT_LARGE = ImageLoader
			.getFrequentImage(ImageLoader.GENERIC_CLASS_IMAGE);
	private final Image DEFAULT_SMALL = ImageLoader
			.getFrequentImage(ImageLoader.GENERIC_CLASS_SMALL_IMAGE);

	public ExplorerLabelProvider() {
		super();
	}

	public Image getImage(Object element) {
		Image image = super.getImage(element);
		if (image == DEFAULT_LARGE) {
			image = DEFAULT_SMALL;
		} else if (image != null && image.getBounds().width != SIZE) {
			// Alternate method that might be faster exists,
			// see
			// http://www.eclipse.org/articles/Article-SWT-images/graphics-resources.html
			ImageData data = image.getImageData().scaledTo(SIZE, SIZE);
			image = new Image(image.getDevice(), data);
		}
		return image;
	}
}
