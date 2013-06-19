package org.jmodelica.ide.compiler;

import java.io.File;
import java.io.IOException;
import java.io.Reader;
import java.io.StringReader;

import org.eclipse.core.resources.IFile;
import org.eclipse.core.resources.IProject;
import org.jmodelica.ide.IDEConstants;
import org.jmodelica.ide.error.CompileErrorReport;
import org.jmodelica.ide.error.InstanceErrorHandler;
import org.jmodelica.ide.helpers.Util;
import org.jmodelica.modelica.compiler.BadDefinition;
import org.jmodelica.modelica.compiler.List;
import org.jmodelica.modelica.compiler.ParserException;
import org.jmodelica.modelica.compiler.ParserHandler;
import org.jmodelica.modelica.compiler.Program;
import org.jmodelica.modelica.compiler.SourceRoot;
import org.jmodelica.modelica.compiler.StoredDefinition;
import org.jmodelica.modelica.parser.ModelicaParser;
import org.jmodelica.modelica.parser.ModelicaScanner;
import org.jmodelica.util.AbstractModelicaScanner;


/**
 * 
 * Represents a SourceRoot capable of compiling and adding more
 * StoredDefinitions.
 */
public class CompilationRoot {

	private final CompileErrorReport errorReport = new CompileErrorReport();

	private final SourceRoot root;
	private final List<StoredDefinition> list;
	
	private boolean rewritten;

	/**
	 * Create an empty CompilationRoot
	 */
	public CompilationRoot(IProject project) {
		list = new List<StoredDefinition>();
		Program prog = new Program(list);
		root = new SourceRoot(prog);

		root.options = new IDEOptions(project);
		root.setProject(project);
		root.setErrorHandler(new InstanceErrorHandler());
		
		prog.setLibraryList(new IDELibraryList(root.options, project));
		prog.getInstProgramRoot().options = root.options;

		rewritten = false;
	}

	/**
	 * Returns the StoredDefinition for the first compilation. 
	 * Use when you want to only compile a single file.
	 * 
	 * @return StoredDefinition from the first compilation, or null if no
	 *         successful compilation has been performed.
	 */
	public StoredDefinition getStoredDefinition() {
		forceRewrites();
		return list.getNumChild() > 0 ? list.getChild(0) : null;
	}
	
	protected void forceRewrites() {
		if (!rewritten) {
			synchronized (root.state()) {
				// Depends on ASTNode.state being static (if it isn't, this probably doesn't need synchronization) 
				root.forceRewrites();
			}
		}
		rewritten = true;
	}

	protected StoredDefinition annotatedDefinition(StoredDefinition def, IFile file) {
		def.setFile(file);
		def.setFileName(file.getRawLocation().toOSString());
		return def;
	}

	/**
	 * Returns internal SourceRoot.
	 */
	public SourceRoot root() {
		forceRewrites();
		return root;
	}

	/**
	 * Compile and add AST from string.
	 * 
	 * @param doc
	 *            string to compile
	 * @param file
	 *            eclipse file handle. Used as a key to identify the resulting
	 *            StoredDefinition.
	 * @return this
	 */
	public CompilationRoot parseDoc(String doc, IFile file) {
		parseFile(new StringReader(doc), file, true);
		return this;
	}

	public void parseDocs(String[] docs, IFile file) {
		for (String doc : docs)
			parseDoc(doc, file);
	}

	/**
	 * Parse content and add to source root.
	 */
	public CompilationRoot parseFile(IFile file) {
		try {
			parseFile(Util.fileReader(file), file, true);
		} catch (IOException e) {
			addBadDef(file);
		}
		return this;
	}

	public void parseFile(Reader reader, IFile file, boolean clearSemantic) {		
		errorReport.setFile(file, clearSemantic);

		try {
			AbstractModelicaScanner scanner = getScanner(reader);
			SourceRoot localRoot = (SourceRoot) getParser(scanner).parse(scanner);
			for (StoredDefinition def : localRoot.getProgram().getUnstructuredEntitys()) 
				list.add(annotatedDefinition(def, file));
		} catch (ModelicaParser.Exception e) {
			addBadDef(file);
		} catch (ParserException e) {
			addBadDef(file);
		} catch (IOException e) {
			addBadDef(file);
		} finally {
			errorReport.cleanUp();
			rewritten = false;

			try {
				reader.close();
			} catch (IOException e) {
			}
		}
	}
	
	private ModelicaParser getParser(AbstractModelicaScanner scanner) {
		ModelicaParser parser = (ModelicaParser)ParserHandler.createModelicaParser(scanner);
		parser.setReport(errorReport);
		return parser;
	}

	private AbstractModelicaScanner getScanner(Reader reader) {
		AbstractModelicaScanner scanner = ParserHandler.createModelicaScanner(reader);
		return scanner;
	}	
	
	public void addPackageDirectory(File dir) {
		try {
			String path = root.options.getStringOption(IDEConstants.PACKAGES_IN_WORKSPACE_OPTION);
			path += (path.equals("") ? "" : File.pathSeparator) + dir.getAbsolutePath();
			root.options.setStringOption(IDEConstants.PACKAGES_IN_WORKSPACE_OPTION, path);
		} catch (Exception e) {
			e.printStackTrace();
		}
	}

	private void addBadDef(IFile file) {
		list.add(annotatedDefinition(new BadDefinition(), file));
		rewritten = false;
	}

}