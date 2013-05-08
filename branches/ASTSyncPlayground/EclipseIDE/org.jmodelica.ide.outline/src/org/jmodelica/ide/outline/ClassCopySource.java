package org.jmodelica.ide.outline;

import java.util.Iterator;

import org.eclipse.jface.viewers.IStructuredSelection;
import org.eclipse.jface.viewers.StructuredViewer;
import org.jmodelica.ide.sync.CachedClassDecl;

public class ClassCopySource {

	private StructuredViewer viewer;

	public ClassCopySource(StructuredViewer viewer) {
		this.viewer = viewer;
	}

	public boolean canCopy() {
		return canCopy((IStructuredSelection) viewer.getSelection());
	}

	public static boolean canCopy(IStructuredSelection selection) {
		if (!selection.isEmpty()) {
			Iterator<?> it = selection.iterator();
			while (it.hasNext())
				if (!(it.next() instanceof CachedClassDecl))
					return false;
			return true;
		}
		return false;
	}

	public String getStringData() {
		return getStringData((IStructuredSelection) viewer.getSelection());
	}

	public static String getStringData(IStructuredSelection selection) {
		Object[] elems = selection.toArray();
		if (elems.length == 1 && elems[0] instanceof CachedClassDecl) { 
			return ((CachedClassDecl) elems[0]).qualifiedName();
		} else {
			StringBuilder buf = new StringBuilder();
			for (Object elem : elems) {
				if (elem instanceof CachedClassDecl) {
					buf.append(((CachedClassDecl) elem).qualifiedName());
					buf.append('\n');
				}
			}
			return buf.toString();
		}
	}

}
