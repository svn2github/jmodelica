package org.jmodelica.ide;

import java.io.BufferedOutputStream;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.net.URL;
import java.util.zip.ZipEntry;
import java.util.zip.ZipInputStream;

import org.eclipse.core.resources.IProject;
import org.eclipse.core.resources.ProjectScope;
import org.eclipse.core.runtime.IPath;
import org.eclipse.core.runtime.Platform;
import org.eclipse.core.runtime.preferences.AbstractPreferenceInitializer;
import org.eclipse.core.runtime.preferences.DefaultScope;
import org.eclipse.core.runtime.preferences.IEclipsePreferences;
import org.eclipse.core.runtime.preferences.IPreferencesService;
import org.eclipse.core.runtime.preferences.IScopeContext;
import org.eclipse.core.runtime.preferences.InstanceScope;

public class Preferences extends AbstractPreferenceInitializer {

	private static final int BUF_SIZE = 2048;
	private byte buf[] = new byte[BUF_SIZE];

	public Preferences() {
	}
	
	public static String get(String key) {
		IPreferencesService service = Platform.getPreferencesService();
		return service.getString(IDEConstants.PLUGIN_ID, key, null, null);
	}
	
	public static void set(String key, String value) {
		new InstanceScope().getNode(IDEConstants.PLUGIN_ID).put(key, value);
	}

	public static void update(String key, String value) {
		if (value != null && !value.isEmpty())
			set(key, value);
		else
			clear(key);
	}

	public static void clear(String key) {
		new InstanceScope().getNode(IDEConstants.PLUGIN_ID).remove(key);
	}
	
	public static String get(IProject proj, String key) {
		IPreferencesService service = Platform.getPreferencesService();
		IScopeContext[] contexts = new IScopeContext[] { new ProjectScope(proj) };
		return service.getString(IDEConstants.PLUGIN_ID, key, null, contexts);
	}
	
	public static void set(IProject proj, String key, String value) {
		new ProjectScope(proj).getNode(IDEConstants.PLUGIN_ID).put(key, value);
	}

	public static void update(IProject proj, String key, String value) {
		if (value != null && !value.isEmpty())
			set(key, value);
		else
			clear(key);
	}

	public static void clear(IProject proj, String key) {
		new ProjectScope(proj).getNode(IDEConstants.PLUGIN_ID).remove(key);
	}

	@Override
	public void initializeDefaultPreferences() {
		Activator plugin = Activator.getDefault();
		
		// Try to extract options.xml, if not already extracted
		IPath statePath = plugin.getStateLocation();
		String defOptionsPath = statePath.toOSString();
		File defOptionsFile = new File(defOptionsPath, IDEConstants.DEF_OPTIONS_NAME);
		if (!defOptionsFile.isFile()) {
			try {
				saveFile(openResource(IDEConstants.DEF_OPTIONS_URL), defOptionsFile);
			} catch (IOException e) {
				defOptionsFile.delete();
			}
		}

		// Read default values from environment vars
		String jmodelicaHome = System.getenv("JMODELICA_HOME");
		String modelicaPath = System.getenv("MODELICAPATH");

		// Calculate proper defaults from environment vars
		if (modelicaPath == null && jmodelicaHome != null) {
			modelicaPath = jmodelicaHome
					+ "/ThirdParty/MSL".replace('/', File.separatorChar);
		}
		String optionsPath = (jmodelicaHome != null) ? 
				(jmodelicaHome + File.separator + "Options") : defOptionsPath;
		
		// If no MODELICAPATH can be calculated, try to extract MSL from plugin
		if (modelicaPath == null) 
			modelicaPath = getExtractedMSLPath();
		if (modelicaPath == null) 
			modelicaPath = "";

		// Store calculated values
		IEclipsePreferences node = new DefaultScope().getNode(IDEConstants.PLUGIN_ID);
		node.put(IDEConstants.PROPERTY_LIBRARIES_ID, modelicaPath);
		node.put(IDEConstants.PROPERTY_OPTIONS_PATH_ID, optionsPath);
	}

	private String getExtractedMSLPath() {
		String dir = Activator.getDefault().getStateLocation().toOSString();
		File mslDirPath = new File(dir, "MSL");
		if (!mslDirPath.isDirectory()) {
			try {
				extractMSL(mslDirPath);
			} catch (SecurityException e) {
				return null;
			} catch (IOException e) {
				return null;
			}
		}
		return mslDirPath.getAbsolutePath();
	}

	private void extractMSL(File mslDirPath) throws IOException, SecurityException {
		// TODO: this takes a little while - show progress bar?
		if (mslDirPath.isFile())
			mslDirPath.delete();
		mslDirPath.mkdir();
		ZipInputStream zis = new ZipInputStream(openResource(IDEConstants.MSL_ZIP_URL));
		ZipEntry entry;
		while ((entry = zis.getNextEntry()) != null) {
			File path = new File(mslDirPath, entry.getName());
			if (entry.isDirectory())
				path.mkdir();
			else
				saveFile(zis, path);
		}
		zis.close();
	}

	private InputStream openResource(String url) throws IOException {
		return new URL(url).openConnection().getInputStream();
	}

	private void saveFile(InputStream is, File path) throws IOException {
		int count;
		FileOutputStream fos = new FileOutputStream(path);
		BufferedOutputStream dest = new BufferedOutputStream(fos, BUF_SIZE);
		while ((count = is.read(buf, 0, BUF_SIZE)) != -1)
			dest.write(buf, 0, count);
		dest.close();
	}

}
