package org.jmodelica.ide.graphical.proxy.tasks;

import java.util.Stack;

import org.eclipse.core.resources.IFile;
import org.jmodelica.icons.coord.Point;
import org.jmodelica.ide.sync.ASTPathPart;
import org.jmodelica.ide.sync.ModelicaASTRegistry;
import org.jmodelica.ide.sync.tasks.AbstractAestheticModificationTask;
import org.jmodelica.modelica.compiler.ComponentDecl;
import org.jmodelica.modelica.compiler.StoredDefinition;

public class MoveComponentTask extends AbstractAestheticModificationTask {

	private IFile theFile;
	private Stack<ASTPathPart> componentASTPath;
	private double destX;
	private double destY;

	public MoveComponentTask(IFile theFile,
			Stack<ASTPathPart> componentASTPath, double destX, double destY) {
		this.theFile = theFile;
		this.componentASTPath = componentASTPath;
		this.destX = destX;
		this.destY = destY;
	}

	@Override
	public void doJob() {
		long time = System.currentTimeMillis();
		StoredDefinition def = ModelicaASTRegistry.getInstance().getLatestDef(
				theFile);
		synchronized (def.state()) {
			ComponentDecl cd = (ComponentDecl) ModelicaASTRegistry
					.getInstance().resolveSourceASTPath(def, componentASTPath);
			if (cd == null) {
				System.err
						.println("MoveComponentTask failed to resolve ASTPath!");
				return;
			}
			cd.syncGetPlacement().getTransformation()
					.setOrigin(new Point(destX, destY));
		}
		System.out.println("MoveComponentTask took: "
				+ (System.currentTimeMillis() - time) + "ms");
	}
}