package org.jmodelica.ide.graphical.proxy.cache.tasks;

import java.util.Stack;

import org.eclipse.core.resources.IFile;
import org.jmodelica.icons.coord.Extent;
import org.jmodelica.icons.coord.Point;
import org.jmodelica.ide.sync.ModelicaASTRegistry;
import org.jmodelica.ide.sync.tasks.AbstractAestheticModificationTask;
import org.jmodelica.modelica.compiler.ComponentDecl;
import org.jmodelica.modelica.compiler.StoredDefinition;

public class ResizeComponentTask extends AbstractAestheticModificationTask {

	private IFile theFile;
	private Stack<String> componentASTPath;
	private double x;
	private double y;
	private double x2;
	private double y2;

	public ResizeComponentTask(IFile theFile, Stack<String> componentASTPath,
			double x, double y, double x2, double y2) {
		this.theFile = theFile;
		this.componentASTPath = componentASTPath;
		this.x = x;
		this.y = y;
		this.x2 = x2;
		this.y2 = y2;
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
						.println("ResizeComponentTask failed to resolve ASTPath!");
				return;
			}
			cd.syncGetPlacement().getTransformation()
					.setExtent(new Extent(new Point(x, y), new Point(x2, y2)));
		}
		System.out.println("ResizeComponentTask took: "
				+ (System.currentTimeMillis() - time) + "ms");
	}
}