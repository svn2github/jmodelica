package org.jmodelica.ide.helpers;

import java.io.File;

import org.eclipse.core.resources.IFile;
import org.eclipse.core.resources.IProject;
import org.eclipse.core.resources.IWorkspaceRoot;
import org.eclipse.core.resources.ResourcesPlugin;
import org.eclipse.core.runtime.CoreException;
import org.eclipse.jface.dialogs.MessageDialog;
import org.eclipse.jface.wizard.WizardDialog;
import org.eclipse.swt.widgets.Shell;
import org.eclipse.ui.IEditorDescriptor;
import org.eclipse.ui.INewWizard;
import org.eclipse.ui.IWorkbench;
import org.eclipse.ui.IWorkbenchPage;
import org.eclipse.ui.PlatformUI;
import org.eclipse.ui.part.FileEditorInput;
import org.jastadd.ed.core.model.IASTEditor;
import org.jmodelica.ide.IDEConstants;

public class EclipseUtil {

	public static Maybe<IASTEditor> getModelicaEditorForFile(IFile file) {

		// cuteness overload

		IWorkbenchPage page = PlatformUI.getWorkbench()
				.getActiveWorkbenchWindow().getActivePage();

		IEditorDescriptor desc = PlatformUI.getWorkbench().getEditorRegistry()
				.getDefaultEditor(file.getName());

		try {

			return Maybe.Just((IASTEditor) page.openEditor(new FileEditorInput(
					file), desc.getId()));

		} catch (Exception e) {
			e.printStackTrace();
			return Maybe.<IASTEditor> Nothing();
		}
	}

	public static Maybe<IFile> getFileForPath(String path) {

		if (path == null)
			return Maybe.<IFile> Nothing();

		IWorkspaceRoot workspace = ResourcesPlugin.getWorkspace().getRoot();

		// file inside workspace?
		// TODO: If file is outside workspace, add linked resource?
		if (!path.startsWith(workspace.getRawLocation().toOSString()))
			return Maybe.<IFile> Nothing();

		// find files matching URI
		IFile candidates[] = workspace.findFilesForLocationURI(new File(path)
				.toURI());

		// Just take first candidate if several possible.
		// We need to select one in some way, and the first is as good as any.
		return candidates.length > 0 ? Maybe.Just(candidates[0]) : Maybe
				.<IFile> Nothing();
	}

	public static void openNewWizard(INewWizard wizard) {
		IWorkbench workbench = PlatformUI.getWorkbench();
		Shell shell = workbench.getDisplay().getActiveShell();
		wizard.init(workbench, null);
		WizardDialog wd = new WizardDialog(shell, wizard);
		wd.setTitle(wizard.getWindowTitle());
		wd.open();
	}

	public static boolean askUser(String title, String question) {
		Shell shell = PlatformUI.getWorkbench().getDisplay().getActiveShell();
		return MessageDialog.openQuestion(shell, title, question);
	}

	public static boolean isModelicaProject(IProject project) {
		try {
			return project != null && project.hasNature(IDEConstants.NATURE_ID);
		} catch (CoreException e) {
			return false;
		}
	}

}
