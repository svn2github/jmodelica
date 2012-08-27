package org.jmodelica.ide.documentation;

import java.awt.image.BufferedImage;
import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.regex.MatchResult;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import javax.imageio.ImageIO;

import org.eclipse.core.resources.IFile;
import org.jmodelica.icons.Icon;
import org.jmodelica.ide.helpers.EclipseUtil;
import org.jmodelica.ide.helpers.Maybe;
import org.jmodelica.ide.helpers.Util;
import org.jmodelica.modelica.compiler.AbstractEquation;
import org.jmodelica.modelica.compiler.Access;
import org.jmodelica.modelica.compiler.ClassDecl;
import org.jmodelica.modelica.compiler.ComponentDecl;
import org.jmodelica.modelica.compiler.FullClassDecl;
import org.jmodelica.modelica.compiler.ImportClause;
import org.jmodelica.modelica.compiler.Program;
import org.jmodelica.modelica.compiler.ShortClassDecl;
import org.jmodelica.modelica.compiler.UnknownClassDecl;

public class Generator {
	private static final String N0 = "\n";
	private static final String N1 = "\n\t";
	private static final String N2 = "\n\t\t";
	private static final String N3 = "\n\t\t\t";
	private static final String N4 = "\n\t\t\t\t";
	private static final String N5 = "\n\t\t\t\t\t";
	private static final String N6 = "\n\t\t\t\t\t\t";
	private static final String N7 = "\n\t\t\t\t\t\t\t";
	private static final String N8 = "\n\t\t\t\t\t\t\t\t";
	private static final String FOOTER_HEIGHT = "100px";
	private static final String PRIMITIVE_TYPE = "primitive type";
	public static final String INFO_ID_OPEN_TAG = "<div id=\"infoDiv\">";
	public static final String INFO_ID_CLOSE_TAG = "</div>";
	public static final String REV_ID_OPEN_TAG = "<div id=\"revDiv\">";
	public static final String REV_ID_CLOSE_TAG = "</div>";
	public static final String INFO_BTN_DATA_PRE = "onclick='preInfoEdit()' id='editInfoButton' value='Edit..'";
	public static final String REV_BTN_DATA_PRE = "onclick='preRevEdit()' id='editRevisionButton' value='Edit..'";

	/**
	 * Creates the HTML head, including css definitions and a JavaScript file path.
	 * @param scriptPath The absolute path to a JavaScript file.
	 */
	public static String genHead(){
		return "<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Strict//EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd\">" +
				N0 + "<html xmlns=\"http://www.w3.org/1999/xhtml\">" + 
				N1 + "<head>" + 
				N2 + "<meta http-equiv=\"X-UA-Compatible\" content=\"IE=edge\" />" +
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
				N3 + "div#equations {margin-left:20; background-color:#ffffff; border:2px solid #999999; padding:0px 0px; background:#ffffff; width:807px;}"+
				N3 + "div#imports {background-color:#ffffff; border:1px solid #a1a1a1; padding:5px 5px; background:#ffffff; width:800px;}"+
				N3 + "div#extensions {background-color:#ffffff; border:1px solid #a1a1a1; padding:5px 5px; background:#ffffff; width:800px;}"+
				N3 + "a {font-family:Georgia, \"Times New Roman\", Times, serif;font-size:16px;cursor: auto}" +
				N3 + "a:link {color:#4466dd;text-decoration: none;}" +
				N3 + "a:visited {color:#4466dd;text-decoration: none;}" +
				N3 + "a:hover {color:6699ff;text-decoration: underline;}" +
				N3 + "a:active {text-decoration: none}" +
				N2 + "</style>" + N2 + "<!-- END OF CSS -->";
	}
	
	public static String genJavaScript(String scriptPath){
		return  N2 + "<!-- JAVASCRIPT -->" +
				N2 + "<script type=\"text/javascript\" src=\"" + scriptPath + "\">" + "</script>" + 
				N2 + "<script type=\"text/javascript\">" + 
				Scripts.PRE_INFO_EDIT + Scripts.PRE_REV_EDIT + Scripts.POST_INFO_EDIT + Scripts.POST_REV_EDIT + Scripts.CANCEL_INFO + Scripts.CANCEL_REV +
				N2 + "</script>" +
				N2 + "<!-- END OF JAVASCRIPT -->";

	}

	public static String genHeader(){
		return 	N1 + "</head>" + 
				N1 + "<body>" + 
				N2 + "<div id=\"wrap\">" + 
				N3 + "<div id=\"main\">";
	}

