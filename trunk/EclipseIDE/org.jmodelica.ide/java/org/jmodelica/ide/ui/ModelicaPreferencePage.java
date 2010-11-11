package org.jmodelica.ide.ui;

import org.eclipse.core.resources.IncrementalProjectBuilder;
import org.eclipse.core.runtime.QualifiedName;
import org.eclipse.core.runtime.preferences.ConfigurationScope;
import org.eclipse.core.runtime.preferences.IEclipsePreferences;
import org.eclipse.core.runtime.preferences.InstanceScope;
import org.eclipse.jface.preference.IPreferenceStore;
import org.eclipse.jface.preference.PreferencePage;
import org.eclipse.swt.widgets.Composite;
import org.eclipse.swt.widgets.Control;
import org.eclipse.ui.IWorkbench;
import org.eclipse.ui.IWorkbenchPreferencePage;
import org.jmodelica.ide.Activator;
import org.jmodelica.ide.IDEConstants;
import org.jmodelica.ide.Preferences;
import org.jmodelica.ide.helpers.Util;

public class ModelicaPreferencePage extends PreferencePage  implements IWorkbenchPreferencePage {
	
	private static final String LIBRARIES_ID = IDEConstants.PROPERTY_LIBRARIES_ID;
	private static final String OPTIONS_ID = IDEConstants.PROPERTY_OPTIONS_PATH_ID;
	
	private ModelicaSettingsControl settings;

	@Override
	protected Control createContents(Composite parent) {
		settings = new ModelicaSettingsControl();
		settings.setLibraryPaths(Preferences.get(LIBRARIES_ID));
		setOptionsPath(Preferences.get(OPTIONS_ID));
		return settings.createControl(parent);
	}

	private void setOptionsPath(String options) {
		String stateLoc = Activator.getDefault().getStateLocation().toOSString();
		settings.setOptionsPath(options.equals(stateLoc) ? "" : options);
	}

	private String defaults(String key) {
		Preferences.clear(key);
		return Preferences.get(key);
	}

	public void init(IWorkbench workbench) {
		setPreferenceStore(Activator.getDefault().getPreferenceStore());
	}

	@Override
	protected void performDefaults() {
		settings.setLibraryPaths(defaults(LIBRARIES_ID));
		setOptionsPath(defaults(OPTIONS_ID));
		super.performDefaults();
	}

	@Override
	public boolean performOk() {
		Preferences.set(LIBRARIES_ID, settings.getLibraryPaths());
		Preferences.update(OPTIONS_ID, settings.getOptionsPath());
		// TODO Trigger rebuild of all Modelica projects
		return super.performOk();
	}

}
