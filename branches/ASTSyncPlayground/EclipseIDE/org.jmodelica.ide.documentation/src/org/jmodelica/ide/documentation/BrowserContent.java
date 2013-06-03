package org.jmodelica.ide.documentation;

import java.util.ArrayList;
import java.util.Stack;

import org.eclipse.core.resources.IFile;
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
import org.jastadd.ed.core.model.IASTChangeEvent;
import org.jastadd.ed.core.model.IASTChangeListener;
import org.jastadd.ed.core.model.IASTPathPart;
import org.jmodelica.ide.documentation.commands.NavigationProvider;
import org.jmodelica.ide.documentation.sync.ASTCommunicationHandler;
import org.jmodelica.ide.documentation.sync.GoToWYSIWYGEvent;
import org.jmodelica.ide.documentation.sync.GoToWYSIWYGTask;
import org.jmodelica.ide.documentation.sync.RenderClassDeclEvent;
import org.jmodelica.ide.documentation.sync.RenderClassDeclTask;
import org.jmodelica.ide.documentation.sync.SaveFCDAnnotationTask;
import org.jmodelica.ide.documentation.wizard.GenDocWizard;
import org.jmodelica.ide.sync.ASTRegTaskBucket;

public class BrowserContent implements LocationListener, MouseListener,
		TitleListener, IASTChangeListener {
	private StringBuilder content = new StringBuilder();
	private Browser browser;
	private ArrayList<HistoryObject> history = new ArrayList<HistoryObject>();
	private int histIndex;
	private int histSize;
	private NavigationProvider navProv;
	private boolean editing = false;
	private String tinymcePath;
	private DocumentationEditor editor;

	private ASTCommunicationHandler myCache = new ASTCommunicationHandler(this);
	private IFile file;

	/**
	 * Sets up the content of the browser, based of the FullClassDecl fcd, and
	 * renders it. If genDoc is true it also launches a wizard for documentation
	 * generation
	 * 
	 * @param editor
	 *            The editor in which to render the content
	 * @param fullClassDecl
	 *            The FullClassDecl to be rendered
	 * @param browser
	 *            The browser that handles the rendering
	 * @param sourceRoot
	 *            The root node of the source AST
	 * @param navProv
	 *            A navigation provider that that facilitates 'back' and
	 *            'forward' in the browsing history.
	 * @param genDoc
	 *            Whether or not the documentation should we saved to file or
	 *            just directly presented in the browser.
	 */
	public BrowserContent(DocumentationEditor editor,
			Stack<IASTPathPart> classASTPath, IFile file, Browser browser,
			NavigationProvider navProv, boolean genDoc) {
		tinymcePath = this.getClass().getProtectionDomain().getCodeSource()
				.getLocation()
				+ this.getClass()
						.getResource(
								"/resources/tinymce/jscripts/tiny_mce/tiny_mce.js")
						.getPath();
		this.editor = editor;
		this.navProv = navProv;
		this.file = file;
		histIndex = 0;
		histSize = 0;
		this.browser = browser;
		browser.setJavascriptEnabled(true);
		browser.addLocationListener(this);
		browser.addMouseListener(this);
		browser.addTitleListener(this);
		RenderClassDeclTask task = new RenderClassDeclTask(true, file, myCache,
				tinymcePath, new HistoryObject(HistoryObject.TYPE_CLASS,
						classASTPath), this.getClass().getProtectionDomain()
						.getCodeSource().getLocation().getPath());
		ASTRegTaskBucket.getInstance().addTask(task);
		if (genDoc) {
			generateDocumentation(file, classASTPath);
		}
	}

	/**
	 * Generates offline documentation for the FullClassDecl fcd by launching a
	 * wizard
	 * 
	 * @param fcd
	 *            The FullClassDecl
	 */
	public void generateDocumentation(IFile file,
			Stack<IASTPathPart> classASTPath) {
		WizardDialog dialog = new WizardDialog(PlatformUI.getWorkbench()
				.getActiveWorkbenchWindow().getShell(), new GenDocWizard(file,
				classASTPath));
		dialog.create();
		dialog.open();
	}

	/**
	 * Renders a hyperlink clicked by the user. This can refer to a external
	 * site or a class declaration. If it's not a http(s) link, it's assumed to
	 * be a link to a ClassDecl. Does not accept links to files on the file
	 * system.
	 * 
	 * @param link
	 *            The unique identifier for the link. A URL for a HTTP request
	 *            or a Modelica path (with or without the 'modelica://' prefix
	 */
	private void renderLink(HistoryObject history) {
		navProv.setBackEnabled(histIndex > 0 ? true : false);
		navProv.setForwardEnabled(histSize > histIndex ? true : false);
		if (history.getType() == HistoryObject.TYPE_URL) {
			String link = history.getExternalURL();
			if (link.startsWith("http")) {
				if (!browser.getUrl().equals(link)) {
					browser.setUrl(link);
				}
			}
		} else {
			RenderClassDeclTask task = new RenderClassDeclTask(false, file,
					myCache, tinymcePath, history, this.getClass()
							.getProtectionDomain().getCodeSource()
							.getLocation().getPath());
			ASTRegTaskBucket.getInstance().addTask(task);
		}
	}

	/**
	 * Attempts to update the navigation history and render the 'next' page
	 * 
	 * @return Whether the action was successfully carried out
	 */
	public boolean forward() {
		if (histSize <= histIndex)
			return false;
		if (editing)
			return true;
		histIndex++;
		HistoryObject location = history.get(histIndex);
		renderLink(location);
		return histSize > histIndex;
	}

	/**
	 * Attempts to update the navigation history and render the 'previous' page
	 * 
	 * @return Whether the action was successfully carried out
	 */
	public boolean back() {
		if (histIndex <= 0)
			return false;
		if (editing)
			return true;
		histIndex--;
		HistoryObject location = history.get(histIndex);
		renderLink(location);
		return histIndex > 0;
	}

	/**
	 * Adds a new String value to information annotation node of the current
	 * class declaration and saves it to file. Overwrites any existing value.
	 * 
	 * @param newVal
	 *            The new information string associated with the current class
	 *            declaration.
	 */
	private void saveNewInformationAnnotation(String newVal) {
		SaveFCDAnnotationTask task = new SaveFCDAnnotationTask(
				SaveFCDAnnotationTask.TYPE_INFORMATION, newVal,
				history.get(histIndex), file);
		ASTRegTaskBucket.getInstance().addTask(task);
	}

	/**
	 * Adds a new String value to revisions annotation node of the current class
	 * declaration and saves it to file. Overwrites any existing value.
	 * 
	 * @param newVal
	 *            The new revisions string associated with the current class
	 *            declaration.
	 */
	private void saveNewRevisionsAnnotation(String newVal) {
		SaveFCDAnnotationTask task = new SaveFCDAnnotationTask(
				SaveFCDAnnotationTask.TYPE_REVISION, newVal,
				history.get(histIndex), file);
		ASTRegTaskBucket.getInstance().addTask(task);
	}

	/**
	 * Invoked before the browser has 'changed'. This includes change of dynamic
	 * content through JavaScript, invoking browser.setText() or
	 * browser.setURL(), and the browsers own handling of hyperlink redirects.
	 * This invokation takes place both at the first request to change as well
	 * as when the change is completed, i.e when the page is fully loaded.
	 * Determines whether the change should be allowed to take place
	 */
	@Override
	public void changing(LocationEvent event) {
		event.doit = true;
		if (editing) {
			if (event.location.endsWith("tmp.html")
					|| event.location.startsWith("javascript")) {
				event.doit = true;
			} else {
				if (event.location.equals("about:blank")) {
					event.doit = false;
					return;
				}
				boolean confirmed = yesNoBox(
						"Would you like to leave edit mode? All unsaved changed will be lost!",
						"Confirm navigation");// (Boolean)
												// browser.evaluate(Scripts.CONFIRM_POPUP);
				event.doit = confirmed;
				editing = !confirmed;
				if (confirmed) {
					browser.evaluate(Scripts.UNDO_ALL);
					editor.setDirty(false);
					browser.setText(content.toString());
				}
			}
		}
	}

	/**
	 * Updates the browser history and calls renderLink() for the new location
	 * This method is invoked after the browser has 'changed'. This includes
	 * change of dynamic content through JavaScript, invoking browser.setText()
	 * or browser.setURL(), and the browsers own handling of hyperlink
	 * redirects.
	 */
	@Override
	public void changed(LocationEvent event) {
		if (event.location.endsWith("tmp.html"))
			return;
		String location = Generator.processLinkString(event.location);
		HistoryObject obj = new HistoryObject(HistoryObject.TYPE_URL, location);
		// return if we're going to a blank page or current page
		if (location.equals("blank") || history.get(histIndex).equals(location)
				|| location.startsWith("javascript"))
			return;
		histIndex++;
		if (histIndex >= history.size()) {
			history.add(obj);
		} else {
			history.set(histIndex, obj);
		}
		histSize = histIndex;
		renderLink(obj);
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
	 * Checks for input from the user and saves it to documentation/info
	 * annotation in the corresponding .mo file.
	 */
	@Override
	public void changed(TitleEvent event) {
		String title = (String) browser.evaluate("return document.title");
		if (title == null)
			return;
		if (title.equals("preInfoEdit")) {
			String docContent = (String) browser
					.evaluate(Scripts.FETCH_INFO_DIV_CONTENT);
			if (docContent.trim().equals(Generator.NO_INFO_AVAILABLE)) {
				docContent = "";
			}
			editor.setDirty(true);
			gotoWYSIWYG(docContent, true);
		} else if (title.equals("postInfoEdit")) {
			String textAreaContent = (String) browser
					.evaluate(Scripts.FETCH_INFO_TEXTAREA_CONTENT);
			saveNewInformationAnnotation(textAreaContent);
			if (textAreaContent.trim().equals("")) {
				textAreaContent = Generator.NO_INFO_AVAILABLE;
			}
			// reset title, reset saving, use browser.setText()
			editing = false;
			content.replace(content.indexOf(Generator.INFO_ID_OPEN_TAG)
					+ Generator.INFO_ID_OPEN_TAG.length(),
					content.indexOf("<!-- END OF INFO -->"), textAreaContent
							+ "\n\t\t\t" + Generator.INFO_ID_CLOSE_TAG);
			editor.setDirty(false);
			browser.setText(content.toString());
		} else if (title.equals("preRevEdit")) {
			String revContent = (String) browser
					.evaluate(Scripts.FETCH_REV_DIV_CONTENT);
			if (revContent.trim().equals(Generator.NO_REV_AVAILABLE)) {
				revContent = "";
			}
			editor.setDirty(true);
			gotoWYSIWYG(revContent, false);
		} else if (title.equals("postRevEdit")) {
			String textAreaContent = (String) browser
					.evaluate(Scripts.FETCH_REV_TEXTAREA_CONTENT);
			saveNewRevisionsAnnotation(textAreaContent);
			if (textAreaContent.trim().equals("")) {
				textAreaContent = Generator.NO_REV_AVAILABLE;
			}
			editing = false;
			content.replace(content.indexOf(Generator.REV_ID_OPEN_TAG)
					+ Generator.REV_ID_OPEN_TAG.length(),
					content.indexOf("<!-- END OF REVISIONS -->"),
					textAreaContent + "\n\t\t\t" + Generator.REV_ID_CLOSE_TAG);
			editor.setDirty(false);
			if (textAreaContent.trim().equals("")) {
				browser.evaluate(Scripts
						.setRevDivContent(Generator.NO_REV_AVAILABLE));
			}
			browser.setText(content.toString());
		} else if (title.equals("cancelInfo") || title.equals("cancelRev")) {
			editing = false;
			editor.setDirty(false);
			browser.setText(content.toString());
		}
	}

	/**
	 * Saves and renders a HTML file where the div that is about to be edited
	 * has been replaced by the TinyMCE WYSIWYG
	 * 
	 * @param divContent
	 *            The old content of the div that is about to be edited
	 * @param isInfo
	 *            True if the Information annotation is about to be edited,
	 *            false if the Revisions annotation is about to be edited
	 */
	private void gotoWYSIWYG(String divContent, boolean isInfo) {
		GoToWYSIWYGTask task = new GoToWYSIWYGTask(file, myCache, divContent,
				tinymcePath, isInfo, history.get(histIndex));
		ASTRegTaskBucket.getInstance().addTask(task);
	}

	/**
	 * Returns a string representation of the browser content
	 */
	@Override
	public String toString() {
		return content.toString();
	}

	public String getCurrentClassIdentifier() {
		HistoryObject obj = history.get(histIndex);
		if (obj.getType() == HistoryObject.TYPE_CLASS)
			return obj.getClassASTPath().get(0).id();
		else
			// if (obj.getType() == HistoryObject.TYPE_URL)
			return obj.getExternalURL();
	}

	/**
	 * Saves the content of the current WYSIWYG. Only called when the user
	 * attempts to close an editor window while a WYSIWYG for information of
	 * revision is currently open.
	 * 
	 * @return true if anything was saved.
	 */
	public boolean save() {
		if (!editing)
			return false;
		try {
			String textAreaContent = (String) browser
					.evaluate(Scripts.FETCH_INFO_TEXTAREA_CONTENT);
			editing = false;
			saveNewInformationAnnotation(textAreaContent);
			editor.setDirty(false);
		} catch (SWTException e) {
			String textAreaContent2 = (String) browser
					.evaluate(Scripts.FETCH_REV_TEXTAREA_CONTENT);
			editing = false;
			saveNewRevisionsAnnotation(textAreaContent2);
			editor.setDirty(false);
		}
		return true;
	}

	public boolean isDirty() {
		if (!editing)
			return false; // evaluate will throw an exception of editing ==
							// false
		return (Boolean) browser
				.evaluate("return tinyMCE.activeEditor.isDirty()");
	}

	public boolean yesNoBox(String message, String title) {
		MessageDialog dialog = new MessageDialog(editor.getEditorSite()
				.getShell(), title, null, message, MessageDialog.QUESTION,
				new String[] { IDialogConstants.YES_LABEL,
						IDialogConstants.NO_LABEL }, 0);
		int dialogResults = dialog.open();
		if (dialogResults == 0) { // yes
			return true;
		}
		return false;
	}

	public void undoChanges() {
		browser.evaluate(Scripts.UNDO_ALL);
	}

	@Override
	public void astChanged(IASTChangeEvent e) {
		if (e instanceof RenderClassDeclEvent) {
			RenderClassDeclEvent event = (RenderClassDeclEvent) e;
			content.append(event.getRenderedClassDecl());
			browser.setText(content.toString());
			if (event.getSetHistory())
				history.add(event.getHistoryObject());
		} else if (e instanceof GoToWYSIWYGEvent) {
			GoToWYSIWYGEvent event = (GoToWYSIWYGEvent) e;
			editing = true;
			browser.setUrl(event.getFileUrl());
		}
	}
}