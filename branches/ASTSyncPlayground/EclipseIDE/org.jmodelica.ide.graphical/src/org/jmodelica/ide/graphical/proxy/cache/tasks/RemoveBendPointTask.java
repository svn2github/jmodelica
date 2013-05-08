package org.jmodelica.ide.graphical.proxy.cache.tasks;

import java.util.Stack;

import org.eclipse.core.resources.IFile;
import org.jmodelica.icons.primitives.Line;
import org.jmodelica.ide.sync.ASTPathPart;
import org.jmodelica.ide.sync.ModelicaASTRegistry;
import org.jmodelica.ide.sync.tasks.AbstractAestheticModificationTask;
import org.jmodelica.modelica.compiler.ConnectClause;
import org.jmodelica.modelica.compiler.StoredDefinition;

public class RemoveBendPointTask extends AbstractAestheticModificationTask {

	private IFile theFile;
	private Stack<ASTPathPart> connectClauseASTPath;
	private int index;

	public RemoveBendPointTask(IFile theFile,
			Stack<ASTPathPart> connectClauseASTPath, int index) {
		this.theFile = theFile;
		this.connectClauseASTPath = connectClauseASTPath;
		this.index = index;
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
		System.out.println("RemoveBendPointTask took: "
				+ (System.currentTimeMillis() - time) + "ms");
	}
}