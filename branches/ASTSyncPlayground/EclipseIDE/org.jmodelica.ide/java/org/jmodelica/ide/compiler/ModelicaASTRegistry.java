package org.jmodelica.ide.compiler;

import java.util.Stack;

import org.eclipse.core.resources.IFile;
import org.eclipse.core.resources.IProject;
import org.jastadd.ed.core.model.GlobalRootRegistry;
import org.jastadd.ed.core.model.IASTChangeListener;
import org.jastadd.ed.core.model.node.ILocalRootNode;
import org.jmodelica.modelica.compiler.ASTNode;
import org.jmodelica.modelica.compiler.StoredDefinition;

public class ModelicaASTRegistry extends GlobalRootRegistry {
	private static ModelicaASTRegistry registry;

	private ModelicaASTRegistry() {
	}

	public static synchronized ModelicaASTRegistry getInstance() {
		System.out.println("MODELICAASTREGISTRY created/retrieved");
		if (registry == null)
			registry = new ModelicaASTRegistry();
		return registry;
	}

	@Override
	public ILocalRootNode[] doLookup(IFile file) { // TODO FIX initial BUILD,
													// this
		// method should not have to override...
		//System.out.println("MODELICAASTREG doLookup(IFile file)");
		if (file == null)
			return null;
		if (lookupFile(file).length == 0) {
			System.out.println("Lookup of file: " + file.getName()
					+ " returned 0 ast results...");
			ModelicaEclipseCompiler compiler = new ModelicaEclipseCompiler();
			if (compiler.canCompile(file)) {
				System.out.println("Compiler compiling file: "
						+ file.getName());
				ILocalRootNode root = compiler.compile(file);
				doUpdate(file, root);
			} else {
				System.out.println("Compiler could NOT compile file: "
						+ file.getName());
			}
		}
		return lookupFile(file);
	}

	public boolean hasProject(IProject project) {
		return fProjectASTMap.containsKey(project);
	}

	public void addListener(IFile file, ASTNode<?> node,
			IASTChangeListener listener, int listenerType) {
		System.out.println("MODELICAASTREGISTRY: Added listener to file "
				+ file.getName());
		Stack<String> nodePath = new Stack<String>();
		createPath(nodePath, node);
		ChangePropagationController.getInstance().addListener(file, node,
				listener, listenerType, nodePath);
	}

	public void createPath(Stack<String> nodePath, ASTNode<?> node) {
		if (node != null && !(node instanceof StoredDefinition)) {
			ASTNode<?> parent = node.getParent();
			//System.out
			//		.println("ChangePropagationcontoller->createPath() YEAH, found CHILD creating PATH..."
			//				+ node.getNodeName());
			nodePath.add(node.getNodeName());
			createPath(nodePath, parent);
		}
	}
}
