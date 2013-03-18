package org.jmodelica.devel.addtest;


import java.util.Collection;
import java.util.Random;

import org.eclipse.core.commands.AbstractHandler;
import org.eclipse.core.commands.ExecutionEvent;
import org.eclipse.core.commands.ExecutionException;
import org.eclipse.core.expressions.EvaluationContext;
import org.eclipse.core.resources.IFile;
import org.eclipse.core.resources.IResource;
import org.eclipse.core.runtime.CoreException;
import org.eclipse.core.runtime.IProgressMonitor;
import org.eclipse.core.runtime.IStatus;
import org.eclipse.core.runtime.Status;
import org.eclipse.core.runtime.jobs.Job;
import org.eclipse.debug.core.DebugPlugin;
import org.eclipse.debug.core.ILaunch;
import org.eclipse.debug.core.ILaunchConfiguration;
import org.eclipse.debug.core.ILaunchConfigurationType;
import org.eclipse.debug.core.ILaunchConfigurationWorkingCopy;
import org.eclipse.debug.core.ILaunchManager;
import org.eclipse.debug.core.ILaunchesListener;
import org.eclipse.debug.core.ILaunchesListener2;
import org.eclipse.debug.ui.DebugUITools;
import org.eclipse.debug.ui.IDebugUIConstants;
import org.eclipse.jface.dialogs.MessageDialog;
import org.eclipse.jface.text.TextSelection;
import org.eclipse.swt.SWT;
import org.eclipse.swt.widgets.Shell;
import org.eclipse.ui.IWorkbench;
import org.eclipse.ui.IWorkbenchPart;
import org.eclipse.ui.PlatformUI;
import org.jmodelica.devel.Constants;
import org.jmodelica.devel.launch.Launch;
import org.jmodelica.devel.launch.Refresh;
import org.jmodelica.devel.setup.Setup;
import org.jmodelica.ide.helpers.hooks.IASTEditor;
import org.jmodelica.modelica.compiler.ClassDecl;

import static org.eclipse.jdt.launching.IJavaLaunchConfigurationConstants.ID_JAVA_APPLICATION;
import static org.eclipse.jdt.launching.IJavaLaunchConfigurationConstants.ATTR_MAIN_TYPE_NAME;
import static org.eclipse.jdt.launching.IJavaLaunchConfigurationConstants.ATTR_PROGRAM_ARGUMENTS;
import static org.eclipse.jdt.launching.IJavaLaunchConfigurationConstants.ATTR_PROJECT_NAME;
import static org.eclipse.jdt.launching.IJavaLaunchConfigurationConstants.ATTR_VM_ARGUMENTS;
import static org.eclipse.debug.ui.IDebugUIConstants.ATTR_PRIVATE;


public class AddTestHandler extends AbstractHandler {

	private static final String FAIL_MSG = "Failed to run TestAnnotationizer";
	private static final String JVM_ARGS = "-Xmx1g";
	private static final String PROJECT_NAME = "JModelica";
	private static final String CLASS_TO_RUN = "org.jmodelica.util.TestAnnotationizer";
	private static final String LAUNCH_NAME = "__TestAnnotationizer_temp_%x";
	
	private static final Random rnd = new Random();

	public AddTestHandler() {
		System.out.println("=================== handler created");
	}

	public Object execute(ExecutionEvent event) throws ExecutionException {
		String typeStr = event.getParameter(Constants.ADD_TEST_TYPE_PARAM_ID);
		String offset = event.getParameter(Constants.ADD_TEST_OFFSET_PARAM_ID);
		TestType type = parseType(typeStr);

		IWorkbench workbench = PlatformUI.getWorkbench();
		ClassDecl cl = findClass(workbench, offset);
		if (cl == null)
			return null;
		
		String name = cl.qualifiedName();
		String fileName = cl.fileName();
		IFile file = cl.getDefinition().getFile();
		String launchName = String.format(LAUNCH_NAME, rnd.nextInt());
		Shell shell = workbench.getDisplay().getActiveShell();
		String data = getData(type, shell);
		if (type != null && (data != null || !type.hasData())) {
			String args = type.args(fileName, name, data);
			try {
				Launch l = new Launch(Setup.JMODELICA_PROJ, launchName, ID_JAVA_APPLICATION, true);
				l.setAttribute(ATTR_MAIN_TYPE_NAME, CLASS_TO_RUN);
				l.setAttribute(ATTR_PROGRAM_ARGUMENTS, args);
				l.addCompletedAction(new Refresh(file));
				l.start();
			} catch (CoreException e1) {
				return failMessage();
			}
		}
		
		return null;
	}

	public TestType parseType(String typeStr) {
		TestType type = null; 
		if (typeStr != null) {
			try {
				type = TestType.valueOf(TestType.class, typeStr);
			} catch (IllegalArgumentException e) {
				// Treat same as none given
			}
		}
		return type;
	}

	private Object failMessage() {
		Shell shell = PlatformUI.getWorkbench().getDisplay().getActiveShell();
		MessageDialog.open(MessageDialog.INFORMATION, shell, "Add Test", FAIL_MSG, SWT.NONE);
		return null;
	}

	private String getData(TestType type, Shell shell) {
		String data = "";
		if (type != null && type.hasData()) {
			DataDialog dlg = new DataDialog(shell, type);
			data = dlg.open();
			if (data != null)
				data = "-d=" + data;
		}
		return data;
	}

	private ClassDecl findClass(IWorkbench workbench, String offset) {
		ClassDecl cl = null;
		IWorkbenchPart part = workbench.getActiveWorkbenchWindow().getActivePage().getActivePart();
		if (part instanceof IASTEditor) {
			IASTEditor editor = (IASTEditor) part;
			int off;
			try {
				off = Integer.parseInt(offset);
			} catch (NumberFormatException e) {
				off = -1;
			}
			cl = (off >= 0) ? editor.getClassContaining(off, 0) : editor.getClassContainingCursor();
		}
		return cl;
	}

}
