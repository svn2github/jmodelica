package org.jmodelica.ide.documentation.sync;

import java.util.HashMap;
import java.util.Stack;

import org.eclipse.core.resources.IFile;
import org.jastadd.ed.core.model.IASTPathPart;
import org.jmodelica.ide.documentation.Generator;
import org.jmodelica.ide.sync.GlobalRootNode;
import org.jmodelica.ide.sync.ModelicaASTRegistry;
import org.jmodelica.ide.sync.tasks.AbstractDocumentationTask;
import org.jmodelica.modelica.compiler.FullClassDecl;
import org.jmodelica.modelica.compiler.SourceRoot;
import org.jmodelica.modelica.compiler.StoredDefinition;

public class SaveFCDDocumentationTask extends AbstractDocumentationTask {
	private HashMap<String, Boolean> checkBoxes;
	private Stack<IASTPathPart> classASTPath;
	private String rootPath;

	public SaveFCDDocumentationTask(IFile file, String rootPath,
			HashMap<String, Boolean> checkBoxes, Stack<IASTPathPart> classASTPath) {
		super(file, null);
		this.checkBoxes = checkBoxes;
		this.classASTPath = classASTPath;
		this.rootPath = rootPath;
	}

	@Override
	public void doJob() {
		StoredDefinition def = ModelicaASTRegistry.getInstance().getLatestDef(
				file);
		SourceRoot sroot = ((GlobalRootNode) ModelicaASTRegistry.getInstance()
				.doLookup(file.getProject())).getSourceRoot();
		FullClassDecl fcd = (FullClassDecl) ModelicaASTRegistry.getInstance()
				.resolveSourceASTPath(def, classASTPath);
		Generator.genDocWizardPerformFinish(fcd, rootPath, sroot, checkBoxes);
	}
}