	/**
	 * Appends a breadcrumbar for a specific class declaration to the page content. The breadcrum bar 
	 * consist of the full path to class, seperated by dots, where each partial path is a hyperlink to
	 * the corresponding class declaration.
	 * @param cd The class declaration
	 * @param program The program for the source root, used for looking up classes.
	 */
	public static String genBreadCrumBar(ClassDecl cd, Program program) {
		if (cd == null) return ""; //link that didn't fall under any existing category and therefore is assumed its a classDecl even if it isn't.
		StringBuilder sb = new StringBuilder();
		StringBuilder content = new StringBuilder();
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
		content.append(N4 + "</div>" + N4 + "<!-- END OF BREADCRUMBAR -->");
		return content.toString();
	}

	public static String genTitle(FullClassDecl fcd, String folderPath){
		StringBuilder content = new StringBuilder();
		String name = fcd.getName().getID();
		content.append(N4 + "<!-- CLASS ICON, RESTRICTION AND NAME -->");
		content.append(N4 +"<h1>");
		content.append(N5 + genIcon(fcd, folderPath + "icon.png"));
		content.append(N5 + fcd.getRestriction() + " " + name + N4 + "</h1>" + N4 + "<!-- END OF CLASS ICON, RESTRICTION AND NAME -->");
		return content.toString();
	}

	public static String genComment(FullClassDecl fcd, boolean isEditable){
		if(fcd.hasStringComment()){
			return N4 + "<!-- COMMENT -->" + N4 + "<div class=\"text\">" + N5 + "<i>" + fcd.stringComment() + "</i>" + N4 + "</div> "+ N4 + "<!-- END OF COMMENT -->";
		}
		return "";
	}

	public static String genInfo (FullClassDecl fcd, boolean isEditable){
		StringBuilder content = new StringBuilder();
		String embeddedHTML = fcd.annotation().forPath("Documentation/info").string();
		content.append(N4 + "<!-- INFO -->");
		if (!isEditable){
			content.append(N4 + "<h2 id=\"buttonInsertion\">" + N5 + "Information"  + N4 + "</h2>");
		}else{
			//figure out if we're in a library. This might give false positives
			//since it treats not found files as library files
			String disabled = "";
			Maybe<IFile> iFile = EclipseUtil.getFileForPath(fcd.containingFileName());
			boolean isLib = (iFile.isNothing() ? true : Util.isInLibrary(iFile.value()));
			if (isLib){
				disabled="disabled='disabled'";
			}
			String editInfoButton = "<input class='buttonIndent' type='button' " + disabled + INFO_BTN_DATA_PRE + "/>";
			content.append(N4 + "<h2 id=\"buttonInsertion\">" + N5 + "Information&nbsp;" + editInfoButton + N4 + "</h2>");
		}
		content.append(N4 + "<!-- The embedded HTML code in the following DIV tag may not be indented in accordance with the rest of the document due to the frequent use of the PRE tag that displays all white spaces -->");
		content.append(N4 + INFO_ID_OPEN_TAG + "\n");
		if (embeddedHTML != null && !embeddedHTML.equals("")){
			content.append(processEmbeddedHTML(embeddedHTML, fcd));
		}else{
			content.append(N6 + "<i>No HTML info available</i>");
		}
		content.append(N4 + "" + INFO_ID_CLOSE_TAG + N4 + "<!-- END OF INFO -->");
		
		return content.toString();
	}

	public static String genClasses (FullClassDecl fcd){
		if (fcd.classes() == null || fcd.classes().size() == 0) return "";
		StringBuilder content = new StringBuilder();
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
		content.append(N6 + "</table>" + N5 + "</div>" + N4 + "<!-- END OF PACKAGE CONTENT -->");
		return content.toString();
	}

	public static String genImports(FullClassDecl fcd){
		if (fcd.getNumImport() == 0) return "";
		StringBuilder content = new StringBuilder();
		content.append(N4 + "<!-- IMPORTS -->");
		content.append(N4 + "<h2>Imports</h2>");
		content.append(N4 + "<div id=\"imports\">");
		for (int i = 0; i < fcd.getNumImport(); i++){
			ImportClause ic = fcd.getImport(i);
			ic.findClassDecl();
			content.append(N5 + "<div class=\"text\">" + N6 + Generator.classDeclLink(ic.findClassDecl(), true) + N5 + "</div>");
		}
		content.append(N4 + "</div>" + N4 + "<!-- END OF IMPORTS -->");
		return content.toString();
	}

