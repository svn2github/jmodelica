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
package org.jmodelica.ide.ui;

import java.net.URL;
import java.util.HashMap;

import org.eclipse.core.runtime.FileLocator;
import org.eclipse.core.runtime.IPath;
import org.eclipse.core.runtime.Path;
import org.eclipse.jface.resource.ImageDescriptor;
import org.eclipse.jface.resource.ImageRegistry;
import org.eclipse.swt.graphics.Image;
import org.jmodelica.ide.Activator;

public class ImageLoader {
	
	public final static IPath ICONS_PATH = new Path("icons");

	
	// Add a key and a image descriptor for each image
	
	public final static String DUMMY_IMAGE = "dummy.png";
	public final static ImageDescriptor DUMMY_DESC = createImageDescriptor(DUMMY_IMAGE);
	public final static String ERROR_CHECK_IMAGE = "buttons/error_check.png";
	public final static ImageDescriptor ERROR_CHECK_DESC = createImageDescriptor(ERROR_CHECK_IMAGE);
	public final static String ERROR_CHECK_DIS_IMAGE = "buttons/error_check_dis.png";
	public final static ImageDescriptor ERROR_CHECK_DIS_DESC = createImageDescriptor(ERROR_CHECK_DIS_IMAGE);
	public final static String ANNOTATION_IMAGE = "buttons/annotation.png";
	public final static ImageDescriptor ANNOTATION_DESC = createImageDescriptor(ANNOTATION_IMAGE);
	public final static String ANNOTATION_DIS_IMAGE = "buttons/annotation_dis.png";
	public final static ImageDescriptor ANNOTATION_DIS_DESC = createImageDescriptor(ANNOTATION_DIS_IMAGE);
	public final static String LIBRARY_IMAGE = "outline/library.png";
	public final static ImageDescriptor LIBRARY_DESC = createImageDescriptor(LIBRARY_IMAGE);
	public final static String COMPONENT_IMAGE = "outline/component_generic.png";
	public final static ImageDescriptor COMPONENT_DESC = createImageDescriptor(COMPONENT_IMAGE);
	
	public final static String BLOCK_CLASS = "block";
	public final static String CLASS_CLASS = "class";
	public final static String CONNECTOR_CLASS = "connector";
	public final static String FUNCTION_CLASS = "function";
	public final static String MODEL_CLASS = "model";
	public final static String PACKAGE_CLASS = "package";
	public final static String RECORD_CLASS = "record";
	public final static String TYPE_CLASS = "type";
	
	private final static String[] CLASS_ICONS = { 
		BLOCK_CLASS, CLASS_CLASS, CONNECTOR_CLASS, FUNCTION_CLASS, MODEL_CLASS, PACKAGE_CLASS, RECORD_CLASS, TYPE_CLASS 
		};
	private final static String[] CLASS_COMPS = { 
		BLOCK_CLASS, CLASS_CLASS, CONNECTOR_CLASS, MODEL_CLASS, RECORD_CLASS, TYPE_CLASS
		};
	
	private static HashMap<String, ImageDescriptor> descriptorMap;
	
	static {
		// Load frequent images into the image registry
		ImageRegistry reg = Activator.getDefault().getImageRegistry();
		reg.put(DUMMY_IMAGE, DUMMY_DESC);
		reg.put(COMPONENT_IMAGE, COMPONENT_DESC);
		
		for (String c : CLASS_ICONS) {
			String name = makeClassIconPath(c, false, false);
			reg.put(name, createImageDescriptor(name));
			name = makeClassIconPath(c, false, true);
			reg.put(name, createImageDescriptor(name));
		}
		for (String c : CLASS_COMPS) {
			String name = makeClassIconPath(c, true, false);
			reg.put(name, createImageDescriptor(name));
			name = makeClassIconPath(c, true, true);
			reg.put(name, createImageDescriptor(name));
		}
	}
	
	
	/**
	 * Looks up images descriptors in the local table in this class
	 * and creates an image.
	 * @param imageId The image id
	 * @return An image or null if none was found
	 */
	public static Image getImage(String imageId) {	
		ImageDescriptor imageDesc = null;	
		if (!descriptorMap.containsKey(imageId)) {
			// Couldn't find images in local table
			return null;
		}
		imageDesc = descriptorMap.get(imageId);
		return imageDesc.createImage();
	}
	
	/**
	 * Looks up frequent images in the ImageRegistry provided by the plug-in activator.
	 * Frequent images need to be added to the registry at start up. For image id's,
	 * defined in this class, this is handled in a static block in this class.
	 * If no image was found in the registry this method will look in the local
	 * table in this class.
	 * @param imageId The image id
	 * @return An image or null if none could be found
	 */
	public static Image getFrequentImage(String imageId) {
		ImageRegistry imageRegistry = Activator.getDefault().getImageRegistry();
		Image image = imageRegistry.get(imageId);
		if (image == null) {
			// Maybe this wasn't a frequent image. Looking in the local table as well
			return getImage(imageId);
		}
		return image;
	}
	
	/**
	 * Creates an image descriptor and puts it in the image descriptor map
	 * @param componentImage The image path in relation to ICONS_PATH
	 * @return An image descriptor
	 */
	private static ImageDescriptor createImageDescriptor(String componentImage) {
		if (descriptorMap == null) {
			descriptorMap = new HashMap<String, ImageDescriptor>();
		}
		ImageDescriptor desc = null;
		IPath path = ICONS_PATH.append(componentImage);
		URL url = FileLocator.find(Activator.getDefault().getBundle(), path, null);
		// Returns missing image descriptor if url is null
		desc = ImageDescriptor.createFromURL(url);
		descriptorMap.put(componentImage, desc);
		return desc;
	}
	
	public static Image getClassImage(String cl, boolean comp, boolean inst) {
		if (cl == null)
			return null;
		return getFrequentImage(makeClassIconPath(cl, comp, inst));
	}

	private static String makeClassIconPath(String cl, boolean comp, boolean inst) {
		StringBuilder name = new StringBuilder("outline/");
		name.append(comp ? "use/" : "def/");
		name.append(inst ? "inst/" : "src/");
		name.append(cl);
		name.append(".png");
		return name.toString();
	}
}