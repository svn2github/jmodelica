package org.jmodelica.ide.documentation;

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.regex.MatchResult;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import org.eclipse.core.resources.IFile;
import org.eclipse.core.runtime.SafeRunner;
import org.eclipse.swt.browser.Browser;
import org.eclipse.swt.browser.LocationEvent;
import org.eclipse.swt.browser.LocationListener;
import org.eclipse.swt.browser.TitleEvent;
import org.eclipse.swt.browser.TitleListener;
import org.eclipse.swt.events.MouseEvent;
import org.eclipse.swt.events.MouseListener;
import org.jmodelica.ide.documentation.commands.NavigationProvider;
import org.jmodelica.ide.helpers.EclipseUtil;
import org.jmodelica.ide.helpers.Maybe;
import org.jmodelica.ide.helpers.Util;
import org.jmodelica.modelica.compiler.AbstractEquation;
import org.jmodelica.modelica.compiler.Access;
import org.jmodelica.modelica.compiler.ClassDecl;
import org.jmodelica.modelica.compiler.ComponentDecl;
import org.jmodelica.modelica.compiler.FullClassDecl;
import org.jmodelica.modelica.compiler.ImportClause;
import org.jmodelica.modelica.compiler.InstClassDecl;
import org.jmodelica.modelica.compiler.Program;
import org.jmodelica.modelica.compiler.ShortClassDecl;
import org.jmodelica.modelica.compiler.StringLitExp;
import org.jmodelica.modelica.compiler.UnknownClassDecl;

public class BrowserContent implements LocationListener, MouseListener, TitleListener{

	private StringBuilder content;
	private Browser browser;
	private HashMap<String, ClassDecl> hyperlinks;
	private ArrayList<String> history;
	private int histIndex;
	private int histSize;
	private static final String PRIMITIVE_TYPE = "primitive type";
	private String head;
	private Program program;
	private NavigationProvider navProv;
	private static final String N1 = "\n\t";
	private static final String N2 = "\n\t\t";
	private static final String N3 = "\n\t\t\t";
	private static final String N4 = "\n\t\t\t\t";
	private static final String N5 = "\n\t\t\t\t\t";
	private static final String N6 = "\n\t\t\t\t\t\t";
	private static final String N7 = "\n\t\t\t\t\t\t\t";
	private static final String N8 = "\n\t\t\t\t\t\t\t\t";
	private static final String FOOTER_HEIGHT = "100px";
	private static final String HEADER = "<i>header</i>";
	private static final String FOOTER = "<i>footer</i>";
	private static final String INFO_ID_OPEN_TAG = "<div id=\"infoDiv\">";
	private static final String INFO_ID_CLOSE_TAG = "</div>";
	private static final String REV_ID_OPEN_TAG = "<div id=\"revDiv\">";
	private static final String REV_ID_CLOSE_TAG = "</div>";
	private static final String INFO_BTN_DATA_PRE = "onclick='preInfoEdit()' id='editInfoButton' value='Edit..'";
	private static final String INFO_BTN_DATA_POST = "onclick='postInfoEdit()' id='editInfoButton' value='Save'";
	private static final String REV_BTN_DATA_PRE = "onclick='preRevEdit()' id='editRevisionButton' value='Edit..'";
	private static final String REV_BTN_DATA_POST = "onclick='postRevEdit()' id='editRevisionButton' value='Save'";
	private static final String INFO_BTN_DISABLE = "onclick='preInfoEdit()' id='editInfoButton' disabled='disabled' value='Edit..'";
	private static final String REV_BTN_DISABLE = "onclick='preRevEdit()' id='editRevisionButton' disabled='disabled' value='Edit..'";
	private static final String CANCEL_INFO_BTN = "<input class='buttonIndent' type='button' onclick='cancelInfo()' id='cancelInfoButton' value='Cancel'/>";
	private static final String CANCEL_REV_BTN = "<input class='buttonIndent' type='button' onclick='cancelRev()' id='cancelRevButton' value='Cancel'/>";



	private boolean saving = false;

