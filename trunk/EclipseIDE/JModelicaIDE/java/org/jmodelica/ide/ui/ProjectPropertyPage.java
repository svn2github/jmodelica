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
import org.eclipse.ui.PlatformUI;
import org.eclipse.ui.dialogs.PropertyPage;
import org.jmodelica.ide.IDEConstants;
import org.jmodelica.ide.helpers.Maybe;
import org.jmodelica.ide.helpers.Util;

public class ProjectPropertyPage extends PropertyPage {

	private List<String> library_paths;
	private String defaultMSL;
	private String optionsPath;

	private Combo defMSLCombo;
	private Button delLibraryButton;
	private Button addLibraryButton;
	private Button optionsBrowse;
	private org.eclipse.swt.widgets.Text text;
	private Table libraryTable;
	private Group optionsGroup;

	private DirectoryDialog dirDlg;
	private final DirectoryDialog optionsDlg;
	private MessageBox error;

	private boolean changed;

	public ProjectPropertyPage() {

		Shell shell = PlatformUI.getWorkbench().getDisplay().getActiveShell();

		dirDlg = new DirectoryDialog(shell);
		dirDlg.setMessage("Select directory to load libraries from");
		dirDlg.setText("Select directory");

		optionsDlg = new DirectoryDialog(shell);
		optionsDlg.setMessage("Select directory containing options.xml");
		optionsDlg.setText("Select directory");

		error = new MessageBox(shell, SWT.ICON_ERROR | SWT.OK);
		changed = false;

		optionsPath = "";
	}

	@Override
	protected Control createContents(Composite parent) {
		return createLibraryGroup(parent);
	}

	private Composite createLibraryGroup(Composite parent) {
		loadProperties();

		Group lib = new Group(parent, SWT.NONE);
		lib.setText("Library paths");
		lib.setLayout(new GridLayout(1, false));
		createLibrariesComposite(lib);

		optionsGroup = new Group(parent, SWT.None);
		optionsGroup.setText("Options.xml path");
		optionsGroup.setLayout(new GridLayout(1, false));
		createOptionsSelection(optionsGroup);
		optionsGroup.pack();

		return lib;
	}

	private Composite newContainer(Composite parent, int layoutNbrCols) {
		Composite container = new Composite(parent, SWT.None);
		container.setLayoutData(new GridData(SWT.FILL, SWT.FILL, true, true));
		container.setLayout(marginlessGridLayout(layoutNbrCols));

		return container;
	}

	private Composite createOptionsSelection(Composite parent) {
		Composite container = newContainer(parent, 3);

		text = new org.eclipse.swt.widgets.Text(container, SWT.NONE);
		text.setText(optionsPath);

		optionsBrowse = createButton(container, "Browse");
		optionsBrowse.addSelectionListener(new OptionsListener());

		return container;
	}

	private void createLibrariesComposite(Composite parent) {
		Composite container = newContainer(parent, 2);
		createLibraryTable(container);
		createLibraryButtonsComposite(container);
		container.pack();
	}

	private void createLibraryButtonsComposite(Composite parent) {
		Composite container = new Composite(parent, SWT.NONE);
		container.setLayoutData(new GridData(SWT.BEGINNING, SWT.BEGINNING, false, false));
		container.setLayout(marginlessGridLayout(1));

		addLibraryButton = createButton(container, "Add");
		addLibraryButton.addSelectionListener(new AddListener());

		delLibraryButton = createButton(container, "Remove");
		delLibraryButton.addSelectionListener(new DeleteListener());
		delLibraryButton.setEnabled(false);

		container.pack();
	}

	private Table createLibraryTable(Composite parent) {
		libraryTable = new Table(parent, SWT.MULTI | SWT.BORDER | SWT.FULL_SELECTION);
		libraryTable.setLinesVisible(true);
		libraryTable.setHeaderVisible(true);
		GridData data = new GridData(SWT.FILL, SWT.FILL, true, true);
		data.heightHint = 100;
		libraryTable.setLayoutData(data);

		for (String columnName : new String[] { "Path" })
			new TableColumn(libraryTable, SWT.NONE).setText(columnName);

		fillLibraryTable();
		libraryTable.addSelectionListener(new TableSelectionListener());
		return libraryTable;
	}

