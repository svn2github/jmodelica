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

import java.util.HashMap;
import java.util.Map;

import org.eclipse.core.runtime.preferences.IEclipsePreferences.IPreferenceChangeListener;
import org.eclipse.core.runtime.preferences.IEclipsePreferences.PreferenceChangeEvent;
import org.eclipse.jface.viewers.Viewer;
import org.eclipse.jface.viewers.ViewerSorter;
import org.jmodelica.ide.IDEConstants;
import org.jmodelica.ide.compiler.Preferences;
import org.jmodelica.ide.helpers.CachedASTNode;
import org.jmodelica.ide.helpers.CachedClassDecl;
import org.jmodelica.ide.helpers.LoadedLibraries;

public class OutlineItemComparator extends ViewerSorter implements IPreferenceChangeListener {

	private static Map<String,ViewerSorter> COMPARATORS = new HashMap<String,ViewerSorter>();
	static {
		COMPARATORS.put(IDEConstants.SORT_ALPHA, new CompAlpha());
		COMPARATORS.put(IDEConstants.SORT_DECLARED, new CompDeclared());
	}
	
	private ViewerSorter cmp;
	
	public OutlineItemComparator() {
		updateComparator();
		Preferences.addListener(this);
	}
	
	public int category(Object element) {
		if (element instanceof CachedASTNode)
			return ((CachedASTNode) element).outlineCategory();
		if (element instanceof LoadedLibraries) 
			return -5;
		return super.category(element);
	}

	public int compare(Viewer viewer, Object e1, Object e2) {
		int cat1 = category(e1);
        int cat2 = category(e2);
        if (cat1 != cat2) 
			return cat1 - cat2;
        else
        	return cmp.compare(viewer, e1, e2);
	}

	public void preferenceChange(PreferenceChangeEvent event) {
		if (event.getKey().equals(IDEConstants.PREFERENCE_EXPLORER_SORT_ORDER))
			updateComparator();
	}

	public void updateComparator() {
		cmp = COMPARATORS.get(Preferences.get(IDEConstants.PREFERENCE_EXPLORER_SORT_ORDER));
	}

	public static class CompAlpha extends ViewerSorter {

		public int compare(Viewer viewer, Object e1, Object e2) {
			// TODO: Move to an attribute
			if (e1 instanceof CachedClassDecl && e2 instanceof CachedClassDecl) {
				String id1 = ((CachedClassDecl) e1).getText();
				String id2 = ((CachedClassDecl) e2).getText();
				return getComparator().compare(id1, id2);
			}
			return super.compare(viewer, e1, e2);
		}

	}
	
	public static class CompDeclared extends ViewerSorter {

		public int compare(Viewer viewer, Object e1, Object e2) {
			if (e1 instanceof CachedASTNode && e2 instanceof CachedASTNode) 
				return ((CachedASTNode) e1).declareOrder() - ((CachedASTNode) e2).declareOrder();
			return super.compare(viewer, e1, e2);
		}

	}
	
}