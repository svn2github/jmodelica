package org.jmodelica.ide.documentation.sync;

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
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

public class GoToWYSIWYGTask extends AbstractDocumentationTask {
	private String tinymcePath;
	private boolean isInfo;
	private String divContent;
	private HistoryObject history;

	public GoToWYSIWYGTask(IFile file, IASTChangeListener myListener,
			String divContent, String tinymcePath, boolean isInfo,
			HistoryObject history) {
		super(file, myListener);
		this.divContent = divContent;
		this.tinymcePath = tinymcePath;
		this.isInfo = isInfo;
		this.history = history;
	}

	@Override
	public void doJob() {
		SourceRoot sroot = ((GlobalRootNode) ModelicaASTRegistry.getInstance()
				.doLookup(file.getProject())).getSourceRoot();
		StoredDefinition def = ModelicaASTRegistry.getInstance().getLatestDef(
				file);
		FullClassDecl fcd = (FullClassDecl) ModelicaASTRegistry.getInstance()
				.resolveSourceASTPath(def, history.getClassASTPath());

		StringBuilder sb = new StringBuilder();
		// remake all code, without edit button and with okay/cancel button
		sb.append(Generator.genHead());
		sb.append(Generator.genJavaScript(tinymcePath, true));
		sb.append(Generator.genHeader());
		sb.append(Generator.genTitle(fcd, this.getClass().getProtectionDomain()
				.getCodeSource().getLocation().getPath(), true));
		sb.append(Generator.genComment(fcd));
		sb.append(Generator.genInfo(fcd, false, sroot, true));
		sb.append(Generator.genImports(fcd));
		sb.append(Generator.genExtensions(fcd));
		sb.append(Generator.genClasses(fcd));
		sb.append(Generator.genComponents(fcd));
		sb.append(Generator.genEquations(fcd));
		sb.append(Generator.genRevisions(fcd, false, sroot, true));
		sb.append(Generator.genFooter(""));

		int startIndex = isInfo ? sb.indexOf(Generator.INFO_ID_OPEN_TAG) : sb
				.indexOf(Generator.REV_ID_OPEN_TAG);
		int endIndex = isInfo ? sb.indexOf("<!-- END OF INFO -->") : sb
				.indexOf("<!-- END OF REVISIONS -->");
		String textAreaID = isInfo ? "infoTextArea" : "revTextArea";
		String submitFunction = isInfo ? "\"postInfoEdit();return false;\""
				: "\"postRevEdit();return false;\"";
		String cancelButton = isInfo ? Generator.CANCEL_INFO_BTN
				: Generator.CANCEL_REV_BTN;
		String textArea = "<form onsubmit=" + submitFunction + ">\n"
				+ "<textarea name=\"content\" id=\"" + textAreaID
				+ "\" cols=\"98\" rows=\"30\" >\n" + divContent + "\n"
				+ "</textarea>\n" + "<input type=\"submit\" value=\"Save\" />"
				+ cancelButton + "</form>\n";
		sb.replace(startIndex, endIndex, textArea);
		try {
			String fileName = this.getClass().getProtectionDomain()
					.getCodeSource().getLocation().getPath()
					+ "tmp.html";
			File file = new File(fileName);
			file.createNewFile();
			FileWriter fstream = new FileWriter(fileName);
			BufferedWriter out = new BufferedWriter(fstream);
			out.write(sb.toString());
			out.close();
			GoToWYSIWYGEvent event = new GoToWYSIWYGEvent(file.toURI().toURL()
					.toString());
			myListener.astChanged(event);
		} catch (IOException e) {
			e.printStackTrace();
		}
	}
}