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
package org.jmodelica.ide.preferences;

import java.io.File;
import java.io.FileNotFoundException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.List;

import org.eclipse.core.resources.IProject;
import org.eclipse.core.resources.IncrementalProjectBuilder;
import org.eclipse.core.runtime.CoreException;
import org.eclipse.core.runtime.QualifiedName;
import org.eclipse.swt.SWT;
import org.eclipse.swt.events.SelectionEvent;
import org.eclipse.swt.events.SelectionListener;
import org.eclipse.swt.layout.GridData;
import org.eclipse.swt.layout.GridLayout;
import org.eclipse.swt.widgets.Button;
import org.eclipse.swt.widgets.Combo;
import org.eclipse.swt.widgets.Composite;
import org.eclipse.swt.widgets.Control;
import org.eclipse.swt.widgets.DirectoryDialog;
import org.eclipse.swt.widgets.Group;
import org.eclipse.swt.widgets.MessageBox;
import org.eclipse.swt.widgets.Shell;
import org.eclipse.swt.widgets.Table;
import org.eclipse.swt.widgets.TableColumn;
import org.eclipse.swt.widgets.TableItem;
import org.eclipse.swt.widgets.Text;
import org.eclipse.ui.PlatformUI;
import org.eclipse.ui.dialogs.PropertyPage;
import org.jmodelica.ide.IDEConstants;
import org.jmodelica.ide.helpers.Maybe;
import org.jmodelica.ide.helpers.Util;

public class ProjectPropertyPage extends PropertyPage {
	
	private static final String LIBRARIES_ID = IDEConstants.PREFERENCE_LIBRARIES_ID;
	private static final String OPTIONS_ID = IDEConstants.PREFERENCE_OPTIONS_PATH_ID;
	private ModelicaSettingsControl settings;

	@Override
	protected Control createContents(Composite parent) {
		settings = new ModelicaSettingsControl();
		IProject proj = getProject();
		settings.setLibraryPaths(Preferences.get(proj, LIBRARIES_ID));
		settings.setOptionsPath(Preferences.get(proj, OPTIONS_ID));
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
			Preferences.update(proj, OPTIONS_ID, settings.getOptionsPath());
			proj.build(IncrementalProjectBuilder.FULL_BUILD, null);
		} catch (CoreException e) {
		}
		return super.performOk();
	}

	@Override
	protected void performDefaults() {
		// TODO: We should remember default status, and save by removing the property for this project - will cause preference to be used
		settings.setLibraryPaths(Preferences.get(LIBRARIES_ID));
		settings.setOptionsPath(Preferences.get(OPTIONS_ID));
		super.performDefaults();
	}

}