	public BrowserContent(FullClassDecl fullClassDecl, Browser browser, InstClassDecl icd, Program program, NavigationProvider navProv){
		this.navProv = navProv;
		this.program = program;
		String tinymcePath = this.getClass().getProtectionDomain().getCodeSource().getLocation() + this.getClass().getResource("/resources/tinymce/jscripts/tiny_mce/tiny_mce.js").getPath();
		genHead(tinymcePath);
		hyperlinks = new HashMap<String, ClassDecl>();
		history = new ArrayList<String>();
		histIndex = 0;
		histSize = 0;
		hyperlinks.put(fullClassDecl.name(), fullClassDecl);
		history.add(getFullPath(fullClassDecl));
		this.browser = browser;
		browser.setJavascriptEnabled(true);
		browser.addLocationListener(this);
		browser.addMouseListener(this);
		browser.addTitleListener(this);
		renderClassDecl(fullClassDecl);
		//System.out.println(Scripts.FULL_FILE);
		//browser.setText(Scripts.FULL_FILE, false);
		//saving = true;
		//browser.setUrl("C:/workspace/org.jmodelica.ide.documentation/resources/test3.html");
	}

	/**
	 * Creates the HTML head, including css definitions and a JavaScript file path.
	 * @param scriptPath The absolute path to a JavaScript file.
	 */
	private void genHead(String scriptPath){
		head = "<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Strict//EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd\">" +
				"<html xmlns=\"http://www.w3.org/1999/xhtml\">" + N1 + "<head>" + 
				"<meta http-equiv=\"X-UA-Compatible\" content=\"IE=edge\" />" +
				N2 + "<!--[if IE]><style type=\"text/css\">#wrap {height:100%;display:table}</style><![endif]-->" +
				N2 +"<!-- CSS -->" + N2 + "<style type=\"text/css\">" +
				N3 + "html, body {height: 100%;}" +
				N3 + "body{background-color:#faffff;height:100%;}" +
				N3 + "#wrap {min-height: 100%;}" +
				N3 + "#main {overflow:auto; padding-bottom: " + FOOTER_HEIGHT + ";}" + //must be same height as the footer
				N3 + "div#footer {margin-left:0; position: relative; margin-top: -" + FOOTER_HEIGHT + "; height: " + FOOTER_HEIGHT + "px; clear:both;}" + //negative value of footer height
				N3 + "body:before {content:\"\";height:100%;float:left;width:0;margin-top:-32767px;}" + //opera fix
				N3 + "h1{margin-left:0;font-family:\"Arial\";color:black;font-size:28px; font: 28px 'Trebuchet MS',Arial,sans-serif;}" +
				N3 + "h2{margin-left:10;color:black;text-align:left;font-size:22px; font: 22px 'Trebuchet MS',Arial,sans-serif;}" +
				N3 + ".buttonIndent{margin-left:10; font-size:14px}" +
				N3 + ".textAreaIndent{margin-left:20;}" +
				N3 + "span{margin-left:20; font-family:Georgia, \"Times New Roman\", Times, serif;font-size:16px;}" +
				N3 + "span.text {margin-left:0}" +
				N3 + "span.code {font-family:Monospace, \"Courier New\", Times, serif;}" +
				N3 + "div{margin-left:20; font-family:Georgia, \"Times New Roman\", Times, serif; font-size:16px;}" +
				N3 + "div.codeBlue {font-size:16px; margin-left:3; margin-top:3; margin-bottom:3; margin-right:3; font-family:Monospace, \"Courier New\", Times, serif; background-color:#DDDDFF}" +
				N3 + "div.codeGray {font-size:16px; margin-left:3; margin-top:3; margin-bottom:3; margin-right:3; font-family:Monospace, \"Courier New\", Times, serif; background-color:#F3F3F3}" +
				N3 + "div.breadCrum {margin-left:0; font-size:16px; background-color:#e3e3e3}" +
				N3 + "div.header {font-size:12px;background-color:#ffffff;}" +
				N3 + "div#revDiv {background-color:#ffffff; border:1px solid #a1a1a1; padding:5px 5px; background:#ffffff; width:800px;}"+
				N3 + "div#infoDiv {background-color:#ffffff; border:1px solid #a1a1a1; padding:5px 5px; background:#ffffff; width:800px;}"+
				N3 + "div#equations {margin-left:20; background-color:#ffffff; border:3px solid #a1a1a1; padding:0px 0px; background:#ffffff; width:807px;}"+
				N3 + "div#imports {background-color:#ffffff; border:1px solid #a1a1a1; padding:5px 5px; background:#ffffff; width:800px;}"+
				N3 + "div#extensions {background-color:#ffffff; border:1px solid #a1a1a1; padding:5px 5px; background:#ffffff; width:800px;}"+

				N3 + "a {font-family:Georgia, \"Times New Roman\", Times, serif;font-size:16px;cursor: auto}" +
				N3 + "a:link {color:#4466dd;text-decoration: none;}" +
				N3 + "a:visited {color:#4466dd;text-decoration: none;}" +
				N3 + "a:hover {color:6699ff;text-decoration: underline;}" +
				N3 + "a:active {text-decoration: none}" +
				N2 + "</style>" + N2 + "<!-- /CSS -->\n" + 
				N2 + "<!-- JAVASCRIPT -->" + N2 + "<script type=\"text/javascript\" src=\"" + scriptPath + "\">" + "</script>" + 
				N2 + "<script type=\"text/javascript\">" + Scripts.PRE_INFO_EDIT + Scripts.PRE_REV_EDIT + Scripts.POST_INFO_EDIT + Scripts.POST_REV_EDIT + Scripts.CANCEL_INFO + Scripts.CANCEL_REV + "</script>" + "<!-- /JAVASCRIPT -->\n" +
				N1 + "</head>" + N1 + "<body>" + N2 + "<div id=\"wrap\">" + N3 + "<div id=\"main\">";
	}

