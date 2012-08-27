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
import org.eclipse.core.runtime.IProgressMonitor;
import org.eclipse.jface.text.IDocument;
import org.eclipse.jface.text.IRegion;
import org.eclipse.jface.text.reconciler.DirtyRegion;
import org.jastadd.plugin.Activator;
import org.jastadd.plugin.compiler.AbstractCompiler;
import org.jastadd.plugin.compiler.ast.IASTNode;
import org.jastadd.plugin.registry.ASTRegistry;
import org.jmodelica.ide.IDEConstants;
import org.jmodelica.ide.helpers.DocumentReader;
import org.jmodelica.ide.helpers.Maybe;
import org.jmodelica.ide.helpers.Util;
import org.jmodelica.modelica.compiler.ASTNode;
import org.jmodelica.modelica.compiler.LibNode;
import org.jmodelica.modelica.compiler.StoredDefinition;

public class ModelicaEclipseCompiler extends AbstractCompiler {

	@Override
	public IASTNode compileToProjectAST(IProject project, IProgressMonitor monitor) {
		return recursiveCompile(new CompilationRoot(project), project, monitor).root();
	}

	private CompilationRoot recursiveCompile(CompilationRoot compilationRoot, IContainer parent,
			IProgressMonitor monitor) {
		try {
			IResource[] resources = parent.members();
			for (IResource resource : resources) {
				if (monitor.isCanceled()) // TODO: probably shouldn't return a half-finished compilation result here
					break;

				switch (resource.getType()) {
				case IResource.FOLDER:
					File dir = new File(resource.getRawLocation().toOSString());
					if (LibNode.isStructuredLib(dir)) {
						compilationRoot.addPackageDirectory(dir);
						monitor.worked(1);
					} else {
						recursiveCompile(compilationRoot, (IFolder) resource, monitor);
					}
					break;

				case IResource.FILE:
					IFile file = (IFile) resource;
					if (Util.isModelicaFile(file)) {
						compilationRoot.parseFile(file);
						monitor.worked(1);
					}
					break;
				}
			}

		} catch (CoreException e) {
			e.printStackTrace();
		}

		return compilationRoot;
	}

	@Override
	public IASTNode compileToAST(IDocument document, DirtyRegion dirtyRegion, IRegion region,
			IFile file) {
		if (file == null)
			return null;
		CompilationRoot compilationRoot = new CompilationRoot(file.getProject());
		compilationRoot.parseFile(new DocumentReader(document), file, false);
		return compilationRoot.getStoredDefinition();
	}

	public Maybe<ASTNode<?>> recompile(IDocument doc, IFile file) {
		return new Maybe<ASTNode<?>>((ASTNode<?>) compileToAST(doc, null, null, file));
	}

	public StoredDefinition recompile(String doc, IFile file) {
		CompilationRoot root = new CompilationRoot(file.getProject());

		root.parseDoc(doc, file);

		return root.getStoredDefinition();
	}

	@Override
	protected IASTNode compileToAST(IFile file) {
		return compileFile(file);
	}

	public StoredDefinition compileFile(IFile file) {
		if (file == null)
			return new CompilationRoot(null).getStoredDefinition();
		CompilationRoot compilationRoot = new CompilationRoot(file.getProject());

		compilationRoot.parseFile(file);

		return compilationRoot.getStoredDefinition();
	}

	// Overridden to add synchronization
	@Override
	public void compile(IDocument document, DirtyRegion dirtyRegion, IRegion region, IFile file) {
		ASTNode node = (ASTNode) compileToAST(document, dirtyRegion, region, file);
		ASTRegistry reg = Activator.getASTRegistry();
		if (reg != null && node != null && node.hasLookupKey()) {
			synchronized (node.state()) {
				// Depends on ASTNode.state being static (if it isn't, use an object that is unique to the tree) 
				reg.updateAST(node, node.lookupKey(), file);
			}
		}
	}

	@Override
	protected Collection<String> acceptedFileExtensions() {
		return Arrays.asList(IDEConstants.ALL_FILE_EXTENSIONS);
	}

	@Override
	protected String acceptedNatureID() {
		return IDEConstants.NATURE_ID;
	}
}
