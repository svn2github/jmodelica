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
package org.jmodelica.ide.outline.preferences;

import org.eclipse.core.resources.IProject;
import org.eclipse.core.resources.IncrementalProjectBuilder;
import org.eclipse.core.runtime.CoreException;
import org.eclipse.swt.widgets.Composite;
import org.eclipse.swt.widgets.Control;
import org.eclipse.ui.dialogs.PropertyPage;
import org.jmodelica.ide.IDEConstants;
import org.jmodelica.ide.compiler.Preferences;

public class ProjectPropertyPage extends PropertyPage {

	private static final String LIBRARIES_ID = IDEConstants.PREFERENCE_LIBRARIES_ID;
	private ModelicaSettingsControl settings;

	@Override
	protected Control createContents(Composite parent) {
		settings = new ModelicaSettingsControl();
		IProject proj = getProject();
		settings.setLibraryPaths(Preferences.get(proj, LIBRARIES_ID));
		return settings.createControl(parent);
	}

	private IProject getProject() {
		return (IProject) getElement().getAdapter(IProject.class);
	}

	@Override
	public boolean performOk() {
		IProject proj = getProject();
		try {
			Preferences.set(proj, LIBRARIES_ID, settings.getLibraryPaths());
			proj.build(IncrementalProjectBuilder.FULL_BUILD, null);
		} catch (CoreException e) {
		}
		return super.performOk();
	}

	@Override
	protected void performDefaults() {
		// TODO: We should remember default status, and save by removing the
		// property for this project - will cause preference to be used
		settings.setLibraryPaths(Preferences.get(LIBRARIES_ID));
		super.performDefaults();
	}
}