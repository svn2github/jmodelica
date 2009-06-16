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
import java.util.Collections;
import java.util.List;

import org.eclipse.core.resources.IProject;
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
import org.eclipse.swt.widgets.Label;
import org.eclipse.swt.widgets.MessageBox;
import org.eclipse.swt.widgets.Shell;
import org.eclipse.swt.widgets.Table;
import org.eclipse.swt.widgets.TableColumn;
import org.eclipse.swt.widgets.TableItem;
import org.eclipse.ui.PlatformUI;
import org.eclipse.ui.dialogs.PropertyPage;
import org.jmodelica.ide.Constants;
import org.jmodelica.ide.helpers.Library;
import org.jmodelica.ide.helpers.Library.Version;
import org.jmodelica.ide.scanners.generated.PackageExaminer;

public class ProjectPropertyPage extends PropertyPage {

	private List<Library> libraries;
	private String defaultMSL;
	
	private Combo defMSLCombo;
	private Button delLibraryButton;
	private Button addLibraryButton;
	private Table libraryTable;
	
	private DirectoryDialog dirDlg;
	private MessageBox error;
	private PackageExaminer	examiner;

	public ProjectPropertyPage() {
		Shell shell = PlatformUI.getWorkbench().getDisplay().getActiveShell();
		dirDlg = new DirectoryDialog(shell);
		dirDlg.setMessage("Select directory containing library");
		dirDlg.setText("Select library");
		error = new MessageBox(shell, SWT.ICON_ERROR | SWT.OK);
		examiner = new PackageExaminer();
	}
	
	@Override
	protected Control createContents(Composite parent) {
		Group lib = createLibraryGroup(parent);
		return lib;
	}

	private Group createLibraryGroup(Composite parent) {
		loadProperties();
		Group lib = new Group(parent, SWT.NONE);
		lib.setText("Libraries");
		GridLayout layout = new GridLayout();
		layout.numColumns = 1;
		lib.setLayout(layout);
		createDefaultMSLComposite(lib);
		createLibrariesComposite(lib);
		return lib;
	}

	private Composite createDefaultMSLComposite(Composite parent) {
		Composite container = new Composite(parent, SWT.NONE);
		GridLayout layout = createMarginlessGridLayout(2);
		container.setLayout(layout);
		new Label(container, SWT.LEFT).setText("Default standard library version:");
		defMSLCombo = new Combo(container, SWT.DROP_DOWN);
		defMSLCombo.addSelectionListener(new DefMSLListener());
		updateDefautMSL();
		container.pack();
		return container;
	}

	private void createLibrariesComposite(Composite parent) {
		Composite container = new Composite(parent, SWT.NONE);
		container.setLayoutData(new GridData(SWT.FILL, SWT.FILL, true, true));
		GridLayout layout = createMarginlessGridLayout(2);
		container.setLayout(layout);
		createLibraryTable(container);
		createLibraryButtonsComposite(container);
		container.pack();
	}

	private void createLibraryButtonsComposite(Composite parent) {
		Composite container = new Composite(parent, SWT.NONE);
		container.setLayoutData(new GridData(SWT.BEGINNING, SWT.BEGINNING, false, false));
		GridLayout layout = createMarginlessGridLayout(1);
		container.setLayout(layout);
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
		data.heightHint = 200;
		libraryTable.setLayoutData(data);
		String[] titles = { "Library", "Version", "Location" };
		for (int i = 0; i < titles.length; i++) {
			TableColumn column = new TableColumn(libraryTable, SWT.NONE);
			column.setText(titles[i]);
		}
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

	private GridLayout createMarginlessGridLayout(int cols) {
		GridLayout layout = new GridLayout();
		layout.marginHeight = 0;
		layout.marginWidth = 0;
		layout.numColumns = cols;
		return layout;
	}

	private void fillLibraryTable() {
		IProject proj = getProject();
		if (proj != null) {
			for (int i = 0; i < libraries.size(); i++) 
				addLibrary(libraries.get(i));
		}
		for (int i = 0; i < libraryTable.getColumnCount(); i++) {
			libraryTable.getColumn(i).pack();
		}
	}

	private void addLibrary(Library library) {
		TableItem item = new TableItem(libraryTable, SWT.NONE);
		item.setText(0, library.name);
		item.setText(1, library.version.toString());
		item.setText(2, library.path);
	}

	private IProject getProject() {
		return (IProject) getElement().getAdapter(IProject.class);
	}

	@Override
	public boolean performOk() {
		saveProperties();
		return true;
	}
	
	private void loadProperties() {
		IProject proj = getProject();
		String libStr = null;
		try {
			libStr = proj.getPersistentProperty(Constants.PROPERTY_LIBRARIES_ID);
			defaultMSL = proj.getPersistentProperty(Constants.PROPERTY_DEFAULT_MSL_ID);
		} catch (CoreException e) {
		}
		libraries = Library.fromString(libStr);
	}
	
	private void saveProperties() {
		IProject proj = getProject();
		try {
			String libStr = Library.toString(libraries);
			proj.setPersistentProperty(Constants.PROPERTY_LIBRARIES_ID, libStr);
			proj.setPersistentProperty(Constants.PROPERTY_DEFAULT_MSL_ID, defaultMSL);
		} catch (CoreException e) {
		}
	}

	public void updateDefautMSL() {
		ArrayList<Version> versions = new ArrayList<Version>(libraries.size());
		for (int i = 0; i < libraries.size(); i++) {
			Library lib = libraries.get(i);
			if (lib.name.equals("Modelica")) 
				versions.add(lib.version);
		}
		Collections.sort(versions, Collections.reverseOrder());
		defMSLCombo.removeAll();
		for (Version v : versions) {
			String str = v.toString();
			defMSLCombo.add(str);
			if (str.equals(defaultMSL)) {
				defMSLCombo.select(defMSLCombo.getItemCount() - 1);
			}
		}
		if (defMSLCombo.getSelectionIndex() == -1) {
			if (defMSLCombo.getItemCount() > 0) {
				defMSLCombo.select(0);
				defaultMSL = defMSLCombo.getItem(0);
			} else {
				defaultMSL = null;
			}
		}
	}

	public class AddListener implements SelectionListener {

		public void widgetDefaultSelected(SelectionEvent e) {
		}

		public void widgetSelected(SelectionEvent e) {
			String path = dirDlg.open();
			if (path != null) {
				try {
					Library lib = examiner.examine(path);
					if (!lib.isOK()) {
						error.setMessage("Could not find package information in package.mo file.");
						error.open();
					} else if (libraries.contains(lib)) {
						error.setMessage("Library already added.");
						error.open();
					} else {
						libraries.add(lib);
						addLibrary(lib);
						if (lib.name.equals("Modelica"))
							updateDefautMSL();
					}
				} catch (FileNotFoundException ex) {
					error.setMessage("No package.mo file found.\nDirectory does not seem to contain a library.");
					error.open();
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
			boolean isMSL = libraries.get(i).name.equals("Modelica");
			libraryTable.remove(i);
			libraries.remove(i);
			if (isMSL)
				updateDefautMSL();
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

	public class DefMSLListener implements SelectionListener {

		public void widgetDefaultSelected(SelectionEvent e) {
			widgetSelected(e);
		}

		public void widgetSelected(SelectionEvent e) {
			defaultMSL = defMSLCombo.getItem(defMSLCombo.getSelectionIndex());
		}

	}

}
