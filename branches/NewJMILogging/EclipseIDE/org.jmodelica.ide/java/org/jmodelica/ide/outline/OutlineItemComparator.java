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
import org.jmodelica.ide.preferences.ModelicaPreferences;
import org.jmodelica.modelica.compiler.ASTNode;
import org.jmodelica.modelica.compiler.BaseClassDecl;
import org.jmodelica.modelica.compiler.InstClassDecl;

public class OutlineItemComparator extends ViewerSorter implements IPreferenceChangeListener {

	private static Map<String,ViewerSorter> COMPARATORS = new HashMap<String,ViewerSorter>();
	static {
		COMPARATORS.put(IDEConstants.SORT_ALPHA, new CompAlpha());
		COMPARATORS.put(IDEConstants.SORT_DECLARED, new CompDeclared());
	}
	
	private ViewerSorter cmp;
	
	public OutlineItemComparator() {
		updateComparator();
		ModelicaPreferences.INSTANCE.addListener(this);
	}
	
	public int category(Object element) {
		if (element instanceof ASTNode<?>)
			return ((ASTNode<?>) element).outlineCategory();
		if (element instanceof LoadedLibraries) 
			return -5;
		return super.category(element);
	}

	@SuppressWarnings("unchecked")
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
		cmp = COMPARATORS.get(ModelicaPreferences.INSTANCE.get(IDEConstants.PREFERENCE_EXPLORER_SORT_ORDER));
	}

	public static class CompAlpha extends ViewerSorter {

		public int compare(Viewer viewer, Object e1, Object e2) {
			// TODO: Move to an attribute
			if (e1 instanceof InstClassDecl)
				e1 = ((InstClassDecl) e1).getClassDecl();
			if (e2 instanceof InstClassDecl)
				e2 = ((InstClassDecl) e2).getClassDecl();
			if (e1 instanceof BaseClassDecl && e2 instanceof BaseClassDecl) {
				String id1 = ((BaseClassDecl) e1).getName().getID();
				String id2 = ((BaseClassDecl) e2).getName().getID();
				return getComparator().compare(id1, id2);
			}
			return super.compare(viewer, e1, e2);
		}

	}
	
	public static class CompDeclared extends ViewerSorter {

		public int compare(Viewer viewer, Object e1, Object e2) {
			if (e1 instanceof ASTNode && e2 instanceof ASTNode) 
				return ((ASTNode) e1).declareOrder() - ((ASTNode) e2).declareOrder();
			return super.compare(viewer, e1, e2);
		}

	}
	
}