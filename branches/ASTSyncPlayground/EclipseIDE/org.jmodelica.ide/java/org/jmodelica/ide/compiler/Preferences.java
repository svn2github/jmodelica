package org.jmodelica.ide.compiler;

import org.eclipse.core.resources.IProject;
import org.eclipse.core.resources.ProjectScope;
import org.eclipse.core.runtime.Platform;
import org.eclipse.core.runtime.preferences.AbstractPreferenceInitializer;
import org.eclipse.core.runtime.preferences.IEclipsePreferences;
import org.eclipse.core.runtime.preferences.IEclipsePreferences.IPreferenceChangeListener;
import org.eclipse.core.runtime.preferences.IPreferencesService;
import org.eclipse.core.runtime.preferences.IScopeContext;
import org.eclipse.core.runtime.preferences.InstanceScope;
import org.osgi.service.prefs.BackingStoreException;

public abstract class Preferences extends AbstractPreferenceInitializer {

	private String pluginID;
	
	public Preferences(String pluginID) {
		this.pluginID = pluginID;
	}
		
	public String get(String key) {
		return get(null, key, null);
	}
	
	public void set(String key, String value) {
		set(null, key, value);
	}

	public void update(String key, String value) {
		update(null, key, value);
	}

	public void clear(String key) {
		clear(null, key);
	}
	
	public String get(IProject proj, String key, String def) {
		IPreferencesService service = Platform.getPreferencesService();
		IScopeContext[] contexts = (proj == null) ? null : new IScopeContext[] { new ProjectScope(proj) };
		return service.getString(pluginID, key, def, contexts);		
	}
	
	public String get(IProject proj, String key) {
		return get(proj, key, null);
	}
	
	public String get(String key, String def) {
		return get(null, key, def);
	}
	
	public void set(IProject proj, String key, String value) {
		IEclipsePreferences node = getNode(proj);
		node.put(key, value);
		try {
			node.flush();
		} catch (BackingStoreException e) {
		}
	}

	public void update(IProject proj, String key, String value) {
		if (value != null && !value.isEmpty())
			set(proj, key, value);
		else
			clear(proj, key);
	}

	public void clear(IProject proj, String key) {
		getNode(proj).remove(key);
	}
	
	public void addListener(IPreferenceChangeListener listener) {
		addListener(null, listener);
	}
	
	public void addListener(IProject proj, IPreferenceChangeListener listener) {
		getNode(proj).addPreferenceChangeListener(listener);
	}
	
	public void removeListener(IPreferenceChangeListener listener) {
		removeListener(null, listener);
	}
	
	public void removeListener(IProject proj, IPreferenceChangeListener listener) {
		getNode(proj).removePreferenceChangeListener(listener);
	}

	private IEclipsePreferences getNode(IProject proj) {
		return ((proj == null) ? InstanceScope.INSTANCE : new ProjectScope(proj)).getNode(pluginID);
	}
	
}
