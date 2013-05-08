package org.jmodelica.ide.documentation.sync;

import java.io.ByteArrayInputStream;
import org.eclipse.core.resources.IFile;
import org.eclipse.core.runtime.SafeRunner;
import org.eclipse.jface.util.SafeRunnable;
import org.jmodelica.ide.documentation.Generator;
import org.jmodelica.ide.documentation.HistoryObject;
import org.jmodelica.ide.sync.GlobalRootNode;
import org.jmodelica.ide.sync.ModelicaASTRegistry;
import org.jmodelica.ide.sync.tasks.AbstractDocumentationTask;
import org.jmodelica.modelica.compiler.FullClassDecl;
import org.jmodelica.modelica.compiler.Program;
import org.jmodelica.modelica.compiler.SourceRoot;
import org.jmodelica.modelica.compiler.StoredDefinition;
import org.jmodelica.modelica.compiler.StringLitExp;

public class SaveFCDAnnotationTask extends AbstractDocumentationTask {
	public static final int TYPE_INFORMATION = 0;
	public static final int TYPE_REVISION = 1;

	private int type;
	private String annotationString;
	private StoredDefinition definition;
	private HistoryObject history;

	public SaveFCDAnnotationTask(int type, String annotationString,
			HistoryObject history, IFile file) {
		super(file, null);
		this.annotationString = annotationString;
		this.history = history;
		this.type = type;
	}

	@Override
	public void doJob() {
		SourceRoot sroot = ((GlobalRootNode) ModelicaASTRegistry.getInstance()
				.doLookup(file.getProject())).getSourceRoot();
		Program program = sroot.getProgram();
		StringLitExp exp = new StringLitExp(
				Generator.htmlToModelica(annotationString));
		definition = ModelicaASTRegistry.getInstance().getLatestDef(file);
		synchronized (program.state()) {
			FullClassDecl fcd = (FullClassDecl) ModelicaASTRegistry
					.getInstance().resolveSourceASTPath(definition,
							history.getClassASTPath());
			if (type == SaveFCDAnnotationTask.TYPE_INFORMATION) {
				fcd.annotation().forPath("Documentation/info").setValue(exp);
			} else if (type == SaveFCDAnnotationTask.TYPE_REVISION) {
				fcd.annotation().forPath("Documentation/revisions")
						.setValue(exp);
			}
			fcd.flushCache();
			if (definition == null || definition.getFile() == null) {
				System.err
						.print("Couldn't get the definition of the class: "
								+ fcd.getNodeName()
								+ ", or it's corresponding file. Is it part of the standard library?");
				return;
			}
			SafeRunner.run(new SafeRunnable() {
				@Override
				public void run() throws Exception {
					getDefinition().getFile().setContents(
							new ByteArrayInputStream(getDefinition()
									.prettyPrintFormatted().getBytes()), true,
							true, null);
				}
			});
		}
		System.err.println("Successfully saved annotationString?");
	}

	protected StoredDefinition getDefinition() {
		return definition;
	}
}