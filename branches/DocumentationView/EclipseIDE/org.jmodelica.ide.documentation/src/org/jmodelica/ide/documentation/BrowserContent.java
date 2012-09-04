package org.jmodelica.ide.documentation;

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;

import javax.swing.JDialog;
import javax.swing.JFileChooser;
import javax.swing.JFrame;
import javax.swing.JOptionPane;
import javax.swing.SwingUtilities;

import org.eclipse.core.runtime.SafeRunner;
import org.eclipse.swt.browser.Browser;
import org.eclipse.swt.browser.LocationEvent;
import org.eclipse.swt.browser.LocationListener;
import org.eclipse.swt.browser.TitleEvent;
import org.eclipse.swt.browser.TitleListener;
import org.eclipse.swt.events.MouseEvent;
import org.eclipse.swt.events.MouseListener;
import org.jmodelica.ide.documentation.commands.NavigationProvider;
import org.jmodelica.modelica.compiler.ClassDecl;
import org.jmodelica.modelica.compiler.FullClassDecl;
import org.jmodelica.modelica.compiler.InstClassDecl;
import org.jmodelica.modelica.compiler.Program;
import org.jmodelica.modelica.compiler.ShortClassDecl;
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
	private static final String N3 = "\n\t\t\t";
	private static final String N4 = N3 + "\t";
	private static final String FOOTER = "<i>footer</i>";
	private static final String INFO_BTN_DATA_POST = "onclick='postInfoEdit()' id='editInfoButton' value='Save'";
	private static final String REV_BTN_DATA_POST = "onclick='postRevEdit()' id='editRevisionButton' value='Save'";
	private static final String INFO_BTN_DISABLE = "onclick='preInfoEdit()' id='editInfoButton' disabled='disabled' value='Edit..'";
	private static final String REV_BTN_DISABLE = "onclick='preRevEdit()' id='editRevisionButton' disabled='disabled' value='Edit..'";
	private static final String CANCEL_INFO_BTN = "<input class='buttonIndent' type='button' onclick='cancelInfo()' id='cancelInfoButton' value='Cancel'/>";
	private static final String CANCEL_REV_BTN = "<input class='buttonIndent' type='button' onclick='cancelRev()' id='cancelRevButton' value='Cancel'/>";
	private boolean saving = false;

	public BrowserContent(FullClassDecl fullClassDecl, Browser browser, InstClassDecl icd, Program program, NavigationProvider navProv, boolean genDoc){
		this.navProv = navProv;
		this.program = program;
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

//	private class Dialog implements Runnable{
//		private FullClassDecl fcd;
//		private Program program;
//		private String footer;
//		public Dialog(FullClassDecl fcd, Program program, String footer){
//			this.fcd = fcd;
//			this.program = program;
//			this.footer = footer;
//		}
//		@Override
//		public void run() {
//			new DocGenDialog(null, fcd, program, FOOTER);
//			
//		}
//		
//	}
	public void generateDocumentation(FullClassDecl fcd) {
		//DocGenDialog dlg = new DocGenDialog(null);
		new DocGenDialog(null, fcd, program, FOOTER);
		
		//new Dialog(fcd, program, FOOTER).run();
		
		
		
		//RETURN!!!!
//		String rootPath = dlg.getRootPath();
//		HashMap<String, Boolean> options = dlg.getOptions();
//		if (!dlg.isDone()) return;
//		String path = rootPath + fcd.getName().getID();
//		String libName = fcd.getName().getID();
//		
//		if ((new File(path)).exists()) {
//			if (JOptionPane.showConfirmDialog(null, "This folder already exist. Would you like to override existing files?") != JOptionPane.YES_OPTION) return;
//		}else{
//			boolean success = (new File(path)).mkdirs();
//			if (!success) {
//				JOptionPane.showMessageDialog(null, "Unable to create a new directory", "Error", JOptionPane.ERROR_MESSAGE, null);
//				return;
//			}
//		}
//		String code = Generator.genDocumentation(fcd, program, path + "\\", FOOTER, "Unknown Class Decl", rootPath, libName, options);
//		try{
//			FileWriter fstream = new FileWriter(path + "\\index.html");
//			BufferedWriter out = new BufferedWriter(fstream);
//			out.write(code);
//			out.close();
//		}catch (Exception e){
//			JOptionPane.showMessageDialog(null, "Unable to save to file", "Error", JOptionPane.ERROR_MESSAGE, null);
//		}
//		ArrayList<ClassDecl> children = new ArrayList<ClassDecl>();
//		collectChildren(fcd, children);
//		for (ClassDecl child : children){
//			String newPath = rootPath + "\\" + Generator.getFullPath(child).replace(".", "\\");
//			(new File(newPath)).mkdirs();
//			try{
//				FileWriter fstream = new FileWriter(newPath + "\\index.html");
//				BufferedWriter out = new BufferedWriter(fstream);
//				out.write(Generator.genDocumentation(child, program, newPath + "\\", FOOTER, "Unknown class decl", rootPath, libName, options));
//				out.close();
//			}catch (Exception e){
//				JOptionPane.showMessageDialog(null, "Unable to save to file", "Error", JOptionPane.ERROR_MESSAGE, null);
//			}
//		}
//		StringBuilder generatedDocs = new StringBuilder("Documentation was successfully generated for the following classes:");
//		generatedDocs.append("\n" + libName);
//		for (ClassDecl cd : children){
//			generatedDocs.append("\n" + cd.name());
//		}
//		JOptionPane.showMessageDialog(null, generatedDocs.toString(), "Generation Complete", JOptionPane.INFORMATION_MESSAGE, null);
	}

//	private void collectChildren(FullClassDecl fcd, ArrayList<ClassDecl> children) {
//		if (fcd.classes() == null || fcd.classes().size() == 0) return;
//		for (ClassDecl child : fcd.classes()){
//			if (!children.contains(child)){
//				children.add(child);
//				if (child instanceof FullClassDecl){
//					collectChildren((FullClassDecl) child, children);
//				}
//			}
//		}
//	}

	/**
	 * Renders a class declaration. This includes a head, breadcrumbar, header, title, body content 
	 * and footer. The body may, depending on what type of class it is, contain properties such as
	 * classes contained in a package, equations, components, extensions revision information etc.
	 * @param fcd The class declaration to be rendered
	 */
	private void renderClassDecl(ClassDecl fcd){
		String tinymcePath = this.getClass().getProtectionDomain().getCodeSource().getLocation() + this.getClass().getResource("/resources/tinymce/jscripts/tiny_mce/tiny_mce.js").getPath();
		content = new StringBuilder();
		content.append(Generator.genHead());
		content.append(Generator.genJavaScript(tinymcePath));
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
	 * Renders the components specific to a full class declaration. 
	 * This includes: title, info, imports, extensions, classes, components, equations, revision
	 * This does NOT include: head (initialization, css and javascript), header (document header), breadcrum bar
	 * @param fcd
	 */
	private void renderFullClassDecl(FullClassDecl fcd){
		content.append(Generator.genTitle(fcd, this.getClass().getProtectionDomain().getCodeSource().getLocation().getPath(), false));
		content.append(Generator.genComment(fcd));
		content.append(Generator.genInfo(fcd, false));
		content.append(Generator.genImports(fcd));
		content.append(Generator.genExtensions(fcd));
		content.append(Generator.genClasses(fcd));
		content.append(Generator.genComponents(fcd));
		content.append(Generator.genEquations(fcd));
		content.append(Generator.genRevisions(fcd, false));
	}

	/**
	 * Renders a hyperlink clicked by the user. This can refer to a external site or a class declaration.
	 * @param link The unique identifier for the link. A URL for a HTTP request or a Modelica path
	 * for a class declaration
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
	 * Attempts to update the navigation history and render the next page
	 * @return Whether the action was successfully carried out
	 */
	public boolean forward(){
		if (histSize <= histIndex) return false;
		histIndex++;
		String location = history.get(histIndex);
		renderLink(location);
		return histSize > histIndex;
	}

	/**
	 * Attempts to update the navigation history and render the previous page
	 * @return Whether the action was successfully carried out
	 */
	public boolean back(){
		if (histIndex <= 0) return false;
		histIndex--;
		String location = history.get(histIndex);
		renderLink(location);
		return histIndex > 0;
	}

	/**
	 * Adds a new String value to documentation annotation node of the current class declaration and
	 * saves it to file.
	 * @param newVal The new documentation string associated with the current class declaration.
	 */
	private void saveNewDocumentationAnnotation(String newVal){
		ClassDecl fcd = program.simpleLookupClassDotted(history.get(histIndex));
		StringLitExp exp = new StringLitExp(Generator.htmlToModelica(newVal));
		fcd.annotation().forPath("Documentation/info").setValue(exp);
		SaveSafeRunnable ssr = new SaveSafeRunnable(fcd);
		SafeRunner.run(ssr);
	}

	private void saveNewRevisionsAnnotation(String newVal){
		ClassDecl fcd = program.simpleLookupClassDotted(history.get(histIndex));
		StringLitExp exp = new StringLitExp(newVal);
		fcd.annotation().forPath("Documentation/revisions").setValue(exp);
		SaveSafeRunnable ssr = new SaveSafeRunnable(fcd);
		SafeRunner.run(ssr);
	}

	/**
	 * Invoked before the browser has 'changed'. This includes change of dynamic content
	 * through JavaScript, invoking Browser.setText(), and the browsers own handling of
	 * hyperlink redirects. This invokation takes place both at the first request to change
	 * as well as when the change is completed, i.e when the page is fully loaded.
	 */
	@Override
	public void changing(LocationEvent event) {
		event.doit = true;
		if (saving){
			if (event.location.endsWith("tmp.html") || event.location.startsWith("javascript")){
				event.doit = true;
			}else{
				//browser.evaluate(Scripts.ALERT_UNSAVED_CHANGES);
				Boolean shouldMove = (Boolean) browser.evaluate(Scripts.CONFIRM_POPUP);
				if (!shouldMove) event.doit = false;
				saving = !shouldMove;
				if (shouldMove)browser.setText(content.toString());
				event.doit = false;
			}
		}
	}

	/**
	 * Invoked after the browser has 'changed'. This includes change of dynamic content
	 * through JavaScript, invoking Browser.setText(), and the browsers own handling of
	 * hyperlink redirects.
	 * Updates the browser history and calls renderLink() for the new location 
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
		if (title.equals("preInfoEdit")){
			String docContent = (String)browser.evaluate(Scripts.FETCH_INFO_DIV_CONTENT);
			gotoWYSIWYG(docContent, true);
		}else if(title.equals("postInfoEdit")){
			String textAreaContent = (String)browser.evaluate(Scripts.FETCH_INFO_TEXTAREA_CONTENT);
			//reset title, reset saving, use browser.setText()
			saving = false;
			content.replace(content.indexOf(Generator.INFO_ID_OPEN_TAG) + Generator.INFO_ID_OPEN_TAG.length(), content.indexOf("<!-- END OF INFO -->"), textAreaContent + N3 + Generator.INFO_ID_CLOSE_TAG);
			saveNewDocumentationAnnotation(textAreaContent);
			browser.setText(content.toString());
		}else if(title.equals("preRevEdit")){
			String revContent = (String)browser.evaluate(Scripts.FETCH_REV_DIV_CONTENT);
			gotoWYSIWYG(revContent, false);
		}else if (title.equals("postRevEdit")){
			String textAreaContent = (String)browser.evaluate(Scripts.FETCH_REV_TEXTAREA_CONTENT);
			saving = false;
			content.replace(content.indexOf(Generator.REV_ID_OPEN_TAG) + Generator.REV_ID_OPEN_TAG.length(), content.indexOf("<!-- END OF REVISIONS -->"), textAreaContent + N3 + Generator.REV_ID_CLOSE_TAG);
			saveNewRevisionsAnnotation(textAreaContent);
			browser.setText(content.toString());
		}else if (title.equals("cancelInfo") || title.equals("cancelRev")){
			saving = false;
			browser.setText(content.toString());
		}
	}

	/**
	 * Saves and renders a HTML file where the div that is about to be edited has been replaced by the TinyMCE WYSIWYG
	 * @param divContent The old content of the div that is about to be edited
	 * @param isInfo True if the Information annotation is about to be edited, false if the Revisions annotation is about to be edited
	 */
	private void gotoWYSIWYG(String divContent, boolean isInfo){
		StringBuilder sb = new StringBuilder(content.toString());
		//Insert the JavaScript initialization of TinyMCE
		int insert = sb.indexOf("<script type=\"text/javascript\">") + "<script type=\"text/javascript\">".length();
		sb.insert(insert, N4 + Scripts.SCRIPT_INIT_TINY_MCE);
		//Replace the div with a textArea, with the same content [startIndex,endIndex)
		int startIndex = isInfo ? sb.indexOf(Generator.INFO_ID_OPEN_TAG) : sb.indexOf(Generator.REV_ID_OPEN_TAG);
		int endIndex = isInfo ? sb.indexOf("<!-- END OF INFO -->") : sb.indexOf("<!-- END OF REVISIONS -->");
		String textAreaID = isInfo ? "infoTextArea" : "revTextArea";
		String textArea =  
				"<form>\n"+  
						"<textarea name=\"content\" id=\""+ textAreaID + "\" cols=\"98\" rows=\"30\" >\n"+ 
						divContent + "\n"+
						"</textarea>\n"+
						"</form>\n";
		sb.replace(startIndex, endIndex, textArea);
		try
		{
			String fileName = this.getClass().getProtectionDomain().getCodeSource().getLocation().getPath() + "tmp.html";
			File file = new File(fileName);
			file.createNewFile();
			FileWriter fstream = new FileWriter(fileName);
			BufferedWriter out = new BufferedWriter(fstream);
			if (isInfo){
				//change from 'Edit..' to 'Save'
				sb.replace(sb.indexOf(Generator.INFO_BTN_DATA_PRE), sb.indexOf(Generator.INFO_BTN_DATA_PRE)+ Generator.INFO_BTN_DATA_PRE.length(), INFO_BTN_DATA_POST);
				//Disable 'Edit..' for 'Revisions'
				sb.replace(sb.indexOf(Generator.REV_BTN_DATA_PRE), sb.indexOf(Generator.REV_BTN_DATA_PRE) + Generator.REV_BTN_DATA_PRE.length(), REV_BTN_DISABLE);
				//add cancel button
				sb.insert(sb.indexOf(INFO_BTN_DATA_POST) + INFO_BTN_DATA_POST.length() + "/>".length(), CANCEL_INFO_BTN);
			}else{
				//change from 'Edit..' to 'Save'
				sb.replace(sb.indexOf(Generator.REV_BTN_DATA_PRE), sb.indexOf(Generator.REV_BTN_DATA_PRE)+ Generator.REV_BTN_DATA_PRE.length(), REV_BTN_DATA_POST);
				//Disable 'Edit..' for 'Information'
				sb.replace(sb.indexOf(Generator.INFO_BTN_DATA_PRE), sb.indexOf(Generator.INFO_BTN_DATA_PRE) + Generator.INFO_BTN_DATA_PRE.length(), INFO_BTN_DISABLE);
				//add cancel button
				sb.insert(sb.indexOf(REV_BTN_DATA_POST) + REV_BTN_DATA_POST.length() + "/>".length(), CANCEL_REV_BTN);
			}
			out.write(sb.toString());
			out.close();
			saving = true;
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
}