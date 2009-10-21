package org.jmodelica.ide;

import java.io.File;
import java.io.FileReader;
import java.io.IOException;
import java.io.Reader;
import java.io.StringReader;
import java.util.LinkedList;

import org.eclipse.core.resources.IFile;
import org.eclipse.core.resources.IProject;
import org.jmodelica.ide.error.CompileErrorReport;
import org.jmodelica.ide.error.InstanceErrorHandler;
import org.jmodelica.ide.helpers.Library;
import org.jmodelica.ide.helpers.Maybe;
import org.jmodelica.ide.helpers.Util;
import org.jmodelica.modelica.compiler.BadDefinition;
import org.jmodelica.modelica.compiler.List;
import org.jmodelica.modelica.compiler.ParserException;
import org.jmodelica.modelica.compiler.Program;
import org.jmodelica.modelica.compiler.SourceRoot;
import org.jmodelica.modelica.compiler.StoredDefinition;
import org.jmodelica.modelica.parser.ModelicaParser;
import org.jmodelica.modelica.parser.ModelicaScanner;
import org.jmodelica.util.OptionRegistry;

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
private final ModelicaScanner SCANNER =  
    new ModelicaScanner(System.in); // Dummy stream
private final CompileErrorReport errorReport = new CompileErrorReport();
private final SourceRoot root; 
private final List<StoredDefinition> list;
private final InstanceErrorHandler handler;

/**
 * Create an empty CompilationRoot 
 * @param report ErrorReport implementation for parser to use. Defaults to
 *            {@link ModelicaParser.AbortingReport} if Nothing is passed.
 */
public CompilationRoot(
        Maybe<? extends ModelicaParser.Report> report, 
        IProject project) 
{
    this.list = 
        new List<StoredDefinition>();
    this.root = 
        new SourceRoot(
            new Program(list));
    this.handler = 
        new InstanceErrorHandler();
    
    root.setErrorHandler(handler);
    
    if (report.hasValue())
        PARSER.setReport(report.value());

    try {
        
        root.options.copyAllOptions(
            new OptionRegistry(
                project
                .getPersistentProperty(
                    IDEConstants.PROPTERTY_OPTIONS_PATH)
                + "/options.xml"));

        root.options.setStringOption(
            "MODELICAPATH", 
            Library.makeModelicaPath(
                project
                .getPersistentProperty(
                    IDEConstants.PROPERTY_LIBRARIES_ID)));
        
        root.getProgram().getInstProgramRoot().options =
            root.options;

    } catch (Exception e) {
        e.printStackTrace();
    }
}

public CompilationRoot(IProject project) {
    this(
        Maybe.Just(new ModelicaParser.CollectingReport()),
        project);
}

/**
 * Returns the StoredDefinition for the first compilation. Really supposed to be
 * used when you want to only compile a single file.
 * 
 * @return StoredDefinition from the first compilation, or null if no successful
 *         compilation has been performed.
 */
public StoredDefinition getStoredDefinition() {
    assert list.getNumChild() <= 1;
    return list.getNumChild() > 0 ? list.getChild(0) : null;
}

protected StoredDefinition annotatedDefinition(
        StoredDefinition def,
        IFile file, 
        String path) {
    
    def.setFile(file);
    def.setFileName(path == null ? "" : path);
    def.setLineBreakMap(SCANNER.getLineBreakMap());
    
    return def;
}

/**
 * Returns internal SourceRoot.
 * @return internal SourceRoot
 */
public SourceRoot root() {
    return root;
}

/**
 * Compile and add AST from string.
 * 
 * @param doc string to compile
 * @param file eclipse file handle. Used as a key to identify the resulting
 *            StoredDefinition.
 * @return this
 */
public CompilationRoot parseDoc(String doc, IFile file) {
    return parseFile(new StringReader(doc), file, null);
}

public CompilationRoot parseDocs(String[] docs, IFile file) {
    for (String doc : docs)
        parseDoc(doc, file);
    return this;
}

/** 
 * Parse content and add to source root.
 */
public CompilationRoot parseFile(IFile file, String path) {
    
    try {
        if (path == null)
            path = file.getRawLocation().toOSString();
        parseFile(new FileReader(path), file, path);

    } catch (IOException e) {
        list.add(annotatedDefinition(new BadDefinition(), file, path));
    }
    
    return this;
}


public CompilationRoot parseFile(Reader reader, IFile file, String path) {

    errorReport.setFile(file);
    SCANNER.reset(reader);
    
    try {
        
        SourceRoot localRoot = 
            (SourceRoot) PARSER.parse(SCANNER);
        
        for (StoredDefinition def 
                : localRoot.getProgram().getUnstructuredEntitys()) 
        {
            list.add(annotatedDefinition(def, file, path));
        }
        
        
        
    } catch (Parser.Exception e) {
        System.out.println("Parse unsuccessful: " + path);
        list.add(annotatedDefinition(new BadDefinition(), file, path));
    } catch (ParserException e) {
        System.out.println("Parse unsuccessful: " + path);
        list.add(annotatedDefinition(new BadDefinition(), file, path));
    } catch (IOException e) { 
        e.printStackTrace();
        list.add(annotatedDefinition(new BadDefinition(), file, path));
    } finally {
        
        errorReport.cleanUp();
        
        try {
            reader.close();
        } catch (IOException e) {
            e.printStackTrace();
        }
    }
    
    return this;
}

}