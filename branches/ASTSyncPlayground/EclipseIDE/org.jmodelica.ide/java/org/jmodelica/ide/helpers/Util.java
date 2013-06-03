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
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.InputStreamReader;
import java.io.Reader;
import java.io.UnsupportedEncodingException;
import java.net.URI;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collection;
import java.util.Iterator;
import java.util.List;
import java.util.regex.Pattern;

import org.eclipse.core.resources.IContainer;
import org.eclipse.core.resources.IFile;
import org.eclipse.core.resources.IFolder;
import org.eclipse.core.resources.IMarker;
import org.eclipse.core.resources.IProject;
import org.eclipse.core.resources.IResource;
import org.eclipse.core.runtime.CoreException;
import org.eclipse.core.runtime.Path;
import org.eclipse.jface.viewers.ISelection;
import org.eclipse.jface.viewers.IStructuredSelection;
import org.eclipse.jface.viewers.StructuredSelection;
import org.eclipse.ui.IEditorPart;
import org.eclipse.ui.IWorkbenchPage;
import org.eclipse.ui.IWorkbenchPart;
import org.eclipse.ui.IWorkbenchPartReference;
import org.eclipse.ui.IWorkbenchWindow;
import org.eclipse.ui.PartInitException;
import org.eclipse.ui.ide.IDE;
import org.eclipse.ui.part.ISetSelectionTarget;
import org.jastadd.ed.core.model.IASTEditor;
import org.jastadd.ed.core.service.errors.IError;
import org.jmodelica.ide.IDEConstants;
import org.jmodelica.ide.compiler.ModelicaPreferences;
import org.jmodelica.ide.sync.CachedASTNode;
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
		ArrayList<String> list = new ArrayList<String>();
		for (Object o : objs)
			list.add(o.toString());
		return implode(delim, list.toArray(new String[0]));
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

	/**
	 * public static void openAndSelect(IWorkbenchPage page, Object elem) { if
	 * (elem instanceof CachedASTNode) { CachedASTNode node = (CachedASTNode)
	 * elem; IEditorPart editor = null; try { URI uri = new
	 * File(node.containingFileName()).toURI();
	 * Editor.nextReadOnly(node.isInLibrary()); editor = IDE .openEditor(page,
	 * uri, IDEConstants.EDITOR_ID, true); Editor.nextReadOnly(false); } catch
	 * (PartInitException e) { } if (editor instanceof Editor && node != null)
	 * ((Editor) editor).selectNode(true, node.containingFileName(),
	 * node.getSelectionNodeOffset(), node.getSelectionNodeLength()); } }
	 */

	private static boolean ISNEXTREADONLY = false;

	public static boolean nextReadOnly() {
		return ISNEXTREADONLY;
	}

	public static void openAndSelect(IWorkbenchPage page, Object elem) {
		if (elem instanceof CachedASTNode) {
			CachedASTNode node = (CachedASTNode) elem;
			IEditorPart editor = null;
			try {
				URI uri = new File(node.containingFileName()).toURI();
				ISNEXTREADONLY = node.isInLibrary();
				editor = IDE
						.openEditor(page, uri, IDEConstants.EDITOR_ID, true);
				ISNEXTREADONLY = false;
			} catch (PartInitException e) {
				e.printStackTrace();
			}
			if (editor instanceof IASTEditor && node != null)
				((IASTEditor) editor).selectNode(true,
						node.containingFileName(),
						node.getSelectionNodeOffset(),
						node.getSelectionNodeLength());
		}
	}

	public static void deleteErrorMarkers(IResource res, boolean clearSemantic) {
		try {
			if (clearSemantic)
				res.deleteMarkers(IDEConstants.ERROR_MARKER_ID, true,
						IResource.DEPTH_ONE);
			else
				res.deleteMarkers(IDEConstants.ERROR_MARKER_SYNTACTIC_ID,
						false, IResource.DEPTH_ONE);
		} catch (CoreException e) {
		}
	}

	private static final String[] ATTRIBUTES_WITH_OFFSET = new String[] {
			IMarker.MESSAGE, IMarker.SEVERITY, IMarker.LINE_NUMBER,
			IMarker.CHAR_START, IMarker.CHAR_END };
	private static final String[] ATTRIBUTES_NO_OFFSET = new String[] {
			IMarker.MESSAGE, IMarker.SEVERITY, IMarker.LINE_NUMBER };

	public static void addErrorMarker(IResource resource, IError error) {
		try {
			String type = IDEConstants.ERROR_MARKER_SYNTACTIC_ID;
			if (error.getKind() == IError.Kind.SEMANTIC)
				type = IDEConstants.ERROR_MARKER_SEMANTIC_ID;
			if (error.getSeverity() == IError.Severity.WARNING)
				type = IDEConstants.ERROR_MARKER_WARNING_ID;
			IMarker marker = resource.createMarker(type);

			if (marker == null)
				return;

			String message = error.getMessage();
			Integer severity = error.getSeverity().value;
			Integer line = error.getStartLine();
			Integer startOffset = error.getStartOffset();
			Integer endOffset = error.getEndOffset();
			if (line < 0)
				line = 1;

			Object[] vals;
			String[] keys;
			if (startOffset >= 0 && endOffset > startOffset) {
				keys = ATTRIBUTES_WITH_OFFSET;
				vals = new Object[] { message, severity, line, startOffset,
						endOffset };
			} else {
				keys = ATTRIBUTES_NO_OFFSET;
				vals = new Object[] { message, severity, line };
			}
			marker.setAttributes(keys, vals);
		} catch (CoreException e) {
		}
	}

	public static String listString(Collection<?> list, String pre,
			String suff, String sep, String and) {
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
		return lib instanceof IFolder
				&& lib.exists(new Path(IDEConstants.PACKAGE_FILE));
	}

	public static boolean isInLibrary(IResource file) {
		return isLibrary(file.getParent());
	}

	public static String getLibraryPath(IResource file) {
		IContainer parent = file.getParent();
		while (isLibrary(parent.getParent()))
			parent = parent.getParent();
		return parent.findMember(IDEConstants.PACKAGE_FILE).getLocation()
				.toOSString();
	}

	public static Reader fileReader(IFile file) throws FileNotFoundException {
		FileInputStream stream = new FileInputStream(file.getRawLocation()
				.toOSString());
		try {
			return new InputStreamReader(stream, file.getCharset());
		} catch (UnsupportedEncodingException e) {
		} catch (CoreException e) {
		}
		return new InputStreamReader(stream);
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

		public boolean notAmong(E... list) {
			return !among(list);
		}
	}

	/**
	 * Create an {@link Among}-object, supporting queries on the form: <br>
	 * <br>
	 * Util.is(E e).among(E... list_of_objects);
	 * 
	 * @param e
	 *            element to query for membership of
	 * @return {@link Among}-object to perform membership queries.
	 */
	public static <E> Among<E> is(E e) {
		return new Among<E>(e);
	}

	public static <E> List<E> listFromIterable(Iterable<E> iterable) {
		return listFromIterator(iterable.iterator());
	}

	public static <E> List<E> listFromIterator(Iterator<E> iterator) {
		List<E> list = new ArrayList<E>();
		while (iterator.hasNext())
			list.add(iterator.next());
		return list;
	}

	public static String qualifyName(String prefix, String suffix) {
		return prefix.equals("") ? suffix : prefix + "." + suffix;
	}

	/**
	 * Create a dot access from a list of identifiers, or a simple access if
	 * parts.length == 1.
	 * 
	 * @param parts
	 *            parts of the qualified name
	 * @return access created from parts
	 */
	public static Access createDotAccess(String id) {
		String[] parts = id.split("\\.");
		Access[] accessParts = new Access[parts.length];
		for (int i = 0; i < parts.length; i++)
			accessParts[i] = new ParseAccess(parts[i]);
		if (accessParts.length == 1)
			return accessParts[0];
		else
			return new Dot(new org.jmodelica.modelica.compiler.List<Access>(
					accessParts));
	}

	/**
	 * Attempts to select and reveal the specified resource in all parts within
	 * the supplied workbench window's active page.
	 * <p>
	 * Checks all parts in the active page to see if they implement
	 * <code>ISetSelectionTarget</code>, either directly or as an adapter. If
	 * so, tells the part to select and reveal the specified resource.
	 * </p>
	 * 
	 * @param resource
	 *            the resource to be selected and revealed
	 * @param window
	 *            the workbench window to select and reveal the resource
	 * 
	 * @see ISetSelectionTarget
	 */
	public static void selectAndReveal(IResource resource,
			IWorkbenchWindow window) {
		// validate the input
		if (window == null || resource == null) {
			return;
		}
		IWorkbenchPage page = window.getActivePage();
		if (page == null) {
			return;
		}

		// get all the view and editor parts
		List<IWorkbenchPart> parts = new ArrayList<IWorkbenchPart>();
		IWorkbenchPartReference refs[] = page.getViewReferences();
		for (int i = 0; i < refs.length; i++) {
			IWorkbenchPart part = refs[i].getPart(false);
			if (part != null) {
				parts.add(part);
			}
		}
		refs = page.getEditorReferences();
		for (int i = 0; i < refs.length; i++) {
			if (refs[i].getPart(false) != null) {
				parts.add(refs[i].getPart(false));
			}
		}

		final ISelection selection = new StructuredSelection(resource);
		Iterator<IWorkbenchPart> itr = parts.iterator();
		while (itr.hasNext()) {
			IWorkbenchPart part = (IWorkbenchPart) itr.next();

			// get the part's ISetSelectionTarget implementation
			ISetSelectionTarget target = null;
			if (part instanceof ISetSelectionTarget) {
				target = (ISetSelectionTarget) part;
			} else {
				target = (ISetSelectionTarget) part
						.getAdapter(ISetSelectionTarget.class);
			}

			if (target != null) {
				// select and reveal resource
				final ISetSelectionTarget finalTarget = target;
				window.getShell().getDisplay().asyncExec(new Runnable() {
					public void run() {
						finalTarget.selectReveal(selection);
					}
				});
			}
		}
	}

	public static boolean isModelicaFile(IFile file) {
		return IDEConstants.MODELICA_FILE_EXT.equals(file.getFileExtension());
	}

	public static boolean isModelicaProject(IProject project) {
		try {
			return project != null && project.hasNature(IDEConstants.NATURE_ID);
		} catch (CoreException e) {
			return false;
		}
	}

	public static String getModelicaPath(IProject proj) {
		return ModelicaPreferences.INSTANCE.get(proj, IDEConstants.PREFERENCE_LIBRARIES_ID);
	}

	public static void setModelicaPath(IProject proj, String path) {
		ModelicaPreferences.INSTANCE.set(proj, IDEConstants.PREFERENCE_LIBRARIES_ID, path);
	}
}
