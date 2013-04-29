package org.jmodelica.ide.sync.tasks;

import org.eclipse.core.resources.IProject;
import org.jmodelica.ide.sync.GlobalRootNode;
import org.jmodelica.ide.sync.LocalRootNode;
import org.jmodelica.ide.sync.ModelicaASTRegistry;

public class CompileFileTask implements ITaskObject {

	private String fileName;
	private IProject project;

	public CompileFileTask(String fileName, IProject project) {
		this.fileName = fileName;
		this.project = project;
	}

	@Override
	public void doJob() {
		System.out.println("CompileFileJob->doJob()");
		GlobalRootNode gRoot = (GlobalRootNode) ModelicaASTRegistry
				.getInstance().doLookup(project);
		LocalRootNode lroot = (LocalRootNode) gRoot.lookupFileNode(fileName);
		ModelicaASTRegistry.getInstance().recompileFile(lroot.getFile());
	}

	@Override
	public int getJobPriority() {
		return ITaskObject.PRIORITY_HIGH;
	}

	@Override
	public int getListenerID() {
		return 0;
	}

	@Override
	public int getJobType() {
		return ITaskObject.RECOMPILE_FILE;
	}
}