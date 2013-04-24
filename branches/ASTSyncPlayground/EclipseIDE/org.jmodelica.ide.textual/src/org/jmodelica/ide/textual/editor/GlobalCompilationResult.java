package org.jmodelica.ide.textual.editor;

import org.eclipse.core.resources.IFile;
import org.eclipse.core.resources.IProject;
import org.eclipse.jface.text.IDocument;
import org.eclipse.jface.text.reconciler.IReconcilingStrategy;
import org.jastadd.ed.core.ReconcilingStrategy;
import org.jastadd.ed.core.model.IASTChangeEvent;
import org.jastadd.ed.core.model.IASTChangeListener;
import org.jastadd.ed.core.model.node.LocalRootHandle;
import org.jmodelica.ide.compiler.ListenerObject;
import org.jmodelica.ide.compiler.LocalRootNode;
import org.jmodelica.ide.compiler.ModelicaASTRegistry;
import org.jmodelica.ide.compiler.ModelicaEclipseCompiler;
import org.jmodelica.ide.helpers.EditorFile;
import org.jmodelica.modelica.compiler.ASTNode;

public class GlobalCompilationResult extends CompilationResult {

	private final String key;
	private final IProject project;
	private final EditorFile editorFile;

	public GlobalCompilationResult(EditorFile ef, Editor editor) {

		editorFile = ef;

		ModelicaASTRegistry registry = ModelicaASTRegistry.getInstance();
		key = ef.toRegistryKey();
		project = ef.iFile().getProject();

		if (project != null)
			root = (ASTNode<?>) ((LocalRootNode) registry.doLookup(ef.iFile())[0])
					.getDef();
		// root = (ASTNode<?>) registry.lookupAST(key, project);

		// registry.addListener(editor); // TODO JL listen against files, not
		// against all...
		ListenerObject listObj = new ListenerObject(editor, IASTChangeListener.TEXTEDITOR_LISTENER);
		ModelicaASTRegistry.getInstance().addListener(editorFile.iFile(), null,
				listObj);
	}

	public void update(IProject projChanged, String keyChanged) {
		if (project == projChanged && keyChanged.equals(key)) {
			LocalRootNode fileNode = (LocalRootNode) ModelicaASTRegistry.getInstance()
					.doLookup(editorFile.iFile())[0];
			root = (ASTNode<?>) fileNode.getDef();
		}
	}

	public void update(IProject projChanged) {
		this.update(projChanged, key);
	}

	public void dispose(Editor editor) {
		ModelicaASTRegistry.getInstance().removeListener(editor);
	}

	public void recompileLocal(IDocument doc, IFile file) {
	}

	public IReconcilingStrategy compilationStrategy() {
		LocalRootHandle handle = new LocalRootHandle(
				ModelicaASTRegistry.getInstance());
		handle.setFile(editorFile.iFile(), true);
		ReconcilingStrategy strategy = new ReconcilingStrategy(handle,
				new ModelicaEclipseCompiler());
		return strategy;
	}

	@Override
	public void update(IASTChangeEvent e) {
		this.update(project);
	}

}