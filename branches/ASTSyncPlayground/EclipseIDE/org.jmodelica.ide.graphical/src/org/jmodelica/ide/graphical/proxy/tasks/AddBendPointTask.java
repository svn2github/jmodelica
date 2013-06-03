package org.jmodelica.ide.graphical.proxy.tasks;

import java.util.Stack;

import org.eclipse.core.resources.IFile;
import org.jastadd.ed.core.model.IASTPathPart;
import org.jmodelica.icons.coord.Point;
import org.jmodelica.icons.primitives.Line;
import org.jmodelica.ide.sync.ModelicaASTRegistry;
import org.jmodelica.ide.sync.tasks.AbstractAestheticModificationTask;
import org.jmodelica.modelica.compiler.ConnectClause;
import org.jmodelica.modelica.compiler.StoredDefinition;

public class AddBendPointTask extends AbstractAestheticModificationTask {

	private IFile theFile;
	private Stack<IASTPathPart> connectClauseASTPath;
	private int index;
	private double x;
	private double y;

	public AddBendPointTask(IFile theFile,
			Stack<IASTPathPart> connectClauseASTPath, int index, double x,
			double y) {
		this.theFile = theFile;
		this.connectClauseASTPath = connectClauseASTPath;
		this.index = index;
		this.x = x;
		this.y = y;
	}

	@Override
	public void doJob() {
		StoredDefinition def = ModelicaASTRegistry.getInstance().getLatestDef(
				theFile);
		synchronized (def.state()) {
			ConnectClause clause = (ConnectClause) ModelicaASTRegistry
					.getInstance().resolveSourceASTPath(def,
							connectClauseASTPath);
			if (clause == null) {
				System.err
						.println("AddBendPointTask failed to resolve ASTPath!");
				return;
			}
			Line line = clause.syncGetConnectionLine();
			if (line == null) {
				System.err
						.println("Unable to add line point, connection not found!");
				return;
			}
			if (line.getPoints().size() <= index)
				System.err
						.println("Unable to add line point, index is out of bounds someone probably changed it already!");
			line.getPoints().add(index, new Point(x, y));
			line.pointsChanged();
		}
	}
}