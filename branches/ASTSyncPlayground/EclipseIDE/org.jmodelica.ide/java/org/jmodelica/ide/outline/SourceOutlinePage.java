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
import org.eclipse.jface.viewers.TreeViewer;
import org.eclipse.ui.texteditor.AbstractTextEditor;
import org.jastadd.ed.core.model.IASTChangeEvent;
import org.jastadd.ed.core.model.IASTChangeListener;
import org.jmodelica.ide.outline.cache.CachedOutlinePage;

public class SourceOutlinePage extends CachedOutlinePage implements
		IASTChangeListener {

	private SourceOutlineCache cache;

	public SourceOutlinePage(AbstractTextEditor editor) {
		super(editor);
		cache = new SourceOutlineCache(this);
	}

	public void setFile(IFile file) {
		cache.setFile(file);
	}

	@Override
	protected void rootChanged(TreeViewer viewer) {
		viewer.expandToLevel(1);
	}

	@Override
	public void astChanged(IASTChangeEvent e) {
		updateAST(cache.getCache());
	}
}