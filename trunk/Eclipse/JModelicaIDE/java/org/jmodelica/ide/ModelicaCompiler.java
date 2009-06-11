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
import org.jmodelica.ast.ASTNode;
import org.jmodelica.ast.BadDefinition;
import org.jmodelica.ast.List;
import org.jmodelica.ast.Program;
import org.jmodelica.ast.SourceRoot;
import org.jmodelica.ast.StoredDefinition;
import org.jmodelica.ide.error.CompileErrorReport;
import org.jmodelica.ide.error.InstanceErrorHandler;
import org.jmodelica.ide.helpers.DocumentReader;
import org.jmodelica.ide.helpers.Library;
import org.jmodelica.ide.scanners.generated.PackageExaminer;
import org.jmodelica.parser.ModelicaParser;
import org.jmodelica.parser.ModelicaScanner;

public class ModelicaCompiler extends AbstractCompiler {

	public ModelicaCompiler() {
		parser = new ModelicaParser();
		errorReport = new CompileErrorReport();
		instanceErrorHandler = new InstanceErrorHandler();
		examiner = new PackageExaminer();
		parser.setReport(errorReport);
		scanner = new ModelicaScanner(System.in);  // Dummy stream
	}

	public static final String ERROR_MARKER_ID = Constants.ERROR_MARKER_ID;
	private ModelicaParser parser;
	private List<StoredDefinition> list;
	private ModelicaScanner scanner;
	private IFile currentFile;
	private String currentPath;
	private CompileErrorReport errorReport;
	private InstanceErrorHandler instanceErrorHandler;
	private PackageExaminer examiner;

	@Override
	protected IASTNode compileToProjectAST(IProject project, IProgressMonitor monitor) {
		SourceRoot root = newRoot(project);
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
					recursiveCompile((IFolder) resource[i], monitor);
				} else if (type == IResource.FILE && extension != null
						&& extension.equals(Constants.FILE_EXTENSION)) {
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
	protected IASTNode compileToAST(IDocument document,
			DirtyRegion dirtyRegion, IRegion region, IFile file) {
		// TODO: Only compile the changed region, if possible
		newRoot(file.getProject());
		parseFile(new DocumentReader(document), file);
		return list.getChild(0);
	}

	@Override
	protected IASTNode compileToAST(IFile file) {
		return compileFile(file, file.getRawLocation().toOSString());
	}

	private SourceRoot newRoot(IProject project) {
		list = new List<StoredDefinition>();
		SourceRoot root = new SourceRoot(new Program(list));
		instanceErrorHandler.reset();
		root.setErrorHandler(instanceErrorHandler);

		if (project != null) {
			String libStr = null, defaultMSL = null;
			try {
				libStr = project.getPersistentProperty(Constants.PROPERTY_LIBRARIES_ID);
				defaultMSL = project.getPersistentProperty(Constants.PROPERTY_DEFAULT_MSL_ID);
			} catch (CoreException e) {
			}
			java.util.List<Library> libraries = Library.fromString(libStr);

			for (Library lib : libraries) 
				root.options.addModelicaLibrary(lib.name, lib.version.toString(), lib.path);
			root.options.setStringOption("default_msl_version", defaultMSL);
			
			// Find packages in root dir of project and add to library list
			try {
				for (IResource res : project.members()) {
					if (res.getType() == IResource.FOLDER) {
						IFolder folder = (IFolder) res;
						try {
							Library lib = examiner.examine(folder.getLocation().toOSString());
							if (lib.isOK())
								root.options.addModelicaLibrary(lib.name, lib.version.toString(), lib.path);
						} catch (FileNotFoundException e) {
						}
					}
				}
			} catch (CoreException e) {
			}
		}

		return root;
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
			scanner.yyreset(reader);
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
		if (currentFile == null)
			def.setFileName(currentPath);
		list.add(def);
	}
	
	public ASTNode compileFile(IFile file, String path) {
		newRoot(file != null ? file.getProject() : null);
		parseFile(file, path);
		return list.getChild(0);
	}

	@Override
	protected Collection<String> acceptedFileExtensions() {
		return Arrays.asList(Constants.All_FILE_EXTENSIONS);
	}

	@Override
	protected String acceptedNatureID() {
		return Constants.NATURE_ID;
	}
}