	/**
	 * Renders a hyperlink clicked by the user. This can refer to a external site or a class declaration.
	 * @param link The unique identifier for the link. A url for a HTTP request or a modelica path
	 * for a class declaration
	 */
	public void renderLink(String link){
		navProv.setBackEnabled(histIndex > 0 ? true : false);
		navProv.setForwardEnabled(histSize > histIndex ? true : false);
		if (link.startsWith("http")){
			renderHTTP(link);
		}else{
			String s = link.startsWith("//Modelica") ? link.substring("//".length(), link.length()-1) : link;
			renderClassDecl(program.simpleLookupClassDotted(s));
			//renderClassDecl(hyperlinks.get(s));
		}
	}

	public void renderHTTP(String url){
		if (!browser.getUrl().equals(url)){
			browser.setUrl(url);
		}
	}

	/**
	 * Renders a class declaration. This includes a head, breadcrumbar, header, title, body content 
	 * and footer. The body may, depending on what type of class it is, contain properties such as
	 * containing classes, equations, components, extensions etc.
	 * @param fcd The class declaration to be rendered
	 */
	private void renderClassDecl(ClassDecl fcd){
		content = new StringBuilder(head);
		genHeader();
		genBreadCrumBar(fcd);
		if (fcd instanceof UnknownClassDecl){
			renderUnknownClassDecl((UnknownClassDecl)fcd);
			return;
		}
		if (fcd instanceof FullClassDecl){
			renderFullClassDecl((FullClassDecl) fcd);
			return;
		}
		if (fcd instanceof ShortClassDecl){
			renderShortClassDecl((ShortClassDecl) fcd);
			return;
		}
	}

	private void renderUnknownClassDecl(UnknownClassDecl fcd) {
		content.append(N5 + "<span>Error: The class <b>" + history.get(histIndex) + "</b> could not be found."+
				" To get the latest version of the Modelica standard library, please visit " +
				"<a href=\"https://www.modelica.org/libraries/Modelica\">https://www.modelica.org/libraries/Modelica</a></span>");
		genFooter();
		browser.setText(content.toString());
	}

