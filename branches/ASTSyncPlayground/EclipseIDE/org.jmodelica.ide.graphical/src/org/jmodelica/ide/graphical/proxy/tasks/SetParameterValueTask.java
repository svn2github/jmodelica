package org.jmodelica.ide.graphical.proxy.tasks;

import java.util.Stack;

import org.eclipse.core.resources.IFile;
import org.jmodelica.ide.sync.ASTPathPart;
import org.jmodelica.ide.sync.ChangePropagationController;
import org.jmodelica.ide.sync.GlobalRootNode;
import org.jmodelica.ide.sync.ModelicaASTRegistry;
import org.jmodelica.ide.sync.tasks.AbstractAestheticModificationTask;
import org.jmodelica.modelica.compiler.ComponentDecl;
import org.jmodelica.modelica.compiler.StoredDefinition;

public class SetParameterValueTask extends AbstractAestheticModificationTask {

	private IFile theFile;
	private Stack<ASTPathPart> componentASTPath;
	private Stack<String> params;
	private String value;

	public SetParameterValueTask(IFile theFile,
			Stack<ASTPathPart> componentASTPath, Stack<String> params,
			String value) {
		this.theFile = theFile;
		this.componentASTPath = componentASTPath;
		this.params = params;
		this.value = value;
	}

	@Override
	public void doJob() {
		StoredDefinition def = ModelicaASTRegistry.getInstance().getLatestDef(
				theFile);
		synchronized (def.state()) {
			ComponentDecl cd = (ComponentDecl) ModelicaASTRegistry
					.getInstance().resolveSourceASTPath(def, componentASTPath);
			if (cd == null) {
				System.err
						.println("SetParameterValueTask failed to resolve ASTPath!");
				return;
			}
			// TODO why is comp name added to path in graph proxy?
			if (params.peek().equals(cd.name()))
				params.pop();
			cd.syncSetParameterValue(params, value);
			cd.flushCache();
			GlobalRootNode groot = (GlobalRootNode) ModelicaASTRegistry
					.getInstance().doLookup(theFile.getProject());
			groot.getSourceRoot().getProgram().getInstProgramRoot()
					.flushCache();
		}
		ChangePropagationController.getInstance().handleNotifications(
				GRAPHICAL_AESTHETIC, theFile, componentASTPath);
	}
}