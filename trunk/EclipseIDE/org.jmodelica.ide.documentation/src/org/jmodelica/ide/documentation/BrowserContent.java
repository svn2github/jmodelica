package org.jmodelica.ide.documentation;

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.util.ArrayList;
import org.eclipse.core.runtime.SafeRunner;
import org.eclipse.jface.dialogs.IDialogConstants;
import org.eclipse.jface.dialogs.MessageDialog;
import org.eclipse.jface.wizard.WizardDialog;
import org.eclipse.swt.SWTException;
import org.eclipse.swt.browser.Browser;
import org.eclipse.swt.browser.LocationEvent;
import org.eclipse.swt.browser.LocationListener;
import org.eclipse.swt.browser.TitleEvent;
import org.eclipse.swt.browser.TitleListener;
import org.eclipse.swt.events.MouseEvent;
import org.eclipse.swt.events.MouseListener;
import org.eclipse.ui.PlatformUI;
import org.jmodelica.ide.documentation.commands.NavigationProvider;
import org.jmodelica.ide.documentation.wizard.GenDocWizard;
import org.jmodelica.modelica.compiler.ClassDecl;
import org.jmodelica.modelica.compiler.FullClassDecl;
import org.jmodelica.modelica.compiler.Program;
import org.jmodelica.modelica.compiler.ShortClassDecl;
import org.jmodelica.modelica.compiler.SourceRoot;
import org.jmodelica.modelica.compiler.StringLitExp;
import org.jmodelica.modelica.compiler.UnknownClassDecl;

public class BrowserContent implements LocationListener, MouseListener, TitleListener{

	private StringBuilder content;
	private Browser browser;
	private ArrayList<String> history;
	private int histIndex;
	private int histSize;
	private Program program;
	private NavigationProvider navProv;
	private SourceRoot sourceRoot;
	private static final String FOOTER = "<i>footer</i>";
	private static final String CANCEL_INFO_BTN = "<input class='buttonIndent' type='button' onclick='cancelInfo()' id='cancelInfoButton' value='Cancel'/>";
	private static final String CANCEL_REV_BTN = "<input class='buttonIndent' type='button' onclick='cancelRev()' id='cancelRevButton' value='Cancel'/>";
	private boolean editing = false;
	private String tinymcePath;
	private DocumentationEditor editor;

	/**
	 * Sets up the content of the browser, based of the FullClassDecl fcd, and renders it. If genDoc is true it also launches a wizard for documentation generation
	 * @param editor The editor in which to render the content
	 * @param fullClassDecl The FullClassDecl to be rendered
	 * @param browser The browser that handles the rendering
	 * @param sourceRoot The root node of the source AST
	 * @param navProv A navigation provider that that facilitates 'back' and 'forward' in the browsing history.
	 * @param genDoc Whether or not the documentation should we saved to file or just directly presented in the browser.
	 */
	public BrowserContent(DocumentationEditor editor, FullClassDecl fullClassDecl, Browser browser, SourceRoot sourceRoot, NavigationProvider navProv, boolean genDoc){
		this.editor = editor;
		this.sourceRoot = sourceRoot;
		this.navProv = navProv;
		this.program = sourceRoot.getProgram();
		history = new ArrayList<String>();
		histIndex = 0;
		histSize = 0;
		history.add(Generator.getFullPath(fullClassDecl));
		this.browser = browser;
		browser.setJavascriptEnabled(true);
		browser.addLocationListener(this);
		browser.addMouseListener(this);
		browser.addTitleListener(this);
		renderClassDecl(fullClassDecl);
		if(genDoc){
			generateDocumentation(fullClassDecl);
		}
	}

	/**
	 * Generates offline documentation for the FullClassDecl fcd by launching a wizard
	 * @param fcd The FullClassDecl
	 */
	public void generateDocumentation(FullClassDecl fcd) {
		WizardDialog dialog = new WizardDialog(PlatformUI.getWorkbench().getActiveWorkbenchWindow().getShell(), new GenDocWizard(fcd, sourceRoot, FOOTER));
		dialog.create();
		dialog.open();		
	}