	private void renderFullClassDecl(FullClassDecl fcd){
		String name = fcd.getName().getID();
		content.append(N4 + "<!-- CLASS INFO -->");
		content.append(N4 + "<h1>" + N5 + fcd.getRestriction() + " " + name + N4 + "</h1>" + N4 + "<!-- /CLASS INFO -->\n");
		if(fcd.hasStringComment()){
			content.append(N4 + "<!-- COMMENT -->");
			content.append(N4 + "<div class=\"text\">" + N5 + "<i>" + fcd.stringComment() + "</i>" + N4 + "</div> "+ N4 + "<!-- /COMMENT -->\n");
		}

		//DOCUMENTATION
		String embeddedHTML = fcd.annotation().forPath("Documentation/info").string();
		//figure out if we're in a library. This might give false positives
		//since it treats not found files as library files
		String disabled = "";
		Maybe<IFile> iFile = EclipseUtil.getFileForPath(fcd.containingFileName());
		boolean isLib = (iFile.isNothing() ? true : Util.isInLibrary(iFile.value()));
		if (isLib){
			disabled="disabled='disabled'";
		}

		content.append(N4 + "<!-- DOCUMENTATION -->");
		String editInfoButton = "<input class='buttonIndent' type='button' " + disabled + INFO_BTN_DATA_PRE + "/>";
		content.append(N4 + "<h2 id=\"buttonInsertion\">" + N5 + "Information&nbsp;" + editInfoButton + N4 + "</h2>" + N4 + INFO_ID_OPEN_TAG);
		if (embeddedHTML != null && !embeddedHTML.equals("")){
			content.append(processEmbeddedHTML(embeddedHTML, fcd));
		}else{
			content.append(N6 + "<i>No HTML info available</i>");
		}
		content.append(N4 + "" + INFO_ID_CLOSE_TAG + N4 + "<!-- /DOCUMENTATION -->\n");

		/*
		 * Render package
		 */
		if (fcd.getRestriction().getNodeName().equals("MPackage")){
			content.append(N4 + "<!-- PACKAGE CONTENT -->");
			content.append(N4 + "<h2>Classes</h2>");
			ArrayList<ClassDecl> fcds = fcd.classes();
			content.append(N5 + "<div>" + N6 + "<table BORDER=\"3\" CELLPADDING=\"3\" width=\"812\" CELLSPACING=\"0\" >" +
					N7 + "<tr BGCOLOR=\"#CCCCFF\" align=\"left\">" + 
					N8 + "<td><b><span class=\"text\">Class</span></b></td>" + 
					N8 + "<td><b><span class=\"text\">Restriction</span></b></td>" +
					N8 + "<td><b><span class=\"text\">Description</span></b></td></b>" + N7 + "</tr>");
			for (ClassDecl cd : fcds){
				content.append(N7 + "<tr>");
				hyperlinks.put(cd.name(), cd);
				String classCategory;
				if (cd instanceof FullClassDecl){
					classCategory = ((FullClassDecl)cd).getRestriction().toString();
				}else if (cd instanceof ShortClassDecl){
					classCategory = PRIMITIVE_TYPE;
				}else{
					classCategory = "";
				}
				String comment = "";
				if(cd.hasStringComment() && cd.stringComment() != null){
					comment = modelicaToHTML(cd.stringComment());
				}

				content.append(N8 + "<td>" + classDeclLink(cd, false) + "</td>" + 
						N8 + "<td><span class=\"text\">" + classCategory + "</span></td>" + N8 + "<td><span class=\"text\">" + comment + "&nbsp;" + "</span></td>");
				content.append(N7 + "</tr>");
			}
			content.append(N6 + "</table>" + N5 + "</div>" + N4 + "<!-- /PACKAGE CONTENT -->\n");

			/*
			 * Render model, block, type etc
			 */
		}else{
			//IMPORTS
			if (fcd.getNumImport() > 0){
				content.append(N4 + "<!-- IMPORTS -->");
				content.append(N4 + "<h2>Imports</h2>");
				content.append(N4 + "<div id=\"imports\">");
				for (int i = 0; i < fcd.getNumImport(); i++){
					ImportClause ic = fcd.getImport(i);
					ic.findClassDecl();
					content.append(N5 + "<div class=\"text\">" + N6 + classDeclLink(ic.findClassDecl(), true) + N5 + "</div>");
				}
				content.append(N4 + "</div>" + N4 + "<!-- /IMPORTS -->\n");
			}
			//EXTENSIONS
			if (fcd.getNumSuper() > 0){
				content.append(N4 + "<!-- EXTENSIONS -->");
				content.append(N4 + "<h2>Extends</h2>");
				content.append(N4 + "<div id=\"extensions\">");
				for (int i=0; i < fcd.getNumSuper(); i++) {
					content.append(N5 + "<div class=\"text\">" + N6 + classDeclLink(fcd.getSuper(i).findClassDecl(), true) + N5 + "</div>");
				}
				content.append(N4 + "</div>" + N4 + "<!-- /EXTENSIONS -->\n");
			}

			//COMPONENTS
			if (fcd.getNumComponentDecl() > 0){
				content.append(N4 + "<!-- COMPONENTS -->");
				content.append(N4 + "<h2> Components</h2>" + 
						N5 + "<div>" + 
						N6 + "<table BORDER=\"3\"  width=\"813\" CELLPADDING=\"3\" CELLSPACING=\"0\" >" +
						N7 + "<tr BGCOLOR=\"#CCCCFF\" align=\"left\">" + 
						N8 + "<td><b><span class=\"text\">Type</span></b></td>" + 
						N8 + "<td><b><span class=\"text\">Name</span></b></td>" + 
						N8 + "<td><b><span class=\"text\">Description</span></b></td></b>" + 
						N7 + "</tr>");
				for (int i=0;i<fcd.getNumComponentDecl();i++){
					content.append(N7 + "<tr>");
					ComponentDecl cd = fcd.getComponentDecl(i);
					String stringComment = "&nbsp;"; //without the html whitespace the cell isn't drawn properly(?)
					if (cd.getComment().hasStringComment()){
						stringComment = modelicaToHTML(cd.getComment().getStringComment().getComment());
					}
					Access a = cd.getClassName();
					String s = a.name(); //correct path
					ClassDecl cdd = cd.findClassDecl();
					if (cdd.isUnknown()){content.append(
							N8 + "<td>" + "<span class=\"text\">" + s + "</span></td>" +
									N8 + "<td><span class=\"text\">" + cd.getName().getID() + "</span></td>" +
									N8 + "<td><span class=\"text\">" + stringComment + "</span></td>");
					}else{
						content.append(
								N8 + "<td>" + classDeclLink(cdd, false) + "</td>" + 
										N8 + "<td><span class=\"text\">" + cd.getName().getID() + "</span></td>" +
										N8 + "<td><span class=\"text\">" + stringComment + "</span></td>");
					}
					content.append(N7 + "</tr>");
				}
				content.append(N6 + "</table>" + N5 + "</div>");
				content.append(N4 + "<!-- /COMPONENTS -->\n");
			}
			//EQUATIONS
			if (fcd.getNumEquation() > 0){
				String blue = "codeBlue";
				String gray = "codeGray";
				int color = 0;
				content.append(N4 + "<!-- EQUATIONS -->");
				content.append(N4 + "<h2> Equations</h2>");
				content.append(N4 + "<div id=\"equations\">");
				for (int i=0;i<fcd.getNumEquation();i++) {
					AbstractEquation ae = fcd.getEquation(i);
					String tmp = color%2 == 0 ? blue : gray;
					content.append(N5 + "<div class=\"" + tmp + "\"> " + N6 + modelicaToHTML(ae.toString()) + N5 + "</div>");
					color++;
				}
				content.append(N4 + "</div>" + N4 + "<!-- /EQUATIONS -->\n");
			}
		}
		//REVISIONS
		content.append(N4 + "<!-- REVISIONS -->");
		String editRevisionsButton = "<input class='buttonIndent' type='button' " + disabled + " onclick='preRevEdit()' id='editRevisionButton' value='Edit..'/>";
		content.append(N4 + "<h2 id=\"buttonInsertion\">" + N5 + "Revisions&nbsp;" + editRevisionsButton + N4 + "</h2>" + N4 + REV_ID_OPEN_TAG);
		String revision = fcd.annotation().forPath("Documentation/revisions").string();
		if (revision != null && !revision.equals("")){
			content.append(processEmbeddedHTML(revision, fcd));
		}else{
			content.append(N6 + "<i>No revision information available</i>");
		}
		content.append(N4 + "" + REV_ID_CLOSE_TAG + N4 + "<!-- /REVISIONS -->\n");
		genFooter();
		browser.setText(content.toString());
	}

