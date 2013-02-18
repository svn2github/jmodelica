package org.jmodelica.ide.actions;

import org.eclipse.core.resources.IFile;
import org.eclipse.jface.action.Action;
import org.eclipse.jface.viewers.TreeViewer;
import org.eclipse.swt.widgets.TreeItem;
import org.jastadd.ed.core.model.node.IASTNode;
import org.jmodelica.ide.compiler.JobObject;
import org.jmodelica.ide.compiler.ModelicaASTRegistryJobBucket;
import org.jmodelica.modelica.compiler.ASTNode;

public class TestRemoveAction extends Action {

	protected TreeViewer viewer;
	protected IFile file;

	public TestRemoveAction(TreeViewer viewer, IFile file) {
		super("TestRemoveAction");
		this.viewer = viewer;
		this.file = file;
	}

	@Override
	public void run() {
		TreeItem[] selection = viewer.getTree().getSelection();
		System.out.println("TestRemoveAction: A TestRemoveAction was run!");
		for (int i = 0; i < selection.length; i++) {
			String s = ((IASTNode) selection[i].getData()).toString();
			System.out.println("TestRemoveAction: Selection contains node: "
					+ s);
			ASTNode<?> selectedInstNode = (ASTNode<?>) selection[i].getData();
			JobObject job = new JobObject(JobObject.REMOVE_INSTNODE, file,
					selectedInstNode);
			ModelicaASTRegistryJobBucket.getInstance().addJob(job);
		}
	}
}