	private Button createButton(Composite parent, String title) {
		Button button = new Button(parent, SWT.PUSH);
		button.setText(title);
		button.setLayoutData(new GridData(SWT.FILL, SWT.BEGINNING, false, false));
		return button;
	}

	private GridLayout marginlessGridLayout(int cols) {
		GridLayout layout = new GridLayout();
		layout.marginHeight = 0;
		layout.marginWidth = 0;
		layout.numColumns = cols;
		return layout;
	}

	private void fillLibraryTable() {
		if (getProject() == null)
			return;

		for (String lib : library_paths)
			addLibrary(lib);

		for (TableColumn tc : libraryTable.getColumns())
			tc.pack();
	}

	private void addLibrary(String library) {
		new TableItem(libraryTable, SWT.NONE).setText(0, library);
	}

	private IProject getProject() {
		return (IProject) getElement().getAdapter(IProject.class);
	}

	@Override
	public boolean performOk() {
		saveProperties();
		return true;
	}

	@Override
	public boolean performCancel() {
		changed = false;
		return true;
	}

	private void loadProperties() {
		IProject proj = getProject();
		String libStr = null;

		try {
			libStr = proj.getPersistentProperty(IDEConstants.PROPERTY_LIBRARIES_ID);
			optionsPath = proj.getPersistentProperty(IDEConstants.PROPTERTY_OPTIONS_PATH);
			if (optionsPath == null)
				optionsPath = "";
		} catch (CoreException e) {
			e.printStackTrace();
		}

		library_paths = new ArrayList();
		if (libStr != null)
			library_paths.addAll(Arrays.asList(libStr.split(IDEConstants.PATH_SEP)));
	}

	private void saveProperties() {
		IProject proj = getProject();

		try {
			String libStr = Util.implode(IDEConstants.PATH_SEP, library_paths);
			proj.setPersistentProperty(IDEConstants.PROPERTY_LIBRARIES_ID, libStr);
			proj.setPersistentProperty(IDEConstants.PROPTERTY_OPTIONS_PATH, text.getText());

			if (changed)
				proj.build(IncrementalProjectBuilder.FULL_BUILD, null);

		} catch (CoreException e) {
			e.printStackTrace();
		}

		changed = false;
	}

	public class OptionsListener implements SelectionListener {

		public void widgetDefaultSelected(SelectionEvent e) {
		}

		public void widgetSelected(SelectionEvent e) {
			String path = optionsDlg.open();
			if (path == null)
				return;

			if (path.endsWith("options.xml"))
				path = path.substring(0, path.length() - "options.xml".length());

			String[] files = new File(path).list();
			if (files != null && Arrays.asList(files).contains("options.xml")) {
				error.setMessage("No options.xml found in folder");
				error.open();
			}

			text.setText(path);
			optionsGroup.pack();
		}

	}

	public class AddListener implements SelectionListener {

		public void widgetDefaultSelected(SelectionEvent e) {
		}

		public void widgetSelected(SelectionEvent e) {
			String path = dirDlg.open();
			if (path != null) {
				if (library_paths.contains(path)) {
					error.setMessage("Library path already added.");
					error.open();
				} else {
					library_paths.add(path);
					addLibrary(path);
					changed = true;
				}
			}
		}

	}

	public class DeleteListener implements SelectionListener {

		public void widgetDefaultSelected(SelectionEvent e) {
		}

		public void widgetSelected(SelectionEvent e) {
			libraryTable.getSelectionIndex();
			int i = libraryTable.getSelectionIndex();
			libraryTable.remove(i);
			library_paths.remove(i);
			changed = true;
		}

	}

	public class TableSelectionListener implements SelectionListener {

		public void widgetDefaultSelected(SelectionEvent e) {
			widgetSelected(e);
		}

		public void widgetSelected(SelectionEvent e) {
			delLibraryButton.setEnabled(e.item != null);
		}

	}

}
