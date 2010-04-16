package org.jmodelica.ide;

import java.io.File;
import java.io.FileReader;
import java.io.IOException;
import java.io.Reader;
import java.io.StringReader;

import org.eclipse.core.resources.IFile;
import org.eclipse.core.resources.IProject;
import org.eclipse.core.resources.IResource;
import org.jmodelica.ide.error.CompileErrorReport;
import org.jmodelica.ide.error.InstanceErrorHandler;
import org.jmodelica.modelica.compiler.BadDefinition;
import org.jmodelica.modelica.compiler.LibNode;
import org.jmodelica.modelica.compiler.List;
import org.jmodelica.modelica.compiler.ParserException;
import org.jmodelica.modelica.compiler.Program;
import org.jmodelica.modelica.compiler.SourceRoot;
import org.jmodelica.modelica.compiler.StoredDefinition;
import org.jmodelica.modelica.parser.ModelicaParser;
import org.jmodelica.modelica.parser.ModelicaScanner;

import beaver.Parser;

/**
 * 
 * Represents a SourceRoot capable of compiling and adding more
 * StoredDefinitions.
 * 
 * @author philip
 * 
 */
public class CompilationRoot {

	private final ModelicaParser PARSER = new ModelicaParser();
	private final ModelicaScanner SCANNER = new ModelicaScanner(System.in); // Dummy stream
	private final CompileErrorReport errorReport = new CompileErrorReport();

	private final SourceRoot root;
	private final List<StoredDefinition> list;
	private final InstanceErrorHandler handler;

	/**
	 * Create an empty CompilationRoot
	 * 
	 * @param report
	 *            ErrorReport implementation for parser to use. Defaults to
	 *            {@link ModelicaParser.AbortingReport} if Nothing is passed.
	 */
	public CompilationRoot(IProject project) {
		this.list    = new List<StoredDefinition>();
		this.root    = new SourceRoot(new Program(list));
		this.handler = new InstanceErrorHandler();

		PARSER.setReport(errorReport);
		root.setErrorHandler(handler);
		
		root.options = new IDEOptions(project);
		root.getProgram().getInstProgramRoot().options = root.options;

	}

	/**
	 * Returns the StoredDefinition for the first compilation. Really supposed
	 * to be used when you want to only compile a single file.
	 * 
	 * @return StoredDefinition from the first compilation, or null if no
	 *         successful compilation has been performed.
	 */
	public StoredDefinition getStoredDefinition() {

	    assert list.getNumChild() > 0; 
		
		return list.getNumChild() > 0 ? list.getChild(0) : null;
	}

	protected StoredDefinition annotatedDefinition(StoredDefinition def, IFile file) {
		def.setFile(file);
		def.setFileName(file.getRawLocation().toOSString());
		def.setLineBreakMap(SCANNER.getLineBreakMap());

		return def;
	}

	/**
	 * Returns internal SourceRoot.
	 */
	public SourceRoot root() {
		return root;
	}

	/**
	 * Compile and add AST from string.
	 * 
	 * @param doc   string to compile
	 * @param file  eclipse file handle. Used as a key to identify the resulting
	 *              StoredDefinition.
	 * @return this
	 */
	public CompilationRoot parseDoc(String doc, IFile file) {
		parseFile(new StringReader(doc), file);
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
			parseFile(new FileReader(file.getRawLocation().toOSString()), file);
		} catch (IOException e) {
			addBadDef(file);
		}
		return this;
	}

	public void parseFile(Reader reader, IFile file) {

		errorReport.setFile(file);
		SCANNER.reset(reader);

		try {
			SourceRoot localRoot = (SourceRoot) PARSER.parse(SCANNER);
			for (StoredDefinition def : localRoot.getProgram().getUnstructuredEntitys()) { 
				list.add(annotatedDefinition(def, file));
			}
		} catch (Parser.Exception e) {
			addBadDef(file);
			e.printStackTrace();
		} catch (ParserException e) {
		    e.printStackTrace();
			addBadDef(file);
		} catch (IOException e) {
		    e.printStackTrace();
			addBadDef(file);
		} finally {
			errorReport.cleanUp();

			try {
				reader.close();
			} catch (IOException e) {
				e.printStackTrace();
			}
		}
	}
	
	public void addPackageDirectory(IResource dir) {
	    
        try {
            File file =
                new File(dir.getRawLocation().toOSString());
            
            if (file.isDirectory() && 
                LibNode.packageMoPresentIn(file.listFiles())) 
            {
                String path =
                    root.options.getStringOption("PACKAGEPATHS");
                
                path += 
                    file.getAbsolutePath();
            
                root.options.setStringOption(
                        "PACKAGEPATHS",
                        path);
            }
            
        } catch (Exception e) {
            e.printStackTrace();
        }
        
	   
	}

	private void addBadDef(IFile file) {
		list.add(annotatedDefinition(new BadDefinition(), file));
	}

}