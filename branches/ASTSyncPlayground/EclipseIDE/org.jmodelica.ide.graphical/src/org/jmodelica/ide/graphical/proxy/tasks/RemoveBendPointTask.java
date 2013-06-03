package org.jmodelica.ide.graphical.proxy.tasks;

import java.util.Stack;

import org.eclipse.core.resources.IFile;
import org.jastadd.ed.core.model.IASTPathPart;
import org.jmodelica.icons.primitives.Line;
import org.jmodelica.ide.sync.ModelicaASTRegistry;
import org.jmodelica.ide.sync.tasks.AbstractAestheticModificationTask;
import org.jmodelica.modelica.compiler.ConnectClause;
import org.jmodelica.modelica.compiler.StoredDefinition;

public class RemoveBendPointTask extends AbstractAestheticModificationTask {

	private IFile theFile;
	private Stack<IASTPathPart> connectClauseASTPath;
	private int index;

	public RemoveBendPointTask(IFile theFile,
			Stack<IASTPathPart> connectClauseASTPath, int index) {
		this.theFile = theFile;
		this.connectClauseASTPath = connectClauseASTPath;
		this.index = index;
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
						.println("RemoveBendPointTask failed to resolve ASTPath!");
				return;
			}
			Line line = clause.syncGetConnectionLine();
			if (line == null) {
				System.err
						.println("Unable to remove line point, connection not found!");
				return;
			}
			if (index != -1) {
				line.getPoints().remove(index);
				line.pointsChanged();
			} else {
				System.err
						.println("Unable to remove line point, point is missing from pointlist, someone probably swapped it already!");
			}
		}
	}
}