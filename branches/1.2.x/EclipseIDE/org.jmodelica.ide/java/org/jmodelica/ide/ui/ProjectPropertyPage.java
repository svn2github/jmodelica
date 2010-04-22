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
	
	private static final QualifiedName LIBRARIES_ID = IDEConstants.PROPERTY_LIBRARIES_ID;
	private static final QualifiedName OPTIONS_ID = IDEConstants.PROPERTY_OPTIONS_PATH_ID;
	private ModelicaSettingsControl settings;

	@Override
	protected Control createContents(Composite parent) {
		settings = new ModelicaSettingsControl();
		IProject proj = getProject();
		settings.setLibraryPaths(Util.getProperty(proj, LIBRARIES_ID));
		settings.setOptionsPath(Util.getProperty(proj, OPTIONS_ID));
		return settings.createControl(parent);
	}

	private IProject getProject() {
		return (IProject) getElement().getAdapter(IProject.class);
	}

	@Override
	public boolean performOk() {
		IProject proj = getProject();
		try {
			proj.setPersistentProperty(LIBRARIES_ID, settings.getLibraryPaths());
			proj.setPersistentProperty(OPTIONS_ID, settings.getOptionsPath());
			proj.build(IncrementalProjectBuilder.FULL_BUILD, null);
		} catch (CoreException e) {
		}
		return super.performOk();
	}

	@Override
	protected void performDefaults() {
		settings.setLibraryPaths(Util.getProperty(null, LIBRARIES_ID));
		settings.setOptionsPath(Util.getProperty(null, OPTIONS_ID));
		super.performDefaults();
	}

}
