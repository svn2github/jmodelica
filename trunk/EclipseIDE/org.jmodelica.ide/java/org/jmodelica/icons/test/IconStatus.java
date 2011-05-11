package org.jmodelica.icons.test;

import java.util.ArrayList;

import org.eclipse.ui.IWorkbench;
import org.eclipse.ui.IWorkbenchPage;
import org.eclipse.ui.IWorkbenchWindow;
import org.eclipse.ui.PlatformUI;
import org.jastadd.plugin.ui.view.AbstractBaseContentOutlinePage;
import org.jmodelica.ide.editor.Editor;
import org.jmodelica.modelica.compiler.ClassDecl;

public abstract class IconStatus {
	private static ArrayList<ClassDecl> classesWithFinishedIcons = new ArrayList<ClassDecl>();
	private static ArrayList<ClassDecl> classesWithStartedIcons = new ArrayList<ClassDecl>();
	public static int nbrJobs = 0;
	public static boolean busy = false;
	
	public static boolean hasFinishedIcon(ClassDecl decl) {
		return classesWithFinishedIcons.contains(decl);
	}
	
	public static boolean hasStartedIcon(ClassDecl decl) {
		return classesWithStartedIcons.contains(decl);
	}
	
	public static void setHasStartedIcon(ClassDecl decl) {
		classesWithStartedIcons.add(decl);
	} 
	
	public static void setHasFinishedIcon(ClassDecl decl) {
		classesWithStartedIcons.remove(decl);
		classesWithFinishedIcons.add(decl);
	}
	
	public static void cancelIcon(ClassDecl decl) {
		classesWithStartedIcons.remove(decl);
	}
	
	public static void addHasStartedIcon(ClassDecl decl) {
		classesWithStartedIcons.add(decl);
	}

	public static void removeHasStartedIcon(ClassDecl decl) {
		classesWithStartedIcons.remove(decl);
	}
	
	public static AbstractBaseContentOutlinePage getSourceOutline() {
		Editor editor = getEditor();
		if (editor != null) {
			return (AbstractBaseContentOutlinePage)getEditor().getSourceOutlinePage();
		}
		return null;
	}

	public static AbstractBaseContentOutlinePage getInstanceOutline() {
		Editor editor = getEditor();
		if (editor != null) {
			return (AbstractBaseContentOutlinePage)getEditor().getInstanceOutlinePage();
		}
		return null;
	}
	
	private static Editor getEditor() {
		IWorkbench workbench = PlatformUI.getWorkbench();
		if (workbench == null) {
			System.out.println("Workbench is null.");
			return null;
		}
		IWorkbenchWindow window = workbench.getActiveWorkbenchWindow();
		if (window == null) {
			System.out.println("WorkbenchWindow is null.");
			return null;
		}
		IWorkbenchPage page = window.getActivePage();
		if (page == null) {
			System.out.println("WorkbenchPage is null.");
			return null;
		}
		Editor editor = ((Editor)(page.getActiveEditor()));
		if (editor == null) {
			System.out.println("Editor is null.");
		}
		return editor;
	}
}
