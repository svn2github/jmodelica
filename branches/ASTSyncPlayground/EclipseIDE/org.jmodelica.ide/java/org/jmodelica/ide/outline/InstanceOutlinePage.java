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
package org.jmodelica.ide.outline;

import org.eclipse.core.resources.IFile;
import org.eclipse.jface.action.MenuManager;
import org.eclipse.jface.action.ToolBarManager;
import org.eclipse.jface.viewers.ITreeContentProvider;
import org.eclipse.jface.viewers.TreeViewer;
import org.eclipse.swt.SWT;
import org.eclipse.swt.widgets.Composite;
import org.eclipse.swt.widgets.Menu;
import org.eclipse.ui.IFileEditorInput;
import org.eclipse.ui.texteditor.AbstractTextEditor;
import org.jastadd.ed.core.model.IASTChangeEvent;
import org.jastadd.ed.core.model.IASTChangeListener;
import org.jmodelica.ide.actions.TestRenameAction;
import org.jmodelica.ide.actions.TestRemoveAction;
import org.jmodelica.ide.compiler.ModelicaASTRegistry;

public class InstanceOutlinePage extends OutlinePage implements
		IASTChangeListener {

	public InstanceOutlinePage(AbstractTextEditor editor) {
		super(editor);
	}

	@Override
	protected void rootChanged(TreeViewer viewer) {
	}

	@Override
	protected ITreeContentProvider createContentProvider() {
		return new InstanceOutlineContentProvider();
	}

	@Override
	public void createControl(Composite parent) {
		super.createControl(parent);
		setDoubleClickHandling(true);

		TreeViewer viewer = getTreeViewer();
		ToolBarManager tbm = new ToolBarManager(SWT.FLAT | SWT.RIGHT);
		tbm.createControl(parent);

		MenuManager mm = new MenuManager("Test Menu");
		IFile file = ((IFileEditorInput) this.fTextEditor.getEditorInput())
				.getFile();
		mm.add(new TestRenameAction(viewer, file));
		mm.add(new TestRemoveAction(viewer, file));
		tbm.setContextMenuManager(mm);
		Menu menu = mm.createContextMenu(viewer.getTree());
		viewer.getTree().setMenu(menu);
		ModelicaASTRegistry.getInstance().addListener(
				((IFileEditorInput) fTextEditor.getEditorInput()).getFile(),
				null, this, IASTChangeListener.OUTLINE_LISTENER);
	}

	public void astChanged(IASTChangeEvent e) {
		// Synconization is done in contentprovider.
		long time = System.currentTimeMillis();
		update();
		System.out.println("InstanceOutline update took: "
				+ (System.currentTimeMillis() - time) + "ms");
	}
}