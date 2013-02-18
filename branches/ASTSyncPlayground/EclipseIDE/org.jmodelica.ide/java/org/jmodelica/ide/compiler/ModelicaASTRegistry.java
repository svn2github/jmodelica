package org.jmodelica.ide.compiler;

import java.util.ArrayList;
import java.util.HashMap;
import org.eclipse.core.resources.IFile;
import org.eclipse.core.resources.IProject;
import org.jastadd.ed.core.model.GlobalRootRegistry;
import org.jastadd.ed.core.model.IASTChangeListener;
import org.jastadd.ed.core.model.node.ILocalRootNode;

public class ModelicaASTRegistry extends GlobalRootRegistry {
	private static ModelicaASTRegistry registry;

	// Each file has a Tree where listeners register against the file ast nodes.
	// TODO synchronize when using this
	private HashMap<IFile, LibraryNode> listenerTrees = new HashMap<IFile, LibraryNode>();

	private ModelicaASTRegistry() {
	}

	public static synchronized ModelicaASTRegistry getASTRegistry() {
		System.out.println("MODELICAASTREGISTRY created/retrieved");
		if (registry == null)
			registry = new ModelicaASTRegistry();
		return registry;
	}

	@Override
	public ILocalRootNode[] doLookup(IFile file) { // TODO FIX initial BUILD,
													// this
		// method should not have to override...
		System.out.println("MODELICAASTREG doLookup(IFile file)");
		if (file == null)
			return null;
		if (lookupFile(file).length == 0) {
			System.out.println("Lookup of file: " + file.getName()
					+ " returned 0 results...");
			ModelicaEclipseCompiler compiler = new ModelicaEclipseCompiler();
			if (compiler.canCompile(file)) {
				System.out.println("Compiler CAN compile file: "
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

	public void addListener(IFile file, ArrayList<String> nodePath,
			IASTChangeListener listener) {
		System.out.println("MODELICAASTREGISTRY: Added listener to file "
				+ file.getName());
		LibraryNode root = listenerTrees.get(file);
		if (root == null) {
			root = new LibraryNode("");
			listenerTrees.put(file, root);
		}
		LibraryVisitor visitor = new LibraryVisitor();
		visitor.addListener(root, nodePath, listener);
	}

	public LibraryNode getListenerTree(IFile file) {
		return listenerTrees.get(file);
	}
}
