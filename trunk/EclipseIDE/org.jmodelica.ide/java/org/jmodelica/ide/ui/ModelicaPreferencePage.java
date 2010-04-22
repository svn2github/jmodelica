package org.jmodelica.ide.ui;

import org.eclipse.core.resources.IncrementalProjectBuilder;
import org.eclipse.core.runtime.QualifiedName;
import org.eclipse.jface.preference.IPreferenceStore;
import org.eclipse.jface.preference.PreferencePage;
import org.eclipse.swt.widgets.Composite;
import org.eclipse.swt.widgets.Control;
import org.eclipse.ui.IWorkbench;
import org.eclipse.ui.IWorkbenchPreferencePage;
import org.jmodelica.ide.Activator;
import org.jmodelica.ide.IDEConstants;
import org.jmodelica.ide.helpers.Util;

public class ModelicaPreferencePage extends PreferencePage  implements IWorkbenchPreferencePage {
	
	private static final QualifiedName LIBRARIES_ID = IDEConstants.PROPERTY_LIBRARIES_ID;
	private static final QualifiedName OPTIONS_ID = IDEConstants.PROPERTY_OPTIONS_PATH_ID;
	
	private ModelicaSettingsControl settings;

	@Override
	protected Control createContents(Composite parent) {
		settings = new ModelicaSettingsControl();
		settings.setLibraryPaths(load(LIBRARIES_ID));
		settings.setOptionsPath(load(OPTIONS_ID));
		return settings.createControl(parent);
	}

	private String load(QualifiedName key) {
		return getPreferenceStore().getString(key.getLocalName());
	}

	private void save(QualifiedName key, String value) {
		getPreferenceStore().setValue(key.getLocalName(), value);
	}

	private String defaults(QualifiedName key) {
		IPreferenceStore preferenceStore = getPreferenceStore();
		String name = key.getLocalName();
		preferenceStore.setToDefault(name);
		return preferenceStore.getString(name);
	}

	public void init(IWorkbench workbench) {
		setPreferenceStore(Activator.getDefault().getPreferenceStore());
	}

	@Override
	protected void performDefaults() {
		settings.setLibraryPaths(defaults(LIBRARIES_ID));
		settings.setOptionsPath(defaults(OPTIONS_ID));
		super.performDefaults();
	}

	@Override
	public boolean performOk() {
		save(LIBRARIES_ID, settings.getLibraryPaths());
		save(OPTIONS_ID, settings.getOptionsPath());
		// TODO Trigger rebuild of all Modelica projects
		return super.performOk();
	}

}
