package org.jmodelica.ide;

import java.io.FileReader;
import java.io.IOException;
import java.io.Reader;

import org.eclipse.core.resources.IFile;
import org.jmodelica.ide.error.CompileErrorReport;
import org.jmodelica.ide.error.InstanceErrorHandler;
import org.jmodelica.modelica.compiler.BadDefinition;
import org.jmodelica.modelica.compiler.List;
import org.jmodelica.modelica.compiler.Program;
import org.jmodelica.modelica.compiler.SourceRoot;
import org.jmodelica.modelica.compiler.StoredDefinition;
import org.jmodelica.modelica.parser.ModelicaParser;
import org.jmodelica.modelica.parser.ModelicaScanner;

/**
 * 
 * @author philip
 *
 */
class CompilationRoot {

private final ModelicaParser PARSER = new ModelicaParser();
private final ModelicaScanner SCANNER = 
    new ModelicaScanner(System.in); // Dummy stream
private final CompileErrorReport errorReport = new CompileErrorReport();
private final SourceRoot root;
private final List<StoredDefinition> list;
private final InstanceErrorHandler handler;


public CompilationRoot() {
    this.list = new List<StoredDefinition>();
    this.root = new SourceRoot(new Program(list));
    this.handler = new InstanceErrorHandler();
    root.setErrorHandler(handler);
}

public StoredDefinition getStoredDefinition() {
    return list.getNumChild() > 0 ? list.getChild(0) : null;
}

public StoredDefinition annotatedDefinition(
        StoredDefinition def,
        IFile file, 
        String path) {
    
    def.setFile(file);
    def.setFileName(path == null ? "" : path);
    def.setLineBreakMap(SCANNER.getLineBreakMap());
    
    return def;
}

public SourceRoot root() {
    return root;
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

/**
 * Parse content and add to source root.
 */
public CompilationRoot parseFile(Reader reader, IFile file, String path) {

    errorReport.setFile(file);
    SCANNER.reset(reader);
    
    try {
        SourceRoot localRoot = (SourceRoot) PARSER.parse(SCANNER);

        for (StoredDefinition def : localRoot.getProgram()
                .getUnstructuredEntitys())
            list.add(annotatedDefinition(def, file, path));

    } catch (Exception e) {
        
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