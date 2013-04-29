package org.jmodelica.ide.graphical.proxy.cache.tasks;

import java.util.Stack;

import org.eclipse.core.resources.IFile;
import org.jmodelica.ide.sync.ChangePropagationController;
import org.jmodelica.ide.sync.ModelicaASTRegistry;
import org.jmodelica.ide.sync.tasks.AbstractAestheticModificationTask;
import org.jmodelica.modelica.compiler.ComponentDecl;
import org.jmodelica.modelica.compiler.StoredDefinition;

public class SetParameterValueTask extends AbstractAestheticModificationTask {

	private IFile theFile;
	private Stack<String> componentASTPath;
	private Stack<String> params;
	private String value;

	public SetParameterValueTask(IFile theFile, Stack<String> componentASTPath,
			Stack<String> params, String value) {
		this.theFile = theFile;
		this.componentASTPath = componentASTPath;
		this.params = params;
		this.value = value;
	}

	@Override
	public void doJob() {
		long time = System.currentTimeMillis();
		StoredDefinition def = ModelicaASTRegistry.getInstance().getLatestDef(
				theFile);
		synchronized (def.state()) {
			ComponentDecl cd = (ComponentDecl) ModelicaASTRegistry
					.getInstance().recoveryResolve(def, componentASTPath);
			if (cd == null) {
				System.err
						.println("SetParameterValueTask failed to resolve ASTPath!");
				return;
			}
			cd.syncSetParameterValue(params, value);
			cd.flushCache();
		}
		ChangePropagationController.getInstance().handleNotifications(GRAPHICAL_AESTHETIC, theFile, componentASTPath);
		System.out.println("SetParameterValueTask took: "
				+ (System.currentTimeMillis() - time) + "ms");
	}
}