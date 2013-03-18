package org.jmodelica.devel.setup;

import static org.eclipse.ant.launching.IAntLaunchConstants.ATTR_ANT_TARGETS;
import static org.eclipse.ant.launching.IAntLaunchConstants.ATTR_DEFAULT_VM_INSTALL;
import static org.eclipse.ant.launching.IAntLaunchConstants.ID_ANT_LAUNCH_CONFIGURATION_TYPE;
import static org.eclipse.jdt.launching.IJavaLaunchConfigurationConstants.ATTR_SOURCE_PATH_PROVIDER;
import static org.eclipse.jdt.launching.IJavaLaunchConfigurationConstants.ATTR_CLASSPATH_PROVIDER;
import static org.eclipse.jdt.launching.IJavaLaunchConfigurationConstants.ATTR_JRE_CONTAINER_PATH;
import static org.eclipse.jdt.launching.IJavaLaunchConfigurationConstants.ATTR_MAIN_TYPE_NAME;

import org.eclipse.core.resources.IFile;
import org.eclipse.core.resources.IResource;
import org.eclipse.core.runtime.CoreException;
import org.eclipse.jdt.core.IClasspathEntry;
import org.eclipse.jdt.launching.IVMInstall;
import org.eclipse.jdt.launching.JavaRuntime;
import org.eclipse.jdt.launching.environments.IExecutionEnvironment;
import org.eclipse.jdt.ui.PreferenceConstants;
import org.jmodelica.devel.launch.AntFile;
import org.jmodelica.devel.launch.Launch;
import org.jmodelica.devel.launch.Refresh;

public class AntRunner implements FileCreator {

	private static final String BUILD_NOTHING = "${none}";
	private static final String ATTR_BUILD_SCOPE = "org.eclipse.ui.externaltools.ATTR_LAUNCH_CONFIGURATION_BUILD_SCOPE";
	private static final String ANT_PROCESS_FACTORY = "org.eclipse.ant.ui.remoteAntProcessFactory";
	private static final String ATTR_PROCESS_FACTORY = "process_factory_id";
	private static final String ANT_MAIN_TYPE = "org.eclipse.ant.ui.AntClasspathProvider";
	private static final String ANT_CLASSPATH_PROVIDER = ANT_MAIN_TYPE;
	
	private AntFile file;
	private String targets;
	private boolean keep;
	private String dir;

	public AntRunner(AntFile file, String targets, String dir, boolean keep) {
		this.file = file;
		this.targets = targets;
		this.keep = keep;
		this.dir = dir;
	}

	public void createFiles(ProjectDef proj) {
		System.out.println("AntRunner.createFiles(): start");
		String name = file.name + " " + targets;
		try {
			Launch l = new Launch(proj, name, ID_ANT_LAUNCH_CONFIGURATION_TYPE, false);
			l.setFiles(file.path);
			l.setAttribute(ATTR_ANT_TARGETS, targets);
			l.setAttribute(ATTR_DEFAULT_VM_INSTALL, true);
			l.setAttribute(ATTR_SOURCE_PATH_PROVIDER, ANT_CLASSPATH_PROVIDER);
			l.setAttribute(ATTR_CLASSPATH_PROVIDER, ANT_CLASSPATH_PROVIDER);
			l.setAttribute(ATTR_MAIN_TYPE_NAME, ANT_MAIN_TYPE);
			l.setAttribute(ATTR_PROCESS_FACTORY, ANT_PROCESS_FACTORY);
			l.setAttribute(ATTR_BUILD_SCOPE, BUILD_NOTHING);
			
			// TODO: Set the refresh in the launch
			IResource parent = proj.getIProject().getFile(dir).getParent();
			l.addCompletedAction(new Refresh(parent));
			
			System.out.println("AntRunner.createFiles(): execute launch");
			l.execute();
		} catch (CoreException e) {
			// Just swallow it, will be solved by checking if it worked
			System.out.println("AntRunner.createFiles(): exception");
		}
		System.out.println("AntRunner.createFiles(): done");
	}

}