	/**
	 * Renders a class declaration. This includes appending a head, breadcrumbar, header, title, body content 
	 * and footer. The body may, depending on what type of class it is, contain properties such as
	 * classes contained in a package, equations, components, extensions revision information etc.
	 * Called when the users ask for a new class declaration to be rendered by pressing a link or
	 * navigating in the browser history.
	 * @param fcd The class declaration to be rendered
	 */
	private void renderClassDecl(ClassDecl fcd){
		tinymcePath = this.getClass().getProtectionDomain().getCodeSource().getLocation() + this.getClass().getResource("/resources/tinymce/jscripts/tiny_mce/tiny_mce.js").getPath();
		content = new StringBuilder();
		content.append(Generator.genHead());
		content.append(Generator.genJavaScript(tinymcePath, false));
		content.append(Generator.genHeader());
		content.append(Generator.genBreadCrumBar(fcd, program));
		if (fcd instanceof UnknownClassDecl){
			content.append(Generator.genUnknownClassDecl((UnknownClassDecl)fcd, history.get(histIndex)));
		}else if(fcd instanceof FullClassDecl){
			renderFullClassDecl((FullClassDecl) fcd);
		}else if (fcd instanceof ShortClassDecl){
			content.append(Generator.genShortClassDecl((ShortClassDecl) fcd));
		}
		content.append(Generator.genFooter(FOOTER));
		browser.setText(content.toString());
	}

	/**
	 * Appends HTML code that's specific to the ClassDecl subclass FullClassDecl. 
	 * This includes: title, info, imports, extensions, classes, components, equations, revision
	 * This does NOT include: head (initialization, css and javascript), header (document header), breadcrum bar
	 * which are found in all ClassDecl.
	 * @param fcd
	 */
	private void renderFullClassDecl(FullClassDecl fcd){
		content.append(Generator.genTitle(fcd, this.getClass().getProtectionDomain().getCodeSource().getLocation().getPath(), false));
		content.append(Generator.genComment(fcd));
		content.append(Generator.genInfo(fcd, false, sourceRoot, false));
		content.append(Generator.genImports(fcd));
		content.append(Generator.genExtensions(fcd));
		content.append(Generator.genClasses(fcd));
		content.append(Generator.genComponents(fcd));
		content.append(Generator.genEquations(fcd));
		content.append(Generator.genRevisions(fcd, false, sourceRoot, false));
	}

	/**
	 * Renders a hyperlink clicked by the user. This can refer to a external site or a class declaration.
	 * If it's not a http(s) link, it's assumed to be a link to a ClassDecl. Does not accept links to files
	 * on the file system.
	 * @param link The unique identifier for the link. A URL for a HTTP request or a Modelica path (with or without the 'modelica://' prefix
	 */
	private void renderLink(String link){
		navProv.setBackEnabled(histIndex > 0 ? true : false);
		navProv.setForwardEnabled(histSize > histIndex ? true : false);
		if (link.startsWith("http")){
			if (!browser.getUrl().equals(link)){
				browser.setUrl(link);
			}
		}else{
			String s = link.startsWith("//Modelica") ? link.substring("//".length(), link.length()-1) : link;
			renderClassDecl(program.simpleLookupClassDotted(s));
		}
	}

	/**
	 * Attempts to update the navigation history and render the 'next' page
	 * @return Whether the action was successfully carried out
	 */
	public boolean forward(){
		if (histSize <= histIndex) return false;
		if (editing) return true;
		histIndex++;
		String location = history.get(histIndex);
		renderLink(location);
		return histSize > histIndex;
	}

	/**
	 * Attempts to update the navigation history and render the 'previous' page
	 * @return Whether the action was successfully carried out
	 */
	public boolean back(){
		if (histIndex <= 0) return false;
		if (editing) return true;
		histIndex--;
		String location = history.get(histIndex);
		renderLink(location);
		return histIndex > 0;
	}

	/**
	 * Adds a new String value to information annotation node of the current class declaration and
	 * saves it to file. Overwrites any existing value.
	 * @param newVal The new information string associated with the current class declaration.
	 */
	private void saveNewInformationAnnotation(String newVal){
		ClassDecl fcd = program.simpleLookupClassDotted(history.get(histIndex));
		StringLitExp exp = new StringLitExp(Generator.htmlToModelica(newVal));
		synchronized (fcd.state()){
			fcd.annotation().forPath("Documentation/info").setValue(exp);
			SaveSafeRunnable ssr = new SaveSafeRunnable(fcd);
			SafeRunner.run(ssr);
		}

	}

	/**
	 * Adds a new String value to revisions annotation node of the current class declaration and
	 * saves it to file. Overwrites any existing value.
	 * @param newVal The new revisions string associated with the current class declaration.
	 */
	private void saveNewRevisionsAnnotation(String newVal){
		ClassDecl fcd = program.simpleLookupClassDotted(history.get(histIndex));
		StringLitExp exp = new StringLitExp(Generator.htmlToModelica(newVal));
		synchronized (fcd.state()){
			fcd.annotation().forPath("Documentation/revisions").setValue(exp);
			SaveSafeRunnable ssr = new SaveSafeRunnable(fcd);
			SafeRunner.run(ssr);
		}
	}

