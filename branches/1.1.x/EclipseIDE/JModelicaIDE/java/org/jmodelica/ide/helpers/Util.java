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
package org.jmodelica.ide.helpers;

import java.io.File;
import java.net.URI;
import java.util.Arrays;
import java.util.Collection;
import java.util.Iterator;
import java.util.LinkedList;
import java.util.List;
import java.util.regex.Pattern;

import org.eclipse.core.resources.IContainer;
import org.eclipse.core.resources.IFolder;
import org.eclipse.core.resources.IMarker;
import org.eclipse.core.resources.IResource;
import org.eclipse.core.runtime.CoreException;
import org.eclipse.core.runtime.Path;
import org.eclipse.jface.viewers.ISelection;
import org.eclipse.jface.viewers.IStructuredSelection;
import org.eclipse.ui.IEditorPart;
import org.eclipse.ui.IWorkbenchPage;
import org.eclipse.ui.PartInitException;
import org.eclipse.ui.ide.IDE;
import org.jastadd.plugin.compiler.ast.IError;
import org.jmodelica.ide.IDEConstants;
import org.jmodelica.ide.editor.Editor;
import org.jmodelica.modelica.compiler.ASTNode;
import org.jmodelica.modelica.compiler.Access;
import org.jmodelica.modelica.compiler.Dot;
import org.jmodelica.modelica.compiler.ParseAccess;

public class Util {
	public static String DELIM = "|";
	
	public static String implode(String[] arr) {
		return implode(DELIM, arr);
	}
	
	public static String[] explode(String str) {
		return explode(DELIM, str);
	}
	
	public static String implode(String delim, String[] arr) {
		StringBuilder str = new StringBuilder();
		for (int i = 0; i < arr.length; i++) {
			if (i > 0)
				str.append(delim);
			str.append(arr[i]);
		}
		return str.toString();
	}
	
	public static String implode(String delim, Iterable<?> objs) {
	    List<String> list = 
	        new LinkedList<String>();
	    for (Object o : objs) 
	        list.add(o.toString());
	    return implode(delim, list.toArray(new String[] {}));
	}
	
	public static String[] explode(String delim, String str) {
		return str.split(Pattern.quote(delim));
	}
	
	public static Object getSelected(ISelection sel) {
		Object elem = null;
		if (!sel.isEmpty()) {
			IStructuredSelection sel2 = (IStructuredSelection) sel;
			if (sel2.size() == 1) {
				elem = sel2.getFirstElement();
			}
		}
		return elem;
	}

	public static void openAndSelect(IWorkbenchPage page, Object elem) {
		if (elem instanceof ASTNode<?>) {
			ASTNode<?> node = (ASTNode<?>) elem;
			IEditorPart editor = null;
			try {
				URI uri = new File(node.containingFileName()).toURI();
				editor = IDE.openEditor(page, uri, IDEConstants.EDITOR_ID, true);
			} catch (PartInitException e) {
			}
			if (editor instanceof Editor) 
				((Editor) editor).selectNode(node);
		}
	}

	public static final String ERROR_MARKER_ID = IDEConstants.ERROR_MARKER_ID;

	public static void deleteErrorMarkers(IResource res) {
		try {
			res.deleteMarkers(ERROR_MARKER_ID, false, IResource.DEPTH_ONE);
		} catch (CoreException e) {
		}
	}
	
	public static void addErrorMarker(IResource resource, IError error) {
		try {
			IMarker marker = resource.createMarker(ERROR_MARKER_ID);

			String message = error.getMessage();
			int severity = error.getSeverity();
			int line = error.getLine();
			int startOffset = error.getStartOffset();
			int endOffset = error.getEndOffset();

			marker.setAttribute(IMarker.MESSAGE, message);
			marker.setAttribute(IMarker.SEVERITY, severity);
			if (line < 0)
				line = 1;
			marker.setAttribute(IMarker.LINE_NUMBER, line);
			if (startOffset > 0 && endOffset > 0 && endOffset > startOffset) {
				marker.setAttribute(IMarker.CHAR_START, startOffset);
				marker.setAttribute(IMarker.CHAR_END, endOffset);
			}
		} catch (CoreException e) {
			e.printStackTrace();
		}
	}

	public static String listString(Collection<?> list, String pre, String suff, String sep, String and) {
		StringBuilder buf = new StringBuilder();
		int i = 0, last = list.size() - 1;
		for (Object o : list) {
			if (i > 0) {
				if (i < last)
					buf.append(sep);
				else 
					buf.append(and);
			}
			buf.append(pre);
			buf.append(o);
			buf.append(suff);
		}
		return buf.toString();
	}
	
	private static boolean isLibrary(IContainer lib) {
		return lib instanceof IFolder && lib.exists(new Path(IDEConstants.PACKAGE_FILE));
	}
	
	public static boolean isInLibrary(IResource file) {
		return isLibrary(file.getParent());
	}
	
	public static String getLibraryPath(IResource file) {
		IContainer parent = file.getParent();
		while (isLibrary(parent.getParent())) 
			parent = parent.getParent();
		return parent.findMember(IDEConstants.PACKAGE_FILE).getLocation().toOSString();
	}
	
	/**
	 * @see <code>is(E e)</code>
	 * @author philip
	 */
	public static class Among<E> {
	    private E e; 
	    public Among(E e) {
	        this.e = e;
	    }
	    public boolean among(E... list) {
	        return Arrays.asList(list).contains(e);
	    }
	    public boolean notAmong(E...list) {
	        return !among(list);
	    }
	}
	
	/**
	 * Create an {@link Among}-object, supporting queries on the form: <br><br>
	 * Util.is(E e).among(E... list_of_objects);
	 * @param e element to query for membership of
	 * @return {@link Among}-object to perform membership queries.
	 */
	public static <E> Among<E> is(E e) {
	    return new Among<E>(e);
	}
	
	public static <E> List<E> fromIterable(Iterable<E> iterable) {
	    return fromIterator(iterable.iterator());
	}
	
	public static <E> List<E> fromIterator(Iterator<E> iterator) {
	    List<E> list = new LinkedList<E>();
	    while(iterator.hasNext())
	        list.add(iterator.next());
	    return list;
	}
	
    public static String qualifyName(String prefix, String suffix) {
        return prefix.equals("") 
            ? suffix
            : prefix + "." + suffix;
    }
    
    /**
     * 
     * Create a right-recursive dot access from a list of identifiers,
     * or a simple access if parts.length == 1.
     *  
     * @param parts parts of the qualified name
     * @return access created from parts 
     */
    public static Access createDotAccess(String id) {
        return createDotAccess(id.split("\\."), 0); 
    }

    private static Access createDotAccess(String[] parts, int i) {

        Access res = new ParseAccess();
        res.setID(parts[i]);

        return i == parts.length - 1 
            ? res  
            : new Dot("", res, createDotAccess(parts, i + 1));
        
    }

}
