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
package org.jmodelica.ide;

import java.io.File;
import java.util.Arrays;
import java.util.Collection;

import mock.MockFile;
import mock.MockProject;

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
import org.jastadd.plugin.compiler.AbstractCompiler;
import org.jastadd.plugin.compiler.ast.IASTNode;
import org.jmodelica.ide.helpers.DocumentReader;
import org.jmodelica.ide.helpers.Maybe;
import org.jmodelica.modelica.compiler.ASTNode;
import org.jmodelica.modelica.compiler.LibNode;
import org.jmodelica.modelica.compiler.SourceRoot;
import org.jmodelica.modelica.compiler.StoredDefinition;

public class ModelicaCompiler extends AbstractCompiler {

	public static final String ERROR_MARKER_ID = IDEConstants.ERROR_MARKER_ID;

	@Override
	public IASTNode compileToProjectAST(IProject project, IProgressMonitor monitor) {
		return recursiveCompile(new CompilationRoot(project), project, monitor).root();
	}

	private CompilationRoot recursiveCompile(CompilationRoot compilationRoot, IContainer parent,
			IProgressMonitor monitor) {
		try {

			IResource[] resources = parent.members();

			for (IResource resource : resources) {

				if (monitor.isCanceled())
					break;

				switch (resource.getType()) {
				case IResource.FOLDER:
					File dir = new File(resource.getRawLocation().toOSString());
					if (dir.isDirectory() && LibNode.packageMoPresentIn(dir.listFiles())) 
						compilationRoot.addPackageDirectory(dir);
					else
						recursiveCompile(compilationRoot, (IFolder) resource, monitor);
					break;
					
				case IResource.FILE:
					IFile file = (IFile) resource;
					if (IDEConstants.FILE_EXT.equals(file.getFileExtension()))
						compilationRoot.parseFile(file);
					break;
				}

				monitor.worked(1);
			}

		} catch (CoreException e) {
			e.printStackTrace();
		}

		return compilationRoot;
	}

	protected IFile defaultToMock(IFile file) {
		return new Maybe<IFile>(file).defaultTo(new MockFile(null, ""));
	}

	@Override
	public IASTNode compileToAST(IDocument document, DirtyRegion dirtyRegion, IRegion region,
			IFile file) {
		file = defaultToMock(file);
		CompilationRoot compilationRoot = new CompilationRoot(file.getProject());
		compilationRoot.parseFile(new DocumentReader(document), file);
		return compilationRoot.getStoredDefinition();
	}

	public Maybe<ASTNode<?>> recompile(IDocument doc, IFile file) {
		file = defaultToMock(file);
		return new Maybe<ASTNode<?>>((ASTNode<?>) compileToAST(doc, null, null, file));
	}

	public StoredDefinition recompile(String doc, IFile file) {
		file = defaultToMock(file);
		CompilationRoot lasr = new CompilationRoot(file.getProject());

		lasr.parseDoc(doc, file);

		return lasr.getStoredDefinition();
	}

	@Override
	protected IASTNode compileToAST(IFile file) {
		return compileFile(defaultToMock(file));
	}

	public StoredDefinition compileFile(IFile file) {
		file = defaultToMock(file);
		CompilationRoot compilationRoot = new CompilationRoot(file.getProject());

		compilationRoot.parseFile(file);

		return compilationRoot.getStoredDefinition();
	}

	public SourceRoot compileDirectory(File dir) {
		CompilationRoot cRoot = new CompilationRoot(MockProject.PROJECT);
		for (File f : dir.listFiles()) {
			if (f.isDirectory())
				compileDirectory(f);
			else
				cRoot.parseFile(new MockFile(f.getAbsolutePath()));
		}

		return cRoot.root();
	}

	public StoredDefinition compileString(String content) {
		return new CompilationRoot(new MockProject()).parseDoc(content, new MockFile())
				.getStoredDefinition();
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
