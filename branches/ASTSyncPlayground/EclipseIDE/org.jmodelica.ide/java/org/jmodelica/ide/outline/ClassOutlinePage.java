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

import java.util.ArrayList;
import java.util.HashSet;
import java.util.Set;

import org.eclipse.core.resources.IFile;
import org.eclipse.core.resources.IProject;
import org.eclipse.jface.viewers.IBaseLabelProvider;
import org.eclipse.jface.viewers.IDoubleClickListener;
import org.eclipse.jface.viewers.ISelection;
import org.eclipse.jface.viewers.IStructuredSelection;
import org.eclipse.jface.viewers.SelectionChangedEvent;
import org.eclipse.jface.viewers.TreeViewer;
import org.eclipse.swt.widgets.Composite;
import org.eclipse.ui.IFileEditorInput;
import org.eclipse.ui.texteditor.AbstractTextEditor;
import org.jastadd.ed.core.model.IASTChangeEvent;
import org.jastadd.ed.core.model.IASTChangeListener;
import org.jmodelica.ide.compiler.LocalRootNode;
import org.jmodelica.ide.compiler.ModelicaASTRegistry;
import org.jmodelica.ide.editor.ICurrentClassListener;
import org.jmodelica.modelica.compiler.BaseClassDecl;
import org.jmodelica.modelica.compiler.SourceRoot;

public class ClassOutlinePage extends OutlinePage implements
		IDoubleClickListener, IASTChangeListener {

	private static final ClassOutlineContentProvider CLASS_OUTLINE_CONTENT = new ClassOutlineContentProvider();
	private static final OutlineAwareLabelProvider OUTLINE_AWARE_LABEL = new OutlineAwareLabelProvider(
			JASTADD_LABEL);

	private ModelicaASTRegistry registry;
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
		registry = ModelicaASTRegistry.getASTRegistry();
		registry.addListener(this);// , project, null);
		IFileEditorInput fInput = (IFileEditorInput) fTextEditor
				.getEditorInput();
		IFile file = fInput.getFile();
		registry.addListener(file, new ArrayList<String>(), this);
		SourceRoot root = ((LocalRootNode)registry.doLookup(file)[0]).getSourceRoot();
		updateAST(root);
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
		return CLASS_OUTLINE_CONTENT;
	}

	protected IBaseLabelProvider getLabelProvider() {
		return OUTLINE_AWARE_LABEL;
	}

	/*
	 * public void projectASTChanged(IProject project) {
	 * updateAST(registry.doLookup(project)); }
	 * 
	 * public void childASTChanged(IProject project, String key) { ASTNode node
	 * = (ASTNode) registry.doLookup()(key, project); if (node != null &&
	 * !node.isError()) update(getContentProvider().getParent(node)); }
	 */

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
		return (selected instanceof BaseClassDecl) ? (BaseClassDecl) selected
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
		System.out.println("CLASSOUTLINEPAGE RECIEVED ASTEVENT, UPDATING...");
		/*
		 * GlobalRootNode groot = (GlobalRootNode) registry.doLookup(project);
		 * System
		 * .out.println("ClassOutlinePage working on project: "+groot.getSourceRoot
		 * ().getProject().getName()); update(groot.getSourceRoot());
		 * updateAST(groot.getSourceRoot());
		 */
		updateAST(fRoot);
	}

}
