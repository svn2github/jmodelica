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

import org.eclipse.jface.viewers.DoubleClickEvent;
import org.eclipse.jface.viewers.IDoubleClickListener;
import org.eclipse.jface.viewers.ITreeContentProvider;
import org.eclipse.jface.viewers.TreeViewer;
import org.eclipse.swt.widgets.Composite;
import org.eclipse.ui.texteditor.AbstractTextEditor;
import org.jmodelica.ide.helpers.Util;

public class InstanceOutlinePage extends OutlinePage implements IDoubleClickListener {

	public InstanceOutlinePage(AbstractTextEditor editor) {
		super(editor);
	}

	@Override
	protected void rootChanged(TreeViewer viewer) {
	}

	@Override
	protected ITreeContentProvider getContentProvider() {
		return new InstanceOutlineContentProvider();
	}

	@Override
	public void createControl(Composite parent) {
		super.createControl(parent);
		getTreeViewer().addDoubleClickListener(this);
	}

	public void doubleClick(DoubleClickEvent event) {
		Object elem = Util.getSelected(event.getSelection());
		Util.openAndSelect(getSite().getPage(), elem);
	}
}
