package org.jmodelica.devel.launch;

import org.eclipse.core.runtime.CoreException;
import org.eclipse.debug.core.ILaunchConfiguration;
import org.eclipse.debug.core.ILaunchConfigurationWorkingCopy;

public class RemoveLaunchConfiguration implements Runnable {

	private ILaunchConfiguration launch;

	public RemoveLaunchConfiguration(ILaunchConfiguration lc) {
		launch = lc;
	}

	public void run() {
		try {
			launch.delete();
		} catch (CoreException e) {
			// Ignore this, we do this by best-effort
		}
	}

}
