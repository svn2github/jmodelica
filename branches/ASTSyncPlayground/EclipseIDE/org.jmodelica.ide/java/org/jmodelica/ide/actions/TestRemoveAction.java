package org.jmodelica.ide.actions;

import org.eclipse.core.resources.IFile;
import org.eclipse.jface.action.Action;
import org.eclipse.jface.viewers.TreeViewer;
import org.eclipse.swt.widgets.TreeItem;
import org.jastadd.ed.core.model.node.IASTNode;
import org.jmodelica.ide.compiler.IJobObject;
import org.jmodelica.ide.compiler.ModelicaASTRegistryJobBucket;
import org.jmodelica.ide.compiler.ModificationJob;
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
			IJobObject job = new ModificationJob(IJobObject.REMOVE_NODE, file,
					selectedInstNode);
			ModelicaASTRegistryJobBucket.getInstance().addJob(job);
		}
	}
}