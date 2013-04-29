package org.jmodelica.ide.textual.editor;

import org.eclipse.core.resources.IFile;
import org.eclipse.core.resources.IProject;
import org.eclipse.jface.text.IDocument;
import org.eclipse.jface.text.reconciler.IReconcilingStrategy;
import org.jastadd.ed.core.model.IASTChangeEvent;
import org.jmodelica.ide.compiler.ModelicaEclipseCompiler;
import org.jmodelica.ide.helpers.EditorFile;
import org.jmodelica.ide.sync.LocalRootNode;


public class LocalCompilationResult extends CompilationResult {

private final Editor editor;
private final ModelicaEclipseCompiler compiler;

public LocalCompilationResult(EditorFile ef, Editor ed) {

    compiler = new ModelicaEclipseCompiler();
    root = ((LocalRootNode)compiler.compile(ef.iFile())).getDef();
    editor = ed;
    
}

public void update(IProject projChanged, String keyChanged) { }
public void update(IProject projChanged) { }
public void dispose(Editor editor) { }

public void recompileLocal(IDocument doc, IFile file) {
    root = ((LocalRootNode)compiler.recompile(doc, file)).getDef();
}

@Override
public IReconcilingStrategy compilationStrategy() {
    return new LocalReconcilingStrategy(editor);
}

@Override
public void update(IASTChangeEvent e) {
	System.out.println("LOCALCOMPILATIONRESUT --> ERROR: Not implemented update...");
}

}