	/**
	 * Invoked before the browser has 'changed'. This includes change of dynamic content
	 * through JavaScript, invoking browser.setText() or browser.setURL(), and the browsers own handling of
	 * hyperlink redirects. This invokation takes place both at the first request to change
	 * as well as when the change is completed, i.e when the page is fully loaded.
	 * Determines whether the change should be allowed to take place
	 */
	@Override
	public void changing(LocationEvent event) {
		event.doit = true;
		if (editing){
			if (event.location.endsWith("tmp.html") || event.location.startsWith("javascript")){
				event.doit = true;
			}else{
				boolean confirmed = yesNoBox("Would you like to leave edit mode? All unsaved changed will be lost!", "Confirm navigation");//(Boolean) browser.evaluate(Scripts.CONFIRM_POPUP);
				event.doit = confirmed;
				editing = !confirmed;
				if (confirmed){
					browser.evaluate(Scripts.UNDO_ALL);
					editor.setDirty(false);
					browser.setText(content.toString());
				}
			}
		}
	}

	/**
	 * Updates the browser history and calls renderLink() for the new location 
	 * This method is invoked after the browser has 'changed'. This includes change of dynamic content
	 * through JavaScript, invoking browser.setText() or browser.setURL(), and the browsers own handling of
	 * hyperlink redirects.

	 */
	@Override
	public void changed(LocationEvent event) {
		if (event.location.endsWith("tmp.html")) return;
		String location = Generator.processLinkString(event.location);
		//return if we're going to a blank page or current page
		if (location.equals("blank") || history.get(histIndex).equals(location)) return;
		histIndex++;
		if (histIndex >= history.size()){
			history.add(location);
		}else{
			history.set(histIndex, location);
		}
		histSize = histIndex;
		renderLink(location);
	}

	@Override
	public void mouseDoubleClick(MouseEvent e) {
	}

	@Override
	public void mouseDown(MouseEvent e) {
	}

	@Override
	public void mouseUp(MouseEvent e) {
	}

	/**
	 * Checks for input from the user and saves it to documentation/info annotation in the 
	 * corresponding .mo file.
	 */
	@Override
	public void changed(TitleEvent event) {
		String title = (String) browser.evaluate("return document.title");
		if (title == null) return;
		if (title.equals("preInfoEdit")){
			String docContent = (String)browser.evaluate(Scripts.FETCH_INFO_DIV_CONTENT);
			if (docContent.trim().equals(Generator.NO_INFO_AVAILABLE)){
				docContent = "";
			}
			editor.setDirty(true);
			gotoWYSIWYG(docContent, true);
		}else if(title.equals("postInfoEdit")){
			String textAreaContent = (String)browser.evaluate(Scripts.FETCH_INFO_TEXTAREA_CONTENT);
			saveNewInformationAnnotation(textAreaContent);
			if (textAreaContent.trim().equals("")){
				textAreaContent = Generator.NO_INFO_AVAILABLE;	
			}
			//reset title, reset saving, use browser.setText()
			editing = false;
			content.replace(content.indexOf(Generator.INFO_ID_OPEN_TAG) + Generator.INFO_ID_OPEN_TAG.length(), content.indexOf("<!-- END OF INFO -->"), textAreaContent + "\n\t\t\t" + Generator.INFO_ID_CLOSE_TAG);
			editor.setDirty(false);
			browser.setText(content.toString());
		}else if(title.equals("preRevEdit")){
			String revContent = (String)browser.evaluate(Scripts.FETCH_REV_DIV_CONTENT);
			if (revContent.trim().equals(Generator.NO_REV_AVAILABLE)){
				revContent = "";
			}
			editor.setDirty(true);
			gotoWYSIWYG(revContent, false);
		}else if (title.equals("postRevEdit")){
			String textAreaContent = (String)browser.evaluate(Scripts.FETCH_REV_TEXTAREA_CONTENT);
			saveNewRevisionsAnnotation(textAreaContent);
			if (textAreaContent.trim().equals("")){
				textAreaContent = Generator.NO_REV_AVAILABLE;	
			}
			editing = false;
			content.replace(content.indexOf(Generator.REV_ID_OPEN_TAG) + Generator.REV_ID_OPEN_TAG.length(), content.indexOf("<!-- END OF REVISIONS -->"), textAreaContent + "\n\t\t\t" + Generator.REV_ID_CLOSE_TAG);
			editor.setDirty(false);
			if (textAreaContent.trim().equals("")){
				browser.evaluate(Scripts.setRevDivContent(Generator.NO_REV_AVAILABLE));
			}
			browser.setText(content.toString());
		}else if (title.equals("cancelInfo") || title.equals("cancelRev")){
			editing = false;
			editor.setDirty(false);
			browser.setText(content.toString());
		}
	}

