package org.jmodelica.devel.launch;

import static org.eclipse.debug.ui.IDebugUIConstants.ATTR_PRIVATE;
import static org.eclipse.jdt.launching.IJavaLaunchConfigurationConstants.ATTR_JRE_CONTAINER_PATH;
import static org.eclipse.jdt.launching.IJavaLaunchConfigurationConstants.ATTR_PROJECT_NAME;
import static org.eclipse.jdt.launching.IJavaLaunchConfigurationConstants.ATTR_VM_ARGUMENTS;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collection;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.concurrent.CountDownLatch;

import org.eclipse.core.resources.IFile;
import org.eclipse.core.resources.IResource;
import org.eclipse.core.resources.ResourcesPlugin;
import org.eclipse.core.runtime.CoreException;
import org.eclipse.core.runtime.IProgressMonitor;
import org.eclipse.core.runtime.IStatus;
import org.eclipse.core.runtime.NullProgressMonitor;
import org.eclipse.core.runtime.OperationCanceledException;
import org.eclipse.core.runtime.Status;
import org.eclipse.core.runtime.jobs.IJobManager;
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
import org.eclipse.jdt.core.IJavaProject;
import org.eclipse.jdt.launching.IVMInstall;
import org.eclipse.jdt.launching.JavaRuntime;
import org.eclipse.ui.IWorkbench;
import org.eclipse.ui.IWorkbenchWindow;
import org.eclipse.ui.PlatformUI;
import org.jmodelica.devel.setup.ProjectDef;

public class Launch {
	
	private CountDownLatch latch = new CountDownLatch(1);

	private static final String VM_ARGS = "-Xmx1g";
	
	private static final String ATTR_LOCATION = "org.eclipse.ui.externaltools.ATTR_LOCATION";
	private static final String MAPPED_RESOURCE_TYPES = "org.eclipse.debug.core.MAPPED_RESOURCE_TYPES";
	private static final String MAPPED_RESOURCE_PATHS = "org.eclipse.debug.core.MAPPED_RESOURCE_PATHS";
	private ILaunchConfigurationWorkingCopy wc;
	private ProjectDef proj;
	private List<Runnable> completedActions = new ArrayList<Runnable>();
	private boolean temporary;

	public Launch(ProjectDef proj, String name, String type, boolean temporary) throws CoreException {
		this.proj = proj;
		ILaunchManager lm = DebugPlugin.getDefault().getLaunchManager();
		ILaunchConfigurationType lct = lm.getLaunchConfigurationType(type);
		wc = lct.newInstance(null, name);
		wc.setAttribute(ATTR_PRIVATE, temporary);
		wc.setAttribute(ATTR_PROJECT_NAME, proj.getName());
		wc.setAttribute(ATTR_JRE_CONTAINER_PATH, vmString(proj.getVM()));
		wc.setAttribute(ATTR_VM_ARGUMENTS, VM_ARGS);
		this.temporary = temporary;
	}
	
	public void addCompletedAction(Runnable action) {
		completedActions.add(action);
	}

	public void	setFiles(String... paths) {
		ArrayList<String> pathList = new ArrayList<String>();
		List<String> types = new ArrayList<String>();
		for (String path : paths) {
			pathList.add(proj.getIProject().getFullPath().append(path).toString());
			types.add("1");
		}
		setAttribute(ATTR_LOCATION, String.format("${workspace_loc:%s}", pathList.get(0)));
		setAttribute(MAPPED_RESOURCE_PATHS, pathList);
		setAttribute(MAPPED_RESOURCE_TYPES, types);
	}

	public void setAttribute(String name, boolean value) {
		wc.setAttribute(name, value);
	}

	public void setAttribute(String name, int value) {
		wc.setAttribute(name, value);
	}

	public void setAttribute(String name, List value) {
		wc.setAttribute(name, value);
	}

	public void setAttribute(String name, Map value) {
		wc.setAttribute(name, value);
	}

	public void setAttribute(String name, Set value) {
		wc.setAttribute(name, value);
	}

	public void setAttribute(String name, String value) {
		wc.setAttribute(name, value);
	}

	public void execute() throws CoreException {
		System.out.println("Launch.execute(): start");
		start();
		try {
			System.out.println("Launch.execute(): waiting");
			latch.await();
			System.out.println("Launch.execute(): finished waiting");
		} catch (InterruptedException e) {
			// OK, then, we'll return before we're done
			System.out.println("Launch.execute(): exception");
		}
		System.out.println("Launch.execute(): done");
	}

	public void start() throws CoreException {
		ILaunchManager lm = DebugPlugin.getDefault().getLaunchManager();
		lm.addLaunchListener(new Cleanup(completedActions, lm));
		ILaunchConfiguration lc = wc.doSave();
		if (temporary)
			addCompletedAction(new RemoveLaunchConfiguration(lc));
		System.out.println("Launch.start(): waiting for builds");
		waitForBuilds();
		System.out.println("Launch.start(): launching");
		DebugUITools.launch(lc, ILaunchManager.RUN_MODE);
	}

	private void waitForBuilds() {
		try {
			final IJobManager jobManager = Job.getJobManager();
			jobManager.join(ResourcesPlugin.FAMILY_MANUAL_BUILD, new NullProgressMonitor());
			jobManager.join(ResourcesPlugin.FAMILY_AUTO_BUILD, new NullProgressMonitor());
		} catch (OperationCanceledException e1) {
		} catch (InterruptedException e1) {
		}
	}

	private String vmString(IVMInstall vm) {
		return ATTR_JRE_CONTAINER_PATH + "/" + vm.getVMInstallType().getId() + "/" + vm.getName();
	}

	
	private class Cleanup extends Job implements ILaunchesListener2 {
		
		private Collection<Runnable> actions;
		private ILaunchManager lm;
		private ILaunch launch;

		public Cleanup(Collection<Runnable> actions, ILaunchManager lm) {
			super("Cleaning up after launch");
			setSystem(true);
			this.actions = actions;
			this.lm = lm;
		}

		public void launchesRemoved(ILaunch[] launches) {}

		public void launchesAdded(ILaunch[] launches) {
			launch = launches[0];
		}

		public void launchesChanged(ILaunch[] launches) {}

		public void launchesTerminated(ILaunch[] launches) {
			for (ILaunch l : launches) {
				if (l.equals(launch)) {
					System.out.println("Cleanup.launchesTerminated(): scheduling");
					schedule();
					return;
				}
			}
		}

		protected IStatus run(IProgressMonitor monitor) {
			System.out.println("Cleanup.job(): start");
			lm.removeLaunchListener(this);
			for (Runnable action : actions) {
				try {
					action.run();
				} catch (Exception e) {
					// Can't really do anything here
				}
			}
			System.out.println("Cleanup.job(): release latch");
			latch.countDown();
			System.out.println("Cleanup.job(): done");
			return Status.OK_STATUS;
		}

	}
	
}
