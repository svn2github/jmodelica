package org.jmodelica.ide.preferences;

import org.eclipse.jface.preference.PreferencePage;
import org.eclipse.swt.widgets.Composite;
import org.eclipse.swt.widgets.Control;
import org.eclipse.ui.IWorkbench;
import org.eclipse.ui.IWorkbenchPreferencePage;
import org.jmodelica.ide.IDEConstants;

public class ModelicaPreferencePage extends PreferencePage  implements IWorkbenchPreferencePage {
	
	private static final String LIBRARIES_ID = IDEConstants.PREFERENCE_LIBRARIES_ID;
	
	private ModelicaSettingsControl settings;

	@Override
	protected Control createContents(Composite parent) {
		settings = new ModelicaSettingsControl();
		settings.setLibraryPaths(ModelicaPreferences.INSTANCE.get(LIBRARIES_ID));
		return settings.createControl(parent);
	}

	private String defaults(String key) {
		ModelicaPreferences.INSTANCE.clear(key);
		return ModelicaPreferences.INSTANCE.get(key);
	}

	public void init(IWorkbench workbench) {}

	@Override
	protected void performDefaults() {
		// TODO: Don't reset the values, just get default values and remember that they are set to default
		settings.setLibraryPaths(defaults(LIBRARIES_ID));
		super.performDefaults();
	}

	@Override
	public boolean performOk() {
		// TODO: for a value that is still default, do Preferences.clear() instead
		ModelicaPreferences.INSTANCE.set(LIBRARIES_ID, settings.getLibraryPaths());
		// TODO Trigger rebuild of all Modelica projects
		return super.performOk();
	}

}
