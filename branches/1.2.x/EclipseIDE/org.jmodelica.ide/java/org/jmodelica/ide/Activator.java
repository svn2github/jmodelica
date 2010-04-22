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
package org.jmodelica.ide;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;

import org.eclipse.core.runtime.IPath;
import org.eclipse.jface.preference.IPreferenceStore;
import org.eclipse.ui.plugin.AbstractUIPlugin;
import org.osgi.framework.BundleContext;

/**
 * The activator class controls the plug-in life cycle
 */
public class Activator extends AbstractUIPlugin {

	// The plug-in ID
	public static final String PLUGIN_ID = IDEConstants.PLUGIN_ID;

	// The shared instance
	private static Activator plugin = new Activator();

	/**
	 * The constructor
	 */
	public Activator() {
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see org.eclipse.ui.plugin.AbstractUIPlugin#start(org.osgi.framework.BundleContext)
	 */
	public void start(BundleContext context) throws Exception {
		super.start(context);
		plugin = this;
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see org.eclipse.ui.plugin.AbstractUIPlugin#stop(org.osgi.framework.BundleContext)
	 */
	public void stop(BundleContext context) throws Exception {
		plugin = null;
		super.stop(context);
	}

	/**
	 * Returns the shared instance
	 * 
	 * @return the shared instance
	 */
	public static Activator getDefault() {
		return plugin;
	}

	/**
	 * Initializes a preference store with default preference values for this plug-in.
	 */
	protected void initializeDefaultPreferences(IPreferenceStore store) {
		// Try to extract options.xml, if not already extracted
		IPath statePath = getStateLocation();
		String defOptionsPath = statePath.append("options.xml").toOSString();
		File defOptionsFile = new File(defOptionsPath);
		if (!defOptionsFile.isFile()) {
			try {
				copyResource("/resources/options.xml", defOptionsPath);
			} catch (IOException e) {
				defOptionsFile.delete();
			}
		}

		// Read default values from environment vars
		String jmodelicaHome = System.getenv("JMODELICA_HOME");
		String modelicaPath = System.getenv("MODELICAPATH");

		// Calculate proper defaults from environment vars
		if (modelicaPath == null && jmodelicaHome != null) {
			modelicaPath = "/ThirdParty/MSL";
			modelicaPath = jmodelicaHome
					+ modelicaPath.replace('/', File.separatorChar);
		}
		String optionsPath = (jmodelicaHome != null) ? jmodelicaHome
				+ File.separator + "Options" : statePath.toOSString();

		// Store calculated values
		store.setDefault(IDEConstants.PROPERTY_LIBRARIES_ID.getLocalName(),
				modelicaPath);
		store.setDefault(IDEConstants.PROPERTY_OPTIONS_PATH_ID.getLocalName(),
				optionsPath);
	}

	/**
	 * \brief Copies a resource from the jar to the file system.
	 * 
	 * @throws FileNotFoundException  If either the resource isn't found or a file 
	 *                                can't be created at the target path.
	 * @throws IOException  If an I/O error occurs.
	 */
	public void copyResource(String resource, String path) throws FileNotFoundException, IOException {
		InputStream in = getClass().getResourceAsStream(resource);
		if (in == null)
			throw new FileNotFoundException("Resource '" + resource + "' not found.");
		OutputStream out = new FileOutputStream(path);
		
		byte[] buf = new byte[1024];
		int i = 0;
		while ((i = in.read(buf)) != -1)
			out.write(buf, 0, i);
		out.close();
		in.close();
	}
}
