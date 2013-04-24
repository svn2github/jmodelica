package org.jmodelica.ide.compiler;

import java.io.File;
import java.util.ArrayList;
import java.util.List;

import org.eclipse.core.resources.IFile;
import org.eclipse.core.resources.IProject;
import org.jastadd.ed.core.model.node.IASTNode;
import org.jastadd.ed.core.model.node.IGlobalRootNode;
import org.jastadd.ed.core.model.node.ILocalRootNode;
import org.jmodelica.ide.IDEConstants;
import org.jmodelica.ide.error.InstanceErrorHandler;
import org.jmodelica.modelica.compiler.Program;
import org.jmodelica.modelica.compiler.SourceRoot;
import org.jmodelica.modelica.compiler.StoredDefinition;

public class GlobalRootNode implements IGlobalRootNode {

	private final SourceRoot root;
	private final org.jmodelica.modelica.compiler.List<StoredDefinition> list;

	private ArrayList<ILocalRootNode> files = new ArrayList<ILocalRootNode>();

	public GlobalRootNode(IProject project) {
		list = new org.jmodelica.modelica.compiler.List<StoredDefinition>();
		Program prog = new Program(list);
		root = new SourceRoot(prog);

		root.options = new IDEOptions(project);
		root.setProject(project);
		root.setErrorHandler(new InstanceErrorHandler());

		prog.setLibraryList(new IDELibraryList(root.options, project));
		prog.getInstProgramRoot().options = root.options;
	}

	public SourceRoot getSourceRoot() {
		return root;
	}

	@Override
	public List<ILocalRootNode> lookupFileNode(IFile file) {
		ArrayList<ILocalRootNode> newList = new ArrayList<ILocalRootNode>();
		for (ILocalRootNode node : this.files) {
			if (node.getFile().equals(file)) {
				newList.add(node);
			}
		}
		return newList;
	}

	@Override
	public ILocalRootNode[] lookupAllFileNodes() {
		return files.toArray(new ILocalRootNode[files.size()]);
	}

	@Override
	public void addFileNode(ILocalRootNode newNode) {
		addOrUpdate(newNode);
	}

	private void addOrUpdate(ILocalRootNode newNode) {
		boolean found = false;
		for (ILocalRootNode node : files) {
			if (node.getFile().equals(newNode.getFile())) {
				node = newNode;
				found = true;
			}
		}
		for (int i = 0; i < list.getNumChild(); i++) {
			if (list.getChildNoTransform(i).getFile().equals(newNode.getFile())) {
				list.setChild(((LocalRootNode) newNode).getDef(), i);
				found = true;
			}
		}
		if (!found) {
			files.add(newNode);
			list.add(((LocalRootNode) newNode).getDef());
		}
	}

	public void addFiles(
			org.jmodelica.modelica.compiler.List<StoredDefinition> files2) {
		for (int i = 0; i < files2.getNumChild(); i++) {
			LocalRootNode fileNode = new LocalRootNode(
					files2.getChildNoTransform(i));
			addOrUpdate(fileNode);
		}
	}

	public void addFile(ILocalRootNode fileNode) {
		addOrUpdate(fileNode);
	}

	public void addPackageDirectory(File dir) {
		try {
			String path = root.options
					.getStringOption(IDEConstants.PACKAGES_IN_WORKSPACE_OPTION);
			path += (path.equals("") ? "" : File.pathSeparator)
					+ dir.getAbsolutePath();
			root.options.setStringOption(
					IDEConstants.PACKAGES_IN_WORKSPACE_OPTION, path);
		} catch (Exception e) {
			e.printStackTrace();
		}
	}

	@Override
	public IASTNode getChild(int i) {
		System.err
				.println("GlobalRootNode.getChild() should never be invoked\n");
		return null;
	}

	@Override
	public int getNumChild() {
		System.err
				.println("GlobalRootNode.getNumChild() should never be invoked\n");
		return 0;
	}

	@Override
	public IASTNode getParent() {
		System.err
				.println("GlobalRootNode.getParent() should never be invoked\n");
		return null;
	}

	@Override
	public IProject getProject() {
		System.err
				.println("GlobalRootNode.getProject() should never be invoked\n");
		return null;
	}

	public IFile lookupFileNode(String sourceFileName) {
		for (ILocalRootNode fileNode : files) {
			if (fileNode.getFile().getName().equals(sourceFileName))
				return fileNode.getFile();
		}
		return null;
	}
}