	/**
	 * Saves and renders a HTML file where the div that is about to be edited has been replaced by the TinyMCE WYSIWYG
	 * @param divContent The old content of the div that is about to be edited
	 * @param isInfo True if the Information annotation is about to be edited, false if the Revisions annotation is about to be edited
	 */
	private void gotoWYSIWYG(String divContent, boolean isInfo){
		//StringBuilder sb = new StringBuilder(content.toString());
		StringBuilder sb = new StringBuilder();
		FullClassDecl fcd = (FullClassDecl)program.simpleLookupClassDotted(history.get(histIndex));
		//remake all code, without edit button and with okay/cancel button
		sb.append(Generator.genHead());
		sb.append(Generator.genJavaScript(tinymcePath, true));
		sb.append(Generator.genHeader());
		sb.append(Generator.genTitle(fcd, this.getClass().getProtectionDomain().getCodeSource().getLocation().getPath(), true));
		sb.append(Generator.genComment(fcd));
		sb.append(Generator.genInfo(fcd, false, sourceRoot, true));
		sb.append(Generator.genImports(fcd));
		sb.append(Generator.genExtensions(fcd));
		sb.append(Generator.genClasses(fcd));
		sb.append(Generator.genComponents(fcd));
		sb.append(Generator.genEquations(fcd));
		sb.append(Generator.genRevisions(fcd, false, sourceRoot, true));
		sb.append(Generator.genFooter(""));

		int startIndex = isInfo ? sb.indexOf(Generator.INFO_ID_OPEN_TAG) : sb.indexOf(Generator.REV_ID_OPEN_TAG);
		int endIndex = isInfo ? sb.indexOf("<!-- END OF INFO -->") : sb.indexOf("<!-- END OF REVISIONS -->");
		String textAreaID = isInfo ? "infoTextArea" : "revTextArea";
		String submitFunction = isInfo ? "\"postInfoEdit();return false;\"" : "\"postRevEdit();return false;\"";
		String cancelButton = isInfo ? CANCEL_INFO_BTN : CANCEL_REV_BTN;
		String textArea =  
				"<form onsubmit=" + submitFunction + ">\n"+
						"<textarea name=\"content\" id=\""+ textAreaID + "\" cols=\"98\" rows=\"30\" >\n"+ 
						divContent + "\n"+
						"</textarea>\n"+
						"<input type=\"submit\" value=\"Save\" />" + cancelButton +
						"</form>\n";
		sb.replace(startIndex, endIndex, textArea);
		try
		{
			String fileName = this.getClass().getProtectionDomain().getCodeSource().getLocation().getPath() + "tmp.html";
			File file = new File(fileName);
			file.createNewFile();
			FileWriter fstream = new FileWriter(fileName);
			BufferedWriter out = new BufferedWriter(fstream);
			out.write(sb.toString());
			out.close();
			editing = true;
			browser.setUrl(file.toURI().toURL().toString());
		}
		catch (IOException e)
		{
			System.out.println(e.getMessage());
		}
	}

	/**
	 * Returns a string representation of the browser content
	 */
	@Override
	public String toString(){
		return content.toString();
	}

	public String getCurrentClass() {
		return history.get(histIndex);
	}

	/**
	 * Saves the content of the current WYSIWYG. Only called when the user attempts to close an editor window while a 
	 * WYSIWYG for information of revision is currently open.
	 * @return true if anything was saved.
	 */
	public boolean save() {
		if (!editing) return false;
		try{
			String textAreaContent = (String)browser.evaluate(Scripts.FETCH_INFO_TEXTAREA_CONTENT);
			editing = false;
			saveNewInformationAnnotation(textAreaContent);
			editor.setDirty(false);
		}catch(SWTException e){
			String textAreaContent2 = (String)browser.evaluate(Scripts.FETCH_REV_TEXTAREA_CONTENT);
			editing = false;
			saveNewRevisionsAnnotation(textAreaContent2);
			editor.setDirty(false);
		}
		return true;
	}

	public boolean isDirty() {
		if (!editing) return false; //evaluate will throw an exception of editing == false
		return (Boolean) browser.evaluate("return tinyMCE.activeEditor.isDirty()");
	}

	public boolean yesNoBox(String message, String title){
		MessageDialog dialog = new MessageDialog(editor.getEditorSite().getShell(),
				title,
				null,
				message,
				MessageDialog.QUESTION, new String[]{
			IDialogConstants.YES_LABEL,
			IDialogConstants.NO_LABEL},
			0);
		int dialogResults = dialog.open();
		if (dialogResults == 0){ //yes
			return true;
		}
		return false;
	}

	public void undoChanges() {
		browser.evaluate(Scripts.UNDO_ALL);

	}
}