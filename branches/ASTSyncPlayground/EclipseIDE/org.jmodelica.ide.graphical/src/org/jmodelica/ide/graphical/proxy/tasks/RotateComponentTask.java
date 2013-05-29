package org.jmodelica.ide.graphical.proxy.tasks;

import java.util.Stack;

import org.eclipse.core.resources.IFile;
import org.jmodelica.ide.sync.ASTPathPart;
import org.jmodelica.ide.sync.ModelicaASTRegistry;
import org.jmodelica.ide.sync.tasks.AbstractAestheticModificationTask;
import org.jmodelica.modelica.compiler.ComponentDecl;
import org.jmodelica.modelica.compiler.StoredDefinition;

public class RotateComponentTask extends AbstractAestheticModificationTask {

	private IFile theFile;
	private Stack<ASTPathPart> componentASTPath;
	private double angle;

	public RotateComponentTask(IFile theFile,
			Stack<ASTPathPart> componentASTPath, double angle) {
		this.theFile = theFile;
		this.componentASTPath = componentASTPath;
		this.angle = angle;
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
						.println("RotateComponentTask failed to resolve ASTPath!");
				return;
			}
			cd.syncGetPlacement()
					.getTransformation()
					.setRotation(
							cd.syncGetPlacement().getTransformation()
									.getRotation()
									+ angle);
		}
	}
}