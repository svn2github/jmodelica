package org.jmodelica.ide.helpers;

import java.io.File;
import java.net.URI;
import java.util.regex.Pattern;

import org.eclipse.jface.viewers.ISelection;
import org.eclipse.jface.viewers.IStructuredSelection;
import org.eclipse.ui.IEditorPart;
import org.eclipse.ui.IWorkbenchPage;
import org.eclipse.ui.PartInitException;
import org.eclipse.ui.ide.IDE;
import org.jmodelica.ast.ASTNode;
import org.jmodelica.ide.Constants;
import org.jmodelica.ide.editor.Editor;

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
		if (elem instanceof ASTNode) {
			ASTNode node = (ASTNode) elem;
			IEditorPart editor = null;
			try {
				URI uri = new File(node.containingFileName()).toURI();
				editor = IDE.openEditor(page, uri, Constants.EDITOR_ID, true);
			} catch (PartInitException e) {
			}
			if (editor instanceof Editor) 
				((Editor) editor).selectNode(node);
		}
	}

}
