package org.jmodelica.ide.documentation.sync;

import org.eclipse.core.resources.IFile;
import org.jastadd.ed.core.model.IASTChangeListener;
import org.jmodelica.ide.documentation.Generator;
import org.jmodelica.ide.documentation.HistoryObject;
import org.jmodelica.ide.sync.GlobalRootNode;
import org.jmodelica.ide.sync.ModelicaASTRegistry;
import org.jmodelica.ide.sync.tasks.AbstractDocumentationTask;
import org.jmodelica.modelica.compiler.FullClassDecl;
import org.jmodelica.modelica.compiler.SourceRoot;
import org.jmodelica.modelica.compiler.StoredDefinition;

public class RenderClassDeclTask extends AbstractDocumentationTask {
	private String tinymcePath;
	private String classCodeSourcePath;
	private boolean setHistory;
	private HistoryObject history;

	public RenderClassDeclTask(boolean setHistory, IFile file,
			IASTChangeListener myListener, String tinymcePath,
			HistoryObject history, String classCodeSourcePath) {
		super(file, myListener);
		this.setHistory = setHistory;
		this.tinymcePath = tinymcePath;
		this.history = history;
		this.classCodeSourcePath = classCodeSourcePath;
	}

	@Override
	public void doJob() {
		StoredDefinition def = ModelicaASTRegistry.getInstance().getLatestDef(
				file);
		SourceRoot sroot = ((GlobalRootNode) ModelicaASTRegistry.getInstance()
				.doLookup(file.getProject())).getSourceRoot();
		FullClassDecl fcd = (FullClassDecl) ModelicaASTRegistry.getInstance()
				.resolveSourceASTPath(def, history.getClassASTPath());
		String renderedClassDecl = Generator.renderClassDecl(fcd, sroot,
				tinymcePath, classCodeSourcePath);
		RenderClassDeclEvent event = new RenderClassDeclEvent(
				renderedClassDecl, history, setHistory);
		myListener.astChanged(event);
	}
}