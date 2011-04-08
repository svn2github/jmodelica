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

import org.eclipse.core.resources.IProject;
import org.eclipse.jface.viewers.DoubleClickEvent;
import org.eclipse.jface.viewers.IBaseLabelProvider;
import org.eclipse.jface.viewers.IDoubleClickListener;
import org.eclipse.jface.viewers.ITreeContentProvider;
import org.eclipse.jface.viewers.TreeViewer;
import org.eclipse.swt.widgets.Composite;
import org.eclipse.ui.texteditor.AbstractTextEditor;
import org.jastadd.plugin.registry.ASTRegistry;
import org.jastadd.plugin.registry.IASTRegistryListener;
import org.jmodelica.ide.helpers.Util;

public class ClassOutlinePage extends OutlinePage implements IDoubleClickListener, IASTRegistryListener {

	private ASTRegistry registry;
	private ClassOutlineContentProvider content;
	private IProject project;

	public ClassOutlinePage(IProject project, AbstractTextEditor editor) {
		super(editor);
		this.project = project;
	}

	@Override
	public void createControl(Composite parent) {
		super.createControl(parent);
		getTreeViewer().addDoubleClickListener(this);
	    registry = org.jastadd.plugin.Activator.getASTRegistry();
	    registry.addListener(this, project, null);
	    projectASTChanged(project);
	}

	@Override
	protected void rootChanged(TreeViewer viewer) {
	}

	public void dispose() {
		super.dispose();
		registry.removeListener(this);
	}

	@Override
	protected ClassOutlineContentProvider getContentProvider() {
		if (content == null)
			content = new ClassOutlineContentProvider();
		return content;
	}

	protected IBaseLabelProvider getLabelProvider() {
		return new OutlineAwareLabelProvider(JASTADD_LABEL);
	}

	public void doubleClick(DoubleClickEvent event) {
		Object elem = Util.getSelected(event.getSelection());
		Util.openAndSelect(getSite().getPage(), elem);
	}

	public void projectASTChanged(IProject project) {
		updateAST(registry.lookupAST(null, project));
	}

	public void childASTChanged(IProject project, String key) {
		// TODO Auto-generated method stub
		
	}
}
