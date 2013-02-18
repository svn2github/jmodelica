/*
    Copyright (C) 2009 Modelon AB

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, version 3 of the License.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */
package org.jmodelica.ide.compiler;

import java.io.File;
import java.util.Arrays;
import java.util.Collection;
import org.eclipse.core.resources.IContainer;
import org.eclipse.core.resources.IFile;
import org.eclipse.core.resources.IFolder;
import org.eclipse.core.resources.IProject;
import org.eclipse.core.resources.IResource;
import org.eclipse.core.runtime.CoreException;
import org.eclipse.jface.text.IDocument;
import org.eclipse.jface.text.IRegion;
import org.eclipse.jface.text.reconciler.DirtyRegion;
import org.jastadd.ed.core.ICompiler;
import org.jastadd.ed.core.model.node.IASTNode;
import org.jastadd.ed.core.model.node.IGlobalRootNode;
import org.jastadd.ed.core.model.node.ILocalRootNode;
import org.jmodelica.ide.IDEConstants;
import org.jmodelica.ide.helpers.DocumentReader;
import org.jmodelica.ide.helpers.Maybe;
import org.jmodelica.ide.helpers.Util;
import org.jmodelica.modelica.compiler.ASTNode;
import org.jmodelica.modelica.compiler.LibNode;
import org.jmodelica.modelica.compiler.SourceRoot;
import org.jmodelica.modelica.compiler.StoredDefinition;
import org.jmodelica.ide.compiler.ModelicaASTRegistry;

public class ModelicaEclipseCompiler implements ICompiler {

	public ModelicaEclipseCompiler() {
		super();
		System.out.println("MODELICAECLIPSECOMPILER");
	}

	/*
	 * public IASTNode compileToProjectAST(IProject project) { System.out
	 * .println(
	 * "MODELICACOMPILER compileToProjectAST(IProject project, IProgressMonitor monitor)"
	 * ); return recursiveCompile(new CompilationRoot(project), project)
	 * .root(); }
	 */// TODO NEVER USED?

	private CompilationRoot recursiveCompile(CompilationRoot compilationRoot,
			IContainer parent) {
		System.out
				.println("MODELICACOMPILER recursiveCompile(CompilationRoot compilationRoot, IContainer parent, IProgressMonitor monitor)");
		try {
			IResource[] resources = parent.members();
			for (IResource resource : resources) {

				switch (resource.getType()) {
				case IResource.FOLDER:
					File dir = new File(resource.getRawLocation().toOSString());
					if (LibNode.isStructuredLib(dir)) {
						compilationRoot.addPackageDirectory(dir);
					} else {
						recursiveCompile(compilationRoot, (IFolder) resource);
					}
					break;

				case IResource.FILE:
					IFile file = (IFile) resource;
					if (Util.isModelicaFile(file)) {
						compilationRoot.parseFile(file);
					}
					break;
				}
			}

		} catch (CoreException e) {
			e.printStackTrace();
		}

		return compilationRoot;
	}

	public ILocalRootNode compileToAST(IDocument document,
			DirtyRegion dirtyRegion, IRegion region, IFile file) {
		System.out
				.println("MODELICACOMPILER compileToAST(IDocument document, DirtyRegion dirtyRegion, IRegion region, IFile file)");
		if (file == null)
			return null;
		CompilationRoot compilationRoot = new CompilationRoot(file.getProject());
		compilationRoot.parseFile(new DocumentReader(document), file, false);
		return new LocalRootNode(compilationRoot.root(),
				compilationRoot.getStoredDefinition());
	}

	public Maybe<ASTNode<?>> recompile(IDocument doc, IFile file) {
		return new Maybe<ASTNode<?>>((ASTNode<?>) compileToAST(doc, null, null,
				file));
	}

	public StoredDefinition recompile(String doc, IFile file) {
		CompilationRoot root = new CompilationRoot(file.getProject());

		root.parseDoc(doc, file);

		return root.getStoredDefinition();
	}

	protected IASTNode compileToAST(IFile file) {
		return compileFile(file);
	}

	public ILocalRootNode compileFile(IFile file) {
		System.out.println("MODELICACOMPILER compileFile(IFile file)");
		if (file == null) {
			System.out.println("compileFile() file was NULL...");
			CompilationRoot croot = new CompilationRoot(null);
			return new LocalRootNode(croot.root(), croot.getStoredDefinition());
		}
		CompilationRoot compilationRoot = new CompilationRoot(file.getProject());

		compilationRoot.parseFile(file);
		SourceRoot sroot = compilationRoot.root();
		GlobalRootNode groot = new GlobalRootNode(sroot);
		groot.addFiles(compilationRoot.getFiles());
		System.out.println("ADDED NEW PROJECT");
		ModelicaASTRegistry.getASTRegistry().doUpdate(file.getProject(), groot);
		return new LocalRootNode(sroot, compilationRoot.getStoredDefinition());
	}

	// Overridden to add synchronization
	public void compile(IDocument document, DirtyRegion dirtyRegion,
			IRegion region, IFile file) {
		System.out
				.println("MODLEICACOMPILER compile(IDocument document, DirtyRegion dirtyRegion, IRegion region, IFile file)");

		ASTNode<?> node = (ASTNode<?>) compileToAST(document, dirtyRegion,
				region, file);
		ModelicaASTRegistry reg = ModelicaASTRegistry.getASTRegistry();
		if (reg != null && node != null && node.hasLookupKey()) {
			synchronized (node.state()) {
				// Depends on ASTNode.state being static (if it isn't, use an
				// object that is unique to the tree)
				reg.doUpdate(file, (ILocalRootNode) node);// , node.lookupKey(),
															// file);
			}
		}
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see
	 * org.jastadd.plugin.compiler.ICompiler#canCompile(org.eclipse.core.resources
	 * .IProject)
	 */
	public boolean canCompile(IProject project) {
		try {
			if (project != null && project.isOpen()
					&& project.isNatureEnabled(acceptedNatureID())) {
				return true;
			}
		} catch (CoreException e) {
			e.printStackTrace();
		}
		return false;
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see
	 * org.jastadd.plugin.compiler.ICompiler#canCompile(org.eclipse.core.resources
	 * .IFile)
	 */
	public boolean canCompile(IFile file) {
		if (file == null)
			return false;
		for (String str : acceptedFileExtensions()) {
			if (file.getFileExtension() != null
					&& file.getFileExtension().equals(str)) {
				return canCompile(file.getProject());
			}
		}
		return false;
	}

	@Override
	public IGlobalRootNode compile(IProject project) {
		CompilationRoot croot = recursiveCompile(new CompilationRoot(project),
				project);
		GlobalRootNode newRoot = new GlobalRootNode(croot.root());
		newRoot.addFiles(croot.getFiles());
		return newRoot;
	}

	@Override
	public ILocalRootNode compile(IFile file, IDocument document) {
		return compileToAST(document,
				null, null, file);
	}

	@Override
	public ILocalRootNode compile(IFile file) {
		return compileFile(file);
	}

	private String acceptedNatureID() {
		return IDEConstants.NATURE_ID;
	}

	private Collection<String> acceptedFileExtensions() {
		return Arrays.asList(IDEConstants.ALL_FILE_EXTENSIONS);
	}
}
