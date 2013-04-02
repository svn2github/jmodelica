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

import java.util.HashSet;
import java.util.Set;

import org.eclipse.core.resources.IFile;
import org.eclipse.core.resources.IProject;
import org.eclipse.jface.viewers.ISelection;
import org.eclipse.jface.viewers.IStructuredSelection;
import org.eclipse.jface.viewers.SelectionChangedEvent;
import org.eclipse.jface.viewers.TreeViewer;
import org.eclipse.swt.widgets.Composite;
import org.eclipse.ui.IFileEditorInput;
import org.eclipse.ui.texteditor.AbstractTextEditor;
import org.jastadd.ed.core.model.IASTChangeEvent;
import org.jastadd.ed.core.model.IASTChangeListener;
import org.jmodelica.ide.helpers.CachedClassDecl;
import org.jmodelica.ide.helpers.ICurrentClassListener;
import org.jmodelica.ide.outline.cache.CachedOutlinePage;

public class ClassOutlinePage extends CachedOutlinePage implements
		IASTChangeListener {

	private Set<ICurrentClassListener> currentClassListeners;
	private ClassOutlineCache cache = new ClassOutlineCache(this);

	public ClassOutlinePage(IProject project, AbstractTextEditor editor) {
		super(editor);
		currentClassListeners = new HashSet<ICurrentClassListener>();
	}

	@Override
	public void createControl(Composite parent) {
		super.createControl(parent);
		IFileEditorInput fInput = (IFileEditorInput) fTextEditor
				.getEditorInput();
		IFile file = fInput.getFile();
		cache.setFile(file);
		setDoubleClickHandling(true);
	}

	@Override
	protected void rootChanged(TreeViewer viewer) {
	}

	public void dispose() {
		super.dispose();
		cache.dispose();
		currentClassListeners.clear();
	}

	public void selectionChanged(SelectionChangedEvent event) {
		CachedClassDecl node = getSelectedNode(event.getSelection());
		for (ICurrentClassListener listener : currentClassListeners)
			listener.setCurrentClass(node); // todo used to be BaseClassDecl
		super.selectionChanged(event);
	}

	public CachedClassDecl getSelectedNode(ISelection selection) {
		Object selected = null;
		if (selection instanceof IStructuredSelection)
			selected = ((IStructuredSelection) selection).getFirstElement();
		return (selected instanceof CachedClassDecl) ? (CachedClassDecl) selected
				: null;
	}

	public void addCurrentClassListener(ICurrentClassListener listener) {
		currentClassListeners.add(listener);
		listener.setCurrentClass(getSelectedNode(getSelection()));
	}

	public void removeCurrentClassListener(ICurrentClassListener listener) {
		currentClassListeners.remove(listener);
	}

	@Override
	public void astChanged(IASTChangeEvent e) {
		fRoot = cache.getCache();
		updateAST(fRoot);
	}
}