	public static String genExtensions(FullClassDecl fcd){
		if (fcd.getNumSuper() == 0) return "";
		StringBuilder content = new StringBuilder();
		content.append(N4 + "<!-- EXTENSIONS -->");
		content.append(N4 + "<h2>Extends</h2>");
		content.append(N4 + "<div id=\"extensions\">");
		for (int i=0; i < fcd.getNumSuper(); i++) {
			content.append(N5 + "<div class=\"text\">" + N6 + Generator.classDeclLink(fcd.getSuper(i).findClassDecl(), true) + N5 + "</div>");
		}
		content.append(N4 + "</div>" + N4 + "<!-- END OF EXTENSIONS -->");
		return content.toString();
	}

	public static String genComponents(FullClassDecl fcd){
		if (fcd.getNumComponentDecl() == 0) return "";
		StringBuilder content = new StringBuilder();
		content.append(N4 + "<!-- COMPONENTS -->");
		content.append(N4 + "<h2> Components</h2>" + 
				N5 + "<div>" + 
				N6 + "<table BORDER=\"2\"  width=\"813\" CELLPADDING=\"3\" CELLSPACING=\"0\" >" +
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
				stringComment = Generator.modelicaToHTML(cd.getComment().getStringComment().getComment());
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
						N8 + "<td>" + Generator.classDeclLink(cdd, false) + "</td>" + 
								N8 + "<td><span class=\"text\">" + cd.getName().getID() + "</span></td>" +
								N8 + "<td><span class=\"text\">" + stringComment + "</span></td>");
			}
			content.append(N7 + "</tr>");
		}
		content.append(N6 + "</table>" + N5 + "</div>");
		content.append(N4 + "<!-- END OF COMPONENTS -->");
		return content.toString();
	}

	public static String genEquations(FullClassDecl fcd){
		if (fcd.getNumEquation() == 0) return "";
		StringBuilder content = new StringBuilder();
		String blue = "codeBlue";
		String gray = "codeGray";
		int color = 0;
		content.append(N4 + "<!-- EQUATIONS -->");
		content.append(N4 + "<h2> Equations</h2>");
		content.append(N4 + "<div id=\"equations\">");
		for (int i=0;i<fcd.getNumEquation();i++) {
			AbstractEquation ae = fcd.getEquation(i);
			String tmp = color%2 == 0 ? blue : gray;
			content.append(N5 + "<div class=\"" + tmp + "\"> " + N6 + Generator.modelicaToHTML(ae.toString()) + N5 + "</div>");
			color++;
		}
		content.append(N4 + "</div>" + N4 + "<!-- END OF EQUATIONS -->");
		return content.toString();
	}

	public static String genRevisions(FullClassDecl fcd, boolean editable){
		StringBuilder content = new StringBuilder();
		String revision = fcd.annotation().forPath("Documentation/revisions").string();
		content.append(N4 + "<!-- REVISIONS -->");
		if(!editable){
			content.append(N4 + "<h2 id=\"buttonInsertion\">" + N5 + "Revisions&nbsp;" + N4 + "</h2>");
		}else{
			String disabled = "";
			Maybe<IFile> iFile = EclipseUtil.getFileForPath(fcd.containingFileName());
			boolean isLib = (iFile.isNothing() ? true : Util.isInLibrary(iFile.value()));
			if (isLib){
				disabled="disabled='disabled'";
			}
			String editRevisionsButton = "<input class='buttonIndent' type='button' " + disabled + " onclick='preRevEdit()' id='editRevisionButton' value='Edit..'/>";
			content.append(N4 + "<h2 id=\"buttonInsertion\">" + N5 + "Revisions&nbsp;" + editRevisionsButton + N4 + "</h2>");
		}
		content.append(N4 + "<!-- The embedded HTML code in the following DIV tag may not be indented in accordance with the rest of the document due to the frequent use of the PRE tag that displays all white spaces -->");
		content.append(N4 + Generator.REV_ID_OPEN_TAG + "\n");
		if (revision != null && !revision.equals("")){
			content.append(Generator.processEmbeddedHTML(revision, fcd));
		}else{
			content.append(N6 + "<i>No revision information available</i>");
		}
		content.append(N4 + "" + Generator.REV_ID_CLOSE_TAG + N4 + "<!-- END OF REVISIONS -->");
		return content.toString();
	}

	/**
	 * Appends a footer to the end of the document. The content of the footer is determined by the constant FOOTER
	 */
	public static String genFooter(String footer){
		StringBuilder content = new StringBuilder();
		content.append(N3 + "</div> <!-- END OF MAIN -->" + N2 + "</div> <!-- END OF WRAP -->"); //closing main and wrap
		content.append(N2 + "<!-- FOOTER -->");
		content.append(N2 + "<div id=\"footer\"> <hr>" + N3 + footer + N2 + "</div>" + N2 + "<!-- END OF FOOTER -->"+ N1 + "</body>\n</html>");
		return content.toString();
	}

	public static String genShortClassDecl(ShortClassDecl scd){
		StringBuilder content = new StringBuilder();
		content.append(N4 + "<h1>" + scd.getRestriction() + " " + scd.name() + "</h1>");
		content.append(N4 + "<div class=\"code\">" + N5 + scd.prettyPrint("") + N4 + "</div>");
		return content.toString();
	}

	public static String genUnknownClassDecl(UnknownClassDecl fcd, String className) {
		return N5 + "<span>Error: The class <b>" + className + "</b> could not be found."+
				" To get the latest version of the Modelica standard library, please visit " +
				"<a href=\"https://www.modelica.org/libraries/Modelica\">https://www.modelica.org/libraries/Modelica</a></span>";
	}

	/**
	 * Extracts the actual path from a Modelica or HTTP link.
	 * @param location The location given by the browser
	 * @return The processed string
	 */
	public static String processLinkString(String location){
		String s = location.startsWith("about:") ? location.substring("about:".length()) : location;
		if (s.endsWith("/")){
			s = s.substring(0, s.length()-1);
		}
		return s.startsWith("Modelica://") || s.startsWith("modelica://") ? s.substring("modelica://".length()) : s;
	}

	/**
	 * Generates the HTML code for a hyperlink for a given class declaration.
	 * @param cd The class declaration
	 * @param printFullPath Whether the full path should be printed in the hyperlink, or only
	 * the class name. The full path is always available by hoovering over it with the mouse.
	 */
	public static String classDeclLink(ClassDecl cd, boolean printFullPath){
		String fullPath = getFullPath(cd);
		String visiblePath = printFullPath ? fullPath : cd.name();
		return "<a href=\"" + fullPath + "\" title = \"" + fullPath + "\">" + visiblePath + "</a>";
	}

	/**
	 * Determines the full modelica path for a given class declaration by traversing its parents.
	 * @param cd The class declaration
	 * @return The full path using the dotted notation
	 */
	public static String getFullPath(ClassDecl cd){
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
	 * Creates an .png image of the icon associated with the full class declaration fcd, and return a HTML string 
	 * containing an IMG tag linking to the file.
	 * @param fcd The full class declaration associated with the icon.
	 * @param fullPath The desired path and file name of the .png file.
	 * @return
	 */
	public static String genIcon(ClassDecl cd, String fullPath){
		if (!(cd instanceof FullClassDecl)) return "";
		FullClassDecl fcd = (FullClassDecl) cd;
		if (renderIcon(fcd,fullPath)){
			return "<img src=\"file:/" + fullPath + "\">";
		}
		return "<!-- No icon available -->";	
	}

	private static boolean renderIcon(FullClassDecl fcd, String folderPath){
		if (fcd.hasIcon()){
			try {
				Icon icon = fcd.icon();
				BufferedImage bi =fcd.render(icon, 32,32);
				String fileName = folderPath;
				File outputfile = new File(fileName);
				ImageIO.write(bi, "png",outputfile);
			}catch (IOException e){
				return false;
			}
			return true;
		}
		return false;
	}

	/**
	 * Prevens the '<' and '>' characters used in modelica as 'less than' and 'greater than'  to be
	 * interpreted as opening and closing of HTML tags by replacing them with their corresponding
	 * HTML codes
	 * @param s Modelica string
	 * @return HTML string
	 */
	public static String modelicaToHTML(String s){
		s = s.replaceAll("<", "&#60;");
		s = s.replaceAll(">", "&#62;");
		return s;
	}

	/**
	 * Processes user input before it is saved to a .mo file by prepending
	 * the modelica escape character \ to the symbols " and \
	 */
	public static String htmlToModelica(String s){
		s = s.replace("\\", "\\\\");
		s = s.replace("\"", "\\\"");
		return s;
	}

	/**
	 * Removes the html tag
	 * @param s The String from which the tag should be removed.
	 * @return The same String stripped from the html tag.
	 */
	public static String removeHTMLTag(String s){
		String open = "<html>";
		String close = "</html>";
		Pattern pattern;
		Matcher matcher;
		pattern = Pattern.compile(open, Pattern.CASE_INSENSITIVE | Pattern.CANON_EQ);
		matcher = pattern.matcher(s);
		StringBuffer sb = new StringBuffer();
		while(matcher.find()){
			matcher.appendReplacement(sb, "");
		}
		matcher.appendTail(sb);
		s = sb.toString();
		pattern = Pattern.compile(close, Pattern.CASE_INSENSITIVE | Pattern.CANON_EQ);
		matcher = pattern.matcher(s);
		sb = new StringBuffer();
		while(matcher.find()){
			matcher.appendReplacement(sb, "");
		}
		matcher.appendTail(sb);
		return sb.toString();
	}

	/**
	 * Processes the HTML documentation embedded in the annotation of Modelica code.
	 * This includes resolving hyperlink and image paths, as well as adding extra information
	 * available when hoovering over an element with the mouse.
	 * @param htmlCode The embedded HTML documentation
	 * @param cd The class declaration this annotation is tied to
	 * @return
	 */
	public static String processEmbeddedHTML(String htmlCode, ClassDecl cd){
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
		return imgSb.toString();
	}

	public static String genDocumentation(ClassDecl cd, Program program, String path, String footer, String className, String rootPath, String libName) {
		StringBuilder content = new StringBuilder();
		content.append(Generator.genHead());
		//don't generate JavaScript
		content.append(genHeader());
		content.append(genBreadCrumBar(cd, program));
		if (cd instanceof ShortClassDecl){
			content.append(genShortClassDecl((ShortClassDecl)cd));
			content.append(genFooter(footer));
			return resolveLinksForGenDoc(content.toString(), rootPath, libName);
		}
		if (cd instanceof UnknownClassDecl){
			content.append(genUnknownClassDecl((UnknownClassDecl)cd, className));
			content.append(genFooter(footer));
			return resolveLinksForGenDoc(content.toString(), rootPath, libName);
		}
		if (!(cd instanceof FullClassDecl)) return "";
		FullClassDecl fcd = (FullClassDecl) cd;
		content.append(genTitle(fcd, path));
		content.append(genInfo(fcd, false));
		content.append(genImports(fcd));
		content.append(genExtensions(fcd));
		content.append(genClasses(fcd));
		content.append(genComponents(fcd));
		content.append(genEquations(fcd));
		content.append(genRevisions(fcd, false));
		content.append(genFooter(footer));
		return resolveLinksForGenDoc(content.toString(), rootPath, libName);
	}
	
	private static String resolveLinksForGenDoc(String documentation, String rootPath, String libName){
		rootPath = rootPath.replace("\\", "/");
		Pattern urlPattern = Pattern.compile("<a[^>]*>(.*?)</a>" , Pattern.CASE_INSENSITIVE | Pattern.CANON_EQ);
		Matcher urlMatcher = urlPattern.matcher(documentation);
		StringBuffer urlSb = new StringBuffer();
		while (urlMatcher.find()){
			MatchResult mr = urlMatcher.toMatchResult();
			String match = documentation.substring(mr.start(), mr.end()); //e.g "Modelica://Modelica.UsersGuide.Overview"
			Pattern refP = Pattern.compile("href=\"(.+?)\"" , Pattern.CASE_INSENSITIVE | Pattern.CANON_EQ);
			Matcher refM = refP.matcher(match);
			if (refM.find()){
				MatchResult refMr = refM.toMatchResult();
				String ref = match.substring(refMr.start() + "href=\"".length(), refMr.end()-1);
				if (ref.toLowerCase().startsWith(libName.toLowerCase())){
					match = match.replaceAll("href=\"(.+?)\"", "href=\"file://" + rootPath + ref.replace(".","/" ) + "/index.html\"");
					urlMatcher.appendReplacement(urlSb, match);
				}else{
					if (ref.toLowerCase().startsWith("modelica://")){
						urlMatcher.appendReplacement(urlSb, ref.substring("modelica://".length()));
					}else{
						urlMatcher.appendReplacement(urlSb, ref);
					}
				}
			}
		}
		urlMatcher.appendTail(urlSb);
		return urlSb.toString();
	}
}
