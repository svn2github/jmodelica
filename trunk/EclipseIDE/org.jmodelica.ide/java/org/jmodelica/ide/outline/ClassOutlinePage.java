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

import org.eclipse.core.resources.IProject;
import org.eclipse.jface.viewers.DoubleClickEvent;
import org.eclipse.jface.viewers.IBaseLabelProvider;
import org.eclipse.jface.viewers.IDoubleClickListener;
import org.eclipse.jface.viewers.ISelection;
import org.eclipse.jface.viewers.IStructuredSelection;
import org.eclipse.jface.viewers.SelectionChangedEvent;
import org.eclipse.jface.viewers.TreeViewer;
import org.eclipse.swt.widgets.Composite;
import org.eclipse.ui.texteditor.AbstractTextEditor;
import org.jastadd.plugin.compiler.ast.IASTNode;
import org.jastadd.plugin.registry.ASTRegistry;
import org.jastadd.plugin.registry.IASTRegistryListener;
import org.jmodelica.ide.editor.ICurrentClassListener;
import org.jmodelica.ide.helpers.Util;
import org.jmodelica.modelica.compiler.ASTNode;
import org.jmodelica.modelica.compiler.BaseClassDecl;

public class ClassOutlinePage extends OutlinePage implements IDoubleClickListener, IASTRegistryListener {

	private ASTRegistry registry;
	private ClassOutlineContentProvider content;
	private IProject project;
	private Set<ICurrentClassListener> currentClassListeners;

	public ClassOutlinePage(IProject project, AbstractTextEditor editor) {
		super(editor);
		this.project = project;
		currentClassListeners = new HashSet<ICurrentClassListener>();
	}

	@Override
	public void createControl(Composite parent) {
		super.createControl(parent);
	    registry = org.jastadd.plugin.Activator.getASTRegistry();
	    registry.addListener(this, project, null);
	    projectASTChanged(project);
	    setDoubleClickHandling(true);
	}

	@Override
	protected void rootChanged(TreeViewer viewer) {
	}

	public void dispose() {
		super.dispose();
		registry.removeListener(this);
		currentClassListeners.clear();
	}

	@Override
	protected ClassOutlineContentProvider createContentProvider() {
		return new ClassOutlineContentProvider();
	}

	protected IBaseLabelProvider getLabelProvider() {
		return new OutlineAwareLabelProvider(JASTADD_LABEL);
	}

	public void projectASTChanged(IProject project) {
		updateAST(registry.lookupAST(null, project));
	}

	public void childASTChanged(IProject project, String key) {
		ASTNode node = (ASTNode) registry.lookupAST(key, project);
		if (!node.isError())
			update(getContentProvider().getParent(node));
	}

	public void selectionChanged(SelectionChangedEvent event) {
		BaseClassDecl node = getSelectedNode(event.getSelection());
		for (ICurrentClassListener listener : currentClassListeners)
			listener.setCurrentClass(node);
		super.selectionChanged(event);
	}

	public BaseClassDecl getSelectedNode(ISelection selection) {
		Object selected = null;
		if (selection instanceof IStructuredSelection) 
			selected = ((IStructuredSelection) selection).getFirstElement();
		return (selected instanceof BaseClassDecl) ? (BaseClassDecl) selected : null;
	}
	
	public void addCurrentClassListener(ICurrentClassListener listener) {
		currentClassListeners.add(listener);
		listener.setCurrentClass(getSelectedNode(getSelection()));
	}
	
	public void removeCurrentClassListener(ICurrentClassListener listener) {
		currentClassListeners.remove(listener);
	}
	
}
