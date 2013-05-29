package org.jmodelica.ide.textual.editor;

import org.eclipse.core.resources.IFile;
import org.eclipse.core.resources.IProject;
import org.eclipse.jface.text.IDocument;
import org.eclipse.jface.text.reconciler.IReconcilingStrategy;
import org.jastadd.ed.core.ReconcilingStrategy;
import org.jastadd.ed.core.model.IASTChangeEvent;
import org.jastadd.ed.core.model.IASTChangeListener;
import org.jastadd.ed.core.model.node.LocalRootHandle;
import org.jmodelica.ide.compiler.ModelicaEclipseCompiler;
import org.jmodelica.ide.helpers.EditorFile;
import org.jmodelica.ide.sync.ChangePropagationController;
import org.jmodelica.ide.sync.ListenerObject;
import org.jmodelica.ide.sync.ModelicaASTRegistry;

public class GlobalCompilationResult extends CompilationResult {

	private final String key;
	private final IProject project;
	private final EditorFile editorFile;

	public GlobalCompilationResult(EditorFile ef, Editor editor) {

		editorFile = ef;
		key = ef.toRegistryKey();
		project = ef.iFile().getProject();

		if (project != null)
			root = ModelicaASTRegistry.getInstance().getLatestDef(
					editorFile.iFile());
		ListenerObject listObj = new ListenerObject(editor,
				IASTChangeListener.TEXTEDITOR_LISTENER);
		ChangePropagationController.getInstance().addListener(listObj,
				editorFile.iFile(), null);
	}

	public void update(IProject projChanged, String keyChanged) {
		if (project == projChanged && keyChanged.equals(key)) {
			root = ModelicaASTRegistry.getInstance().getLatestDef(
					editorFile.iFile());
		}
	}

	public void update(IProject projChanged) {
		this.update(projChanged, key);
	}

	public void dispose(Editor editor) {
		ChangePropagationController.getInstance().removeListener(editor,
				editorFile.iFile(), null);
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