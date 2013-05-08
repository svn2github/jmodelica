package org.jmodelica.ide.graphical.proxy.cache.tasks;

import java.util.Stack;

import org.eclipse.core.resources.IFile;
import org.jmodelica.icons.coord.Point;
import org.jmodelica.icons.primitives.Line;
import org.jmodelica.ide.sync.ASTPathPart;
import org.jmodelica.ide.sync.ModelicaASTRegistry;
import org.jmodelica.ide.sync.tasks.AbstractAestheticModificationTask;
import org.jmodelica.modelica.compiler.ConnectClause;
import org.jmodelica.modelica.compiler.StoredDefinition;

public class MoveBendPointTask extends AbstractAestheticModificationTask {

	private IFile theFile;
	private Stack<ASTPathPart> connectClauseASTPath;
	private int index;
	private double x;
	private double y;

	public MoveBendPointTask(IFile theFile,
			Stack<ASTPathPart> connectClauseASTPath, double x, double y,
			int index) {
		this.theFile = theFile;
		this.connectClauseASTPath = connectClauseASTPath;
		this.index = index;
		this.x = x;
		this.y = y;
	}

	@Override
	public void doJob() {
		long time = System.currentTimeMillis();
		StoredDefinition def = ModelicaASTRegistry.getInstance().getLatestDef(
				theFile);
		synchronized (def.state()) {
			ConnectClause clause = (ConnectClause) ModelicaASTRegistry
					.getInstance().resolveSourceASTPath(def,
							connectClauseASTPath);
			if (clause == null) {
				System.err
						.println("MoveBendPointTask failed to resolve ASTPath!");
				return;
			}
			Line line = clause.syncGetConnectionLine();
			if (line == null) {
				System.err
						.println("Unable to move line point, connection not found!");
				return;
			}
			if (index != -1) {
				line.getPoints().set(index, new Point(x, y));
			} else {
				System.err
						.println("Unable to redo move line point, oldpoint is missing from pointlist, someone probably swapped it already!");
			}
		}
		System.out.println("MoveBendPointTask took: "
				+ (System.currentTimeMillis() - time) + "ms");
	}
}