	private void renderShortClassDecl(ShortClassDecl scd){
		//restriction, name, prettyprint
		content.append(N4 + "<!-- SHORT CLASS DECLARATION -->");
		content.append(N4 + "<h1>" + scd.getRestriction() + " " + scd.name() + "</h1>");
		content.append(N4 + "<div class=\"code\">" + N5 + scd.prettyPrint("") + N4 + "</div>" +
				N4 + "<span class=\"text\">" + N5 + N4 + "</span>" + N4 + "<!-- /SHORT CLASS DECLARATION -->\n");
		genFooter();
		browser.setText(content.toString());
	}

	/**
	 * Generates the HTML code for a hyperlink for a given class declaration.
	 * @param cd The class declaration
	 * @param printFullPath Whether the full path should be printed in the hyperlink, or only
	 * the class name. The full path is always available by hoovering over it with the mouse.
	 */
	private String classDeclLink(ClassDecl cd, boolean printFullPath){
		String fullPath = getFullPath(cd);
		hyperlinks.put(fullPath, cd);
		String visiblePath = printFullPath ? fullPath : cd.name();
		return "<a href=\"" + fullPath + "\" title = \"" + fullPath + "\">" + visiblePath + "</a>";
	}

	/**
	 * Determines the full modelica path for a given class declaration by traversing its parents.
	 * @param cd The class declaration
	 * @return The full path using the dotted notation
	 */
	private String getFullPath(ClassDecl cd){
		StringBuilder sb = new StringBuilder();
		ClassDecl tmp = cd;
		ArrayList<String> path = new ArrayList<String>();
		String name = cd.name();
		do{
			path.add(tmp.name());
			tmp = tmp.enclosingClassDecl();

		}while(tmp != null && !name.equals(tmp.name()));
		for (int i = path.size() - 1; i >= 0; i--){
			sb.append(path.get(i));
			if (i != 0){
				sb.append(".");
			}
		}
		return sb.toString();
	}

	/**
	 * Appends a breadcrumbar for a specific class declaration to the page content. The breadcrum bar 
	 * consist of the full path to class, seperated by dots, where each partial path is a hyperlink to
	 * the corresponding class declaration.
	 * @param cd The class declaration
	 */
	private void genBreadCrumBar(ClassDecl cd) {
		if (cd == null) return; //link that didn't fall under any existing category and therefore is assumed its a classDecl even if it isn't.
		StringBuilder sb = new StringBuilder();
		ClassDecl tmp = cd;
		ArrayList<String> path = new ArrayList<String>();
		String name2 = cd.name();
		do{
			path.add(tmp.name());
			tmp = tmp.enclosingClassDecl();

		}while(tmp != null && !name2.equals(tmp.name()));
		content.append(N4 + "<!-- BREADCRUMBAR -->");
		content.append(N4 + "<div class=\"breadCrum\">");
		for (int i = path.size() - 1; i >= 0; i--){
			sb.append(path.get(i));
			if (i == 0) {//dont add link to self
				content.append(N5 + program.simpleLookupClassDotted(sb.toString()).name());
			}else{
				content.append(N5 + classDeclLink(program.simpleLookupClassDotted(sb.toString()), false) + " ");
			}
			if (i != 0){
				sb.append(".");
				content.append(".");
			}
		}
		content.append(N4 + "</div>" + N4 + "<!-- /BREADCRUMBAR -->\n");
	}

	private void genHeader(){
	}

	/**
	 * Appends a footer to the end of the document. The content of the footer is determined by the constant FOOTER
	 */
	private void genFooter(){
		content.append(N3 + "</div> <!-- /MAIN -->" + N2 + "</div> <!-- /WRAP -->"); //closing main and wrap
		content.append(N2 + "<!-- FOOTER -->");
		content.append(N2 + "<div id=\"footer\"> <hr>" + N3 + FOOTER + N2 + "</div>" + N2 + "<!-- /FOOTER -->\n"+ N1 + "</body>\n</html>");
	}

	/**
	 * Extracts the actual path from a Modelica or HTTP link.
	 * @param location The location given by the browser
	 * @return The processed string
	 */
	private String processLinkString(String location){
		String s = location.startsWith("about:") ? location.substring("about:".length()) : location;
		if (s.endsWith("/")){
			s = s.substring(0, s.length()-1);
		}
		return s.startsWith("Modelica://") || s.startsWith("modelica://") ? s.substring("modelica://".length()) : s;
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
	 * Removes all hyper links from the input, leaving only the content of the tag
	 * @param htmlCode Input string
	 * @return The input string with all hyper links removed
	 */
	private String removeLinks(String htmlCode){
		String urlPrefix = "<a href=";
		Pattern urlPattern = Pattern.compile(urlPrefix + "\"(.+?)>", Pattern.CASE_INSENSITIVE | Pattern.CANON_EQ);
		Matcher urlMatcher = urlPattern.matcher(htmlCode);
		StringBuffer urlSb = new StringBuffer();
		while (urlMatcher.find()){
			MatchResult mr = urlMatcher.toMatchResult();
			String match = htmlCode.substring(mr.start(), mr.end()); //e.g "Modelica://Modelica.UsersGuide.Overview"
			urlMatcher.appendReplacement(urlSb, "");
		}
		urlMatcher.appendTail(urlSb);
		return urlSb.toString().replaceAll("</a>", "");
	}
	/**
	 * Processes the HTML documentation embedded in the annotation of Modelica code.
	 * This includes resolving hyperlink and image paths, as well as adding extra information
	 * available when hoovering over an element with the mouse.
	 * @param htmlCode The embedded HTML documentation
	 * @param cd The class declaration this annotation is tied to
	 * @return
	 */
	private String processEmbeddedHTML(String htmlCode, ClassDecl cd){
		//process <a href="...">
		htmlCode =  removeHTMLTag(htmlCode);
		String urlPrefix = "a href=";
		Pattern urlPattern = Pattern.compile(urlPrefix + "\"(.+?)\"", Pattern.CASE_INSENSITIVE | Pattern.CANON_EQ);
		Matcher urlMatcher = urlPattern.matcher(htmlCode);
		StringBuffer urlSb = new StringBuffer();
		while (urlMatcher.find()){
			MatchResult mr = urlMatcher.toMatchResult();
			String match = htmlCode.substring(mr.start() + urlPrefix.length(), mr.end()); //e.g "Modelica://Modelica.UsersGuide.Overview"
			String matchWithoutParentesis = match.substring(1, match.length() -1);
			if (matchWithoutParentesis.startsWith("Modelica://")){
				String classPath = matchWithoutParentesis.substring("Modelica://".length());
				hyperlinks.put(classPath, program.simpleLookupClassDotted(classPath));
			}
			urlMatcher.appendReplacement(urlSb, htmlCode.substring(mr.start(), mr.end()) + " title=" + match);
		}
		urlMatcher.appendTail(urlSb);
		//process <img src="...">
		String code = urlSb.toString();
		String imPrefix = "img src=";
		Pattern imgPattern = Pattern.compile(imPrefix + "\"(.+?)\"", Pattern.CASE_INSENSITIVE | Pattern.CANON_EQ);
		Matcher imgMatcher = imgPattern.matcher(code);
		StringBuffer imgSb = new StringBuffer();
		while(imgMatcher.find()){
			MatchResult mr = imgMatcher.toMatchResult();
			String match = code.substring(mr.start() + imPrefix.length() + 1, mr.end() - 1);
			if (match.startsWith("../")){
				match = match.substring("../".length());
			}
			String absPath = cd.uri2path(match);
			if (absPath == null) absPath = match;
			String imgTag = "img src=\"" + absPath + "\"" + " title=" + absPath;
			imgTag = imgTag.replace("\\", "\\\\");
			imgMatcher.appendReplacement(imgSb,  imgTag);
		}
		imgMatcher.appendTail(imgSb);
		return imgSb.toString().replaceAll("\n", N5 + "");
	}

	/**
	 * Removes the html tag
	 * @param data The String from which the tag should be removed.
	 * @return The same String stripped from the html tag.
	 */
	private String removeHTMLTag(String data){
		String open = "<html>";
		String close = "</html>";
		Pattern pattern;
		Matcher matcher;
		pattern = Pattern.compile(open, Pattern.CASE_INSENSITIVE | Pattern.CANON_EQ);
		matcher = pattern.matcher(data);
		StringBuffer sb = new StringBuffer();
		while(matcher.find()){
			matcher.appendReplacement(sb, "");
		}
		matcher.appendTail(sb);
		data = sb.toString();
		pattern = Pattern.compile(close, Pattern.CASE_INSENSITIVE | Pattern.CANON_EQ);
		matcher = pattern.matcher(data);
		sb = new StringBuffer();
		while(matcher.find()){
			matcher.appendReplacement(sb, "");
		}
		matcher.appendTail(sb);
		return sb.toString();
	}

	/**
	 * Adds a new String value to documentation annotation node of the current class declaration and
	 * saves it to file.
	 * @param newVal The new documentation string associated with the current class declaration.
	 */
	private void saveNewDocumentationAnnotation(String newVal){
		ClassDecl fcd = program.simpleLookupClassDotted(history.get(histIndex));
		StringLitExp exp = new StringLitExp(htmlToModelica(newVal));
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
//		if (saving){
//			Boolean cancel = (Boolean) browser.evaluate(Scripts.CONFIRM_POPUP);
//			if (!cancel) return;
//		}
		if (event.location.endsWith("file://C:/workspace/org.jmodelica.ide.documentation/DriveLib.Motor")){
			System.out.println("breakpoint");
		}
		String location = processLinkString(event.location);
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
	public String toString(){
		return content.toString();
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
			content.replace(content.indexOf(INFO_ID_OPEN_TAG) + INFO_ID_OPEN_TAG.length(), content.indexOf("<!-- /DOCUMENTATION -->"), textAreaContent + N3 + INFO_ID_CLOSE_TAG);
			saveNewDocumentationAnnotation(textAreaContent);
			browser.setText(content.toString());
		}else if(title.equals("preRevEdit")){
			String revContent = (String)browser.evaluate(Scripts.FETCH_REV_DIV_CONTENT);
			gotoWYSIWYG(revContent, false);
		}else if (title.equals("postRevEdit")){
			String textAreaContent = (String)browser.evaluate(Scripts.FETCH_REV_TEXTAREA_CONTENT);
			saving = false;
			content.replace(content.indexOf(REV_ID_OPEN_TAG) + REV_ID_OPEN_TAG.length(), content.indexOf("<!-- /REVISIONS -->"), textAreaContent + N3 + REV_ID_CLOSE_TAG);
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
	public void gotoWYSIWYG(String divContent, boolean isInfo){
		StringBuilder sb = new StringBuilder(content.toString());
		//Insert the JavaScript initialization of TinyMCE
		int insert = sb.indexOf("<script type=\"text/javascript\">") + "<script type=\"text/javascript\">".length();
		sb.insert(insert, N4 + Scripts.SCRIPT_INIT_TINY_MCE);
		//Replace the div with a textArea, with the same content [startIndex,endIndex)
		int startIndex = isInfo ? sb.indexOf(INFO_ID_OPEN_TAG) : sb.indexOf(REV_ID_OPEN_TAG);
		int endIndex = isInfo ? sb.indexOf("<!-- /DOCUMENTATION -->") : sb.indexOf("<!-- /REVISIONS -->");
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
				sb.replace(sb.indexOf(INFO_BTN_DATA_PRE), sb.indexOf(INFO_BTN_DATA_PRE)+ INFO_BTN_DATA_PRE.length(), INFO_BTN_DATA_POST);
				//Disable 'Edit..' for 'Revisions'
				sb.replace(sb.indexOf(REV_BTN_DATA_PRE), sb.indexOf(REV_BTN_DATA_PRE) + REV_BTN_DATA_PRE.length(), REV_BTN_DISABLE);
				//add cancel button
				sb.insert(sb.indexOf(INFO_BTN_DATA_POST) + INFO_BTN_DATA_POST.length() + "/>".length(), CANCEL_INFO_BTN);
			}else{
				//change from 'Edit..' to 'Save'
				sb.replace(sb.indexOf(REV_BTN_DATA_PRE), sb.indexOf(REV_BTN_DATA_PRE)+ REV_BTN_DATA_PRE.length(), REV_BTN_DATA_POST);
				//Disable 'Edit..' for 'Information'
				sb.replace(sb.indexOf(INFO_BTN_DATA_PRE), sb.indexOf(INFO_BTN_DATA_PRE) + INFO_BTN_DATA_PRE.length(), INFO_BTN_DISABLE);
				//add cancel button
				sb.insert(sb.indexOf(REV_BTN_DATA_POST) + REV_BTN_DATA_POST.length() + "/>".length(), CANCEL_REV_BTN);
			}
			//TODO
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
	 * Processes user input before it is saved to a .mo file by prepending
	 * the modelica escape character \ to the symbols " and \
	 */
	private String htmlToModelica(String s){
		s = s.replace("\\", "\\\\");
		s = s.replace("\"", "\\\"");
		return s;
	}

	/**
	 * Prevens the '<' and '>' characters used in modelica as 'less than' and 'greater than'  to be
	 * interpreted as opening and closing of HTML tags by replacing them with their corresponding
	 * HTML codes
	 * @param s Modelica string
	 * @return HTML string
	 */
	private String modelicaToHTML(String s){
		s = s.replaceAll("<", "&#60;");
		s = s.replaceAll(">", "&#62;");
		return s;
	}
}