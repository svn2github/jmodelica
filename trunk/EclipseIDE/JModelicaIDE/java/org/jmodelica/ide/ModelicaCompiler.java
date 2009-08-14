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

import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.IOException;
import java.io.Reader;
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
import org.jastadd.plugin.compiler.AbstractCompiler;
import org.jastadd.plugin.compiler.ast.IASTNode;
import org.jmodelica.ide.error.CompileErrorReport;
import org.jmodelica.ide.error.InstanceErrorHandler;
import org.jmodelica.ide.helpers.DocumentReader;
import org.jmodelica.ide.helpers.Library;
import org.jmodelica.ide.scanners.generated.PackageExaminer;
import org.jmodelica.modelica.compiler.ASTNode;
import org.jmodelica.modelica.compiler.BadDefinition;
import org.jmodelica.modelica.compiler.List;
import org.jmodelica.modelica.compiler.Program;
import org.jmodelica.modelica.compiler.SourceRoot;
import org.jmodelica.modelica.compiler.StoredDefinition;
import org.jmodelica.modelica.parser.ModelicaParser;
import org.jmodelica.modelica.parser.ModelicaScanner;

public class ModelicaCompiler extends AbstractCompiler {

	public ModelicaCompiler() {
		parser = new ModelicaParser();
		errorReport = new CompileErrorReport();
		instanceErrorHandler = new InstanceErrorHandler();
		examiner = new PackageExaminer();
		parser.setReport(errorReport);
		scanner = new ModelicaScanner(System.in);  // Dummy stream
	}

	public static final String ERROR_MARKER_ID = IDEConstants.ERROR_MARKER_ID;
	private ModelicaParser parser;
	private List<StoredDefinition> list;
	private ModelicaScanner scanner;
	private IFile currentFile;
	private String currentPath;
	private CompileErrorReport errorReport;
	private InstanceErrorHandler instanceErrorHandler;
	private PackageExaminer examiner;
	private SourceRoot root;

	@Override
	protected IASTNode compileToProjectAST(IProject project, IProgressMonitor monitor) {
		newRoot(project);
		recursiveCompile(project, monitor);
		return root;
	}

	private void recursiveCompile(IContainer parent, IProgressMonitor monitor) {
		try {
			IResource[] resource = parent.members();
			for (int i = 0; i < resource.length && !monitor.isCanceled(); i++) {

				// Make sure this is a file we want to compile
				String extension = resource[i].getFileExtension();
				int type = resource[i].getType();
				if (type == IResource.FOLDER) {
					// If it is a package, add to library list, otherwise, recurse
					IFolder folder = (IFolder) resource[i];
					try {
						Library lib = examiner.examine(folder.getLocation().toOSString());
						if (lib.isOK())
							root.options.addModelicaLibrary(lib.name, lib.version.toString(), lib.path);
					} catch (FileNotFoundException e) {
						recursiveCompile((IFolder) resource[i], monitor);
					}
				} else if (type == IResource.FILE && extension != null
						&& extension.equals(IDEConstants.FILE_EXTENSION)) {
					// Convert to IFile and get content
					IFile file = (IFile) resource[i];
					parseFile(file, null);
				}
				
				monitor.worked(1);
			}
		} catch (CoreException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}

	@Override
	public IASTNode compileToAST(IDocument document,
			DirtyRegion dirtyRegion, IRegion region, IFile file) {
		// TODO: Only compile the changed region, if possible
		newRoot(file != null ? file.getProject() : null);
		parseFile(new DocumentReader(document), file);
		return list.getChild(0);
	}

	@Override
	protected IASTNode compileToAST(IFile file) {
		return compileFile(file, file.getRawLocation().toOSString());
	}

	private void newRoot(IProject project) {
		list = new List<StoredDefinition>();
		root = new SourceRoot(new Program(list));
		instanceErrorHandler.reset();
		root.setErrorHandler(instanceErrorHandler);

		if (project != null) {
			String libStr = null, defaultMSL = null;
			try {
				libStr = project.getPersistentProperty(IDEConstants.PROPERTY_LIBRARIES_ID);
				defaultMSL = project.getPersistentProperty(IDEConstants.PROPERTY_DEFAULT_MSL_ID);
			} catch (CoreException e) {
			}
			java.util.List<Library> libraries = Library.fromString(libStr);

			for (Library lib : libraries) 
				root.options.addModelicaLibrary(lib.name, lib.version.toString(), lib.path);
			root.options.setStringOption("default_msl_version", defaultMSL);
		}
	}

	private void parseFile(IFile file, String path) {
		try {
			// Parse content and add to source root
			if (path == null)
				path = file.getRawLocation().toOSString();
			currentPath = path;
			Reader reader = new FileReader(path);
			parseFile(reader, file);
			reader.close();
			
		} catch (IOException e) {
			addDefinition(new BadDefinition());
		}
	}

	private void parseFile(Reader reader, IFile file) {
		try {
			currentFile = file;
			errorReport.setFile(file);
			scanner.reset(reader);
			SourceRoot localRoot = (SourceRoot) parser.parse(scanner);
			
			for (StoredDefinition def : localRoot.getProgram().getUnstructuredEntitys()) 
				addDefinition(def);
			
		} catch (Exception e) {
			addDefinition(new BadDefinition());
		} finally {
			errorReport.cleanUp();
		}
	}

	private void addDefinition(StoredDefinition def) {
		def.setFile(currentFile);
		def.setLineBreakMap(scanner.getLineBreakMap());
		if (currentFile == null) 
			def.setFileName(currentPath);
		list.add(def);
	}
	
	public ASTNode<?> compileFile(IFile file, String path) {
		newRoot(file != null ? file.getProject() : null);
		parseFile(file, path);
		return list.getChild(0);
	}

	@Override
	protected Collection<String> acceptedFileExtensions() {
		return Arrays.asList(IDEConstants.All_FILE_EXTENSIONS);
	}

	@Override
	protected String acceptedNatureID() {
		return IDEConstants.NATURE_ID;
	}
}
