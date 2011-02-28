package org.jmodelica.ide.editor;

import org.eclipse.core.resources.IFile;
import org.eclipse.jface.text.reconciler.IReconcilingStrategy;
import org.jastadd.plugin.ReconcilingStrategy;

class ModelicaCompilationStrategy {

public final ReconcilingStrategy normalStrategy;
public final LocalReconcilingStrategy localStrategy;

public boolean compiledLocal;

public ModelicaCompilationStrategy(Editor editor) {
    normalStrategy = new ReconcilingStrategy();
    localStrategy = new LocalReconcilingStrategy(editor);
    compiledLocal = false;
}

public IReconcilingStrategy getStrategy() {
    return compiledLocal ? localStrategy : normalStrategy;
}

public void update(IFile file, boolean compiledLocally) {
    normalStrategy.setFile(file); 
    compiledLocal = compiledLocally;
}

}
