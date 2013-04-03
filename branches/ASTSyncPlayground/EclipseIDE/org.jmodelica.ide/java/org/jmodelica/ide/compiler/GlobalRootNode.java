package org.jmodelica.ide.compiler;

import java.util.ArrayList;
import java.util.List;

import org.eclipse.core.resources.IFile;
import org.eclipse.core.resources.IProject;
import org.jastadd.ed.core.model.node.IASTNode;
import org.jastadd.ed.core.model.node.IGlobalRootNode;
import org.jastadd.ed.core.model.node.ILocalRootNode;
import org.jmodelica.modelica.compiler.SourceRoot;
import org.jmodelica.modelica.compiler.StoredDefinition;

public class GlobalRootNode implements IGlobalRootNode {
	private ArrayList<ILocalRootNode> files = new ArrayList<ILocalRootNode>();
	private SourceRoot sourceRoot;
	private CompilationRoot compilationRoot;

	public GlobalRootNode(SourceRoot sroot) {
		this.sourceRoot = sroot;
	}

	public SourceRoot getSourceRoot() {
		return sourceRoot;
	}

	@Override
	public List<ILocalRootNode> lookupFileNode(IFile file) {
		System.out.println("GLOBALROOTNOBE looking for file:" + file.getName());
		ArrayList<ILocalRootNode> newList = new ArrayList<ILocalRootNode>();
		for (ILocalRootNode node : this.files) {
			System.out.println("GRN: searching for: "+file.getName()+" current is:"+node.getFile().getName());
			if (node.getFile().equals(file)) {
				System.out.println("YEAH, found file in globalrootnode:"
						+ node.getFile().getName());
				newList.add(node);
			}
		}
		return newList;
	}

	@Override
	public ILocalRootNode[] lookupAllFileNodes() {
		System.out.println("lookupAllFileNodes in globalrootnode, size:"
				+ files.size());
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
				System.out
						.println("GlobalRootNode recieved add buta already had file:"
								+ node.getFile().getName()
								+ " updating def of localrootnode...");
				node = newNode;
				found = true;
			}
		}
		if (!found) {
			files.add(newNode);
			System.out
					.println("GlobalRootNode recieved add and didnt have file:"
							+ newNode.getFile().getName()
							+ " added to globalrootnode...");
		}
		LocalRootNode lrn = (LocalRootNode) newNode;
		lrn.getSourceRoot().getProgram().classes();
		lrn.getSourceRoot().getProgram().getInstProgramRoot().classes();
		lrn.getSourceRoot().getProgram().getInstProgramRoot().components();
	}

	public void addFiles(
			org.jmodelica.modelica.compiler.List<StoredDefinition> files2) {
		System.out.println("GlobalRootNode addFiles(): nbrnewfiles="
				+ files2.length() + " number oldfiles:" + files.size());
		for (int i = 0; i < files2.length(); i++) {
			LocalRootNode fileNode = new LocalRootNode(sourceRoot,
					files2.getChild(i));
			addOrUpdate(fileNode);
		}
	}

	public void addFile(StoredDefinition def) {
		System.out.println("GLOBALROOTNODE ADDED FILE:" +def.getFile().getName());
		LocalRootNode fileNode = new LocalRootNode(sourceRoot, def);
		addOrUpdate(fileNode);
	}

	@Override
	public IASTNode getChild(int i) {
		// TODO Auto-generated method stub
		return null;
	}

	@Override
	public int getNumChild() {
		// TODO Auto-generated method stub
		return 0;
	}

	@Override
	public IASTNode getParent() {
		// TODO Auto-generated method stub
		return null;
	}

	@Override
	public IProject getProject() {
		// TODO Auto-generated method stub
		return null;
	}

	public void setCompilationRoot(CompilationRoot compilationRoot) {
		this.compilationRoot = compilationRoot;
	}

	public CompilationRoot getCompilationRoot() {
		return compilationRoot;
	}
}
