package org.jmodelica.ide.documentation;

import java.awt.image.BufferedImage;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.FileWriter;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.regex.MatchResult;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import javax.imageio.ImageIO;
import org.eclipse.core.resources.IFile;
import org.jmodelica.icons.Icon;
import org.jmodelica.ide.documentation.wizard.GenDocWizard;
import org.jmodelica.modelica.compiler.AbstractEquation;
import org.jmodelica.modelica.compiler.Access;
import org.jmodelica.modelica.compiler.ClassDecl;
import org.jmodelica.modelica.compiler.ComponentDecl;
import org.jmodelica.modelica.compiler.FullClassDecl;
import org.jmodelica.modelica.compiler.ImportClause;
import org.jmodelica.modelica.compiler.Program;
import org.jmodelica.modelica.compiler.ShortClassDecl;
import org.jmodelica.modelica.compiler.SourceRoot;
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
	public static final String NO_INFO_AVAILABLE = "No information available";
	public static final String NO_REV_AVAILABLE = "No revisions available";
	private static final String FOOTER = "<i>footer</i>";
	public static final String CANCEL_INFO_BTN = "<input class='buttonIndent' type='button' onclick='cancelInfo()' id='cancelInfoButton' value='Cancel'/>";
	public static final String CANCEL_REV_BTN = "<input class='buttonIndent' type='button' onclick='cancelRev()' id='cancelRevButton' value='Cancel'/>";

	/**
	 * Creates the HTML head, including CSS definitions.
	 */
	public static final String genHead() {
		return "<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Strict//EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd\">"
				+ N0
				+ "<html xmlns=\"http://www.w3.org/1999/xhtml\">"
				+ N1
				+ "<head>"
				+ N2
				+ "<meta http-equiv=\"X-UA-Compatible\" content=\"IE=edge; charset=utf-8\" />"
				+ N2
				+ "<!--[if IE]><style type=\"text/css\">#wrap {height:100%;display:table}</style><![endif]-->"
				+ N2
				+ "<!-- CSS -->"
				+ N2
				+ "<style type=\"text/css\">"
				+ N3
				+ "html, body {height: 100%;}"
				+ N3
				+ "body{background-color:#faffff;height:100%;}"
				+ N3
				+ "#wrap {min-height: 100%;}"
				+ N3
				+ "#main {overflow:auto; padding-bottom: "
				+ FOOTER_HEIGHT
				+ ";}"
				+ // must be same height as the footer
				N3
				+ "div#footer {margin-left:0; position: relative; margin-top: -"
				+ FOOTER_HEIGHT
				+ "; height: "
				+ FOOTER_HEIGHT
				+ "px; clear:both;}"
				+ // negative value of footer height
				N3
				+ "body:before {content:\"\";height:100%;float:left;width:0;margin-top:-32767px;}"
				+ // opera fix
				N3
				+ "h1{margin-left:0;font-family:\"Arial\";color:black;font-size:28px; font: 28px 'Trebuchet MS',Arial,sans-serif;}"
				+ N3
				+ "h2{margin-left:10;color:black;text-align:left;font-size:22px; font: 22px 'Trebuchet MS',Arial,sans-serif;}"
				+ N3
				+ ".buttonIndent{margin-left:10; font-size:14px}"
				+ N3
				+ ".textAreaIndent{margin-left:20;}"
				+ N3
				+ "span{margin-left:20; font-family:Georgia, \"Times New Roman\", Times, serif;font-size:16px;}"
				+ N3
				+ "span.text {margin-left:0}"
				+ N3
				+ "span.code {font-family:Monospace, \"Courier New\", Times, serif;}"
				+ N3
				+ "div{margin-left:20; font-family:Georgia, \"Times New Roman\", Times, serif; font-size:16px;}"
				+ N3
				+ "div.codeBlue {font-size:16px; margin-left:3; margin-top:3; margin-bottom:3; margin-right:3; font-family:Monospace, \"Courier New\", Times, serif; background-color:#DDDDFF}"
				+ N3
				+ "div.codeGray {font-size:16px; margin-left:3; margin-top:3; margin-bottom:3; margin-right:3; font-family:Monospace, \"Courier New\", Times, serif; background-color:#F3F3F3}"
				+ N3
				+ "div.breadCrum {margin-left:0; font-size:16px; background-color:#e3e3e3}"
				+ N3
				+ "div.header {font-size:12px;background-color:#ffffff;}"
				+ N3
				+ "div#revDiv {background-color:#ffffff; border:1px solid #a1a1a1; padding:5px 5px; background:#ffffff; width:800px;}"
				+ N3
				+ "div#infoDiv {background-color:#ffffff; border:1px solid #a1a1a1; padding:5px 5px; background:#ffffff; width:800px;}"
				+ N3
				+ "div#equations {margin-left:20; background-color:#ffffff; border:2px solid #999999; padding:0px 0px; background:#ffffff; width:807px;}"
				+ N3
				+ "div#imports {background-color:#ffffff; border:1px solid #a1a1a1; padding:5px 5px; background:#ffffff; width:800px;}"
				+ N3
				+ "div#extensions {background-color:#ffffff; border:1px solid #a1a1a1; padding:5px 5px; background:#ffffff; width:800px;}"
				+ N3
				+ "a {font-family:Georgia, \"Times New Roman\", Times, serif;font-size:16px;cursor: auto}"
				+ N3
				+ "a:link {color:#4466dd;text-decoration: none;}"
				+ N3
				+ "a:visited {color:#4466dd;text-decoration: none;}"
				+ N3
				+ "a:hover {color:6699ff;text-decoration: underline;}"
				+ N3
				+ "a:active {text-decoration: none}"
				+ N2
				+ "</style>"
				+ N2
				+ "<!-- END OF CSS -->";
	}

	/**
	 * Generates the necessary HTML code to include JavaScript for the
	 * documentation view. This includes initializing TinyMCE and adding the
	 * functions to handle button clicks.
	 * 
	 * @param scriptPath
	 *            absolute path to TinyMCE
	 * @return HTML code for the JavaScript
	 */
	public static String genJavaScript(String scriptPath, boolean initTinyMCE) {
		StringBuilder sb = new StringBuilder();
		sb.append(N2 + "<!-- JAVASCRIPT -->" + N2
				+ "<script type=\"text/javascript\" src=\"" + scriptPath
				+ "\">" + "</script>" + N2
				+ "<script type=\"text/javascript\">");
		if (initTinyMCE) {
			sb.append(N3 + Scripts.SCRIPT_INIT_TINY_MCE + Scripts.CANCEL_INFO
					+ Scripts.CANCEL_REV);
		}
		sb.append(N2 + Scripts.SUPPRESS_NAVIGATION_WARNING6
				+ Scripts.PRE_INFO_EDIT + Scripts.PRE_REV_EDIT
				+ Scripts.POST_INFO_EDIT + Scripts.POST_REV_EDIT + N2
				+ "</script>" + N2 + "<!-- END OF JAVASCRIPT -->");
		return sb.toString();
	}

	public static String genHeader() {
		return N1 + "</head>" + N1 + "<body>" + N2 + "<div id=\"wrap\">" + N3
				+ "<div id=\"main\">";
	}

	/**
	 * Appends a breadcrumbar for a specific class declaration to the page
	 * content. The breadcrum bar consist of the full path to class, seperated
	 * by dots, where each partial path is a hyperlink to the corresponding
	 * class declaration.
	 * 
	 * @param cd
	 *            The class declaration
	 * @param program
	 *            The program for the source root, used for looking up classes.
	 */
	public static String genBreadCrumBar(ClassDecl cd, Program program) {
		if (cd == null)
			return ""; // link that didn't fall under any existing category and
						// therefore is assumed its a classDecl even if it
						// isn't.
		StringBuilder sb = new StringBuilder();
		StringBuilder content = new StringBuilder();
		ClassDecl tmp = cd;
		ArrayList<String> path = new ArrayList<String>();
		String name2 = cd.name();
		do {
			path.add(tmp.name());
			tmp = tmp.enclosingClassDecl();

		} while (tmp != null && !name2.equals(tmp.name()));
		content.append(N4 + "<!-- BREADCRUMBAR -->");
		content.append(N4 + "<div class=\"breadCrum\">");
		for (int i = path.size() - 1; i >= 0; i--) {
			sb.append(path.get(i));
			if (i == 0) {// dont add link to self
				content.append(N5
						+ program.simpleLookupClassDotted(sb.toString()).name());
			} else {
				content.append(N5
						+ classDeclLink(
								program.simpleLookupClassDotted(sb.toString()),
								false) + " ");
			}
			if (i != 0) {
				sb.append(".");
				content.append(".");
			}
		}
		content.append(N4 + "</div>" + N4 + "<!-- END OF BREADCRUMBAR -->");
		return content.toString();
	}

	/**
	 * Generates HTML code for showing the icon, restriction and name of the
	 * FullClassDecl
	 * 
	 * @param fcd
	 *            the FullClassDecl
	 * @param folderPath
	 *            Path to the icon
	 * @param offline
	 *            Whether its used for documentation view or documentation
	 *            generation. In the latter case the icon needs to be copied and
	 *            the path has to be made relative
	 * @return The HTML string
	 */
	public static String genTitle(FullClassDecl fcd, String folderPath,
			boolean offline) {
		StringBuilder content = new StringBuilder();
		String name = fcd.getName().getID();
		content.append(N4 + "<!-- CLASS ICON, RESTRICTION AND NAME -->");
		content.append(N4 + "<h1>");
		content.append(N5 + genIcon(fcd, folderPath + "icon.png"));
		content.append(N5 + fcd.getRestriction() + " " + name + N4 + "</h1>"
				+ N4 + "<!-- END OF CLASS ICON, RESTRICTION AND NAME -->");
		return content.toString();
	}

	/**
	 * Generates the HTML code for showing the comment in the FullClassDecl, if
	 * any
	 * 
	 * @param fcd
	 *            The FullClassDecl
	 * @return The HTML string
	 */
	public static String genComment(FullClassDecl fcd) {
		if (fcd.hasStringComment()) {
			return N4 + "<!-- COMMENT -->" + N4 + "<div class=\"text\">" + N5
					+ "<i>" + fcd.stringComment() + "</i>" + N4 + "</div> "
					+ N4 + "<!-- END OF COMMENT -->";
		}
		return "";
	}

	/**
	 * Generates HTML code for showing the information of the FullClassDecl
	 * 
	 * @param fcd
	 *            The FullClassDecl
	 * @param offline
	 *            Whether its used for documentation view or documentation
	 *            generation. In the latter case the information will not be
	 *            editable, and the 'Edit' button should not be included
	 * @return The HTML String
	 */
	public static String genInfo(FullClassDecl fcd, boolean offline,
			SourceRoot sourceRoot, boolean forceDisabled) {

		StringBuilder content = new StringBuilder();
		String info;
		boolean isLib;
		synchronized (fcd.state()) {
			try {
				IFile file = fcd.getDefinition().getFile();
				isLib = !(file != null && file.getProject() == sourceRoot
						.getProject());
			} catch (NullPointerException e) {
				isLib = true;
			}
		}
		synchronized (fcd.state()) {
			info = processEmbeddedHTML(
					fcd.annotation().forPath("Documentation/info").string(),
					fcd).trim();
			// cases in switch an empty string should be returned:
			// (1) is in a library AND there is no info
			if (isLib && (info == null || info.trim().equals("")))
				return "";
			// (2) is offline AND there is no info
			if (offline && (info == null || info.trim().equals("")))
				return "";
		}
		content.append(N4 + "<!-- INFO -->");
		if (offline) {
			content.append(N4 + "<h2 id=\"buttonInsertion\">" + N5
					+ "Information" + N4 + "</h2>");
		} else {
			String disabled = "";

			if (isLib || forceDisabled) {
				disabled = "disabled='disabled'";
			}
			String editInfoButton = "<input class='buttonIndent' type='button' "
					+ disabled + INFO_BTN_DATA_PRE + "/>";
			content.append(N4 + "<h2 id=\"buttonInsertion\">" + N5
					+ "Information&nbsp;" + editInfoButton + N4 + "</h2>");
		}
		content.append(N4
				+ "<!-- The embedded HTML code in the following DIV tag may not be indented in accordance with the rest of the document due to the frequent use of the PRE tag that displays all white spaces -->");
		content.append(N4 + INFO_ID_OPEN_TAG + "\n");
		if (info != null && !info.equals("")) {
			content.append(info);
		} else {
			content.append(N6 + NO_INFO_AVAILABLE);
		}
		content.append(N4 + "" + INFO_ID_CLOSE_TAG + N4
				+ "<!-- END OF INFO -->");

		return content.toString();
	}

	/**
	 * Generates the HTML code for showing the classes contained in the
	 * FullClassDecl fcd
	 * 
	 * @param fcd
	 *            The FullClassDecl
	 * @return The HTML string
	 */
	public static String genClasses(FullClassDecl fcd) {
		if (fcd.classes() == null || fcd.classes().size() == 0)
			return "";
		StringBuilder content = new StringBuilder();
		content.append(N4 + "<!-- PACKAGE CONTENT -->");
		content.append(N4 + "<h2>Classes</h2>");
		synchronized (fcd.state()) {
			ArrayList<ClassDecl> fcds = fcd.classes();
			content.append(N5
					+ "<div>"
					+ N6
					+ "<table BORDER=\"3\" CELLPADDING=\"3\" width=\"812\" CELLSPACING=\"0\" >"
					+ N7
					+ "<tr BGCOLOR=\"#CCCCFF\" align=\"left\">"
					+ N8
					+ "<td><b><span class=\"text\">Class</span></b></td>"
					+ N8
					+ "<td><b><span class=\"text\">Restriction</span></b></td>"
					+ N8
					+ "<td><b><span class=\"text\">Description</span></b></td></b>"
					+ N7 + "</tr>");
			for (ClassDecl cd : fcds) {
				content.append(N7 + "<tr>");
				String classCategory;
				if (cd instanceof FullClassDecl) {
					classCategory = ((FullClassDecl) cd).getRestriction()
							.toString();
				} else if (cd instanceof ShortClassDecl) {
					classCategory = PRIMITIVE_TYPE;
				} else {
					classCategory = "";
				}
				String comment = "";
				if (cd.hasStringComment() && cd.stringComment() != null) {
					comment = modelicaToHTML(cd.stringComment());
				}

				content.append(N8 + "<td>" + classDeclLink(cd, false) + "</td>"
						+ N8 + "<td><span class=\"text\">" + classCategory
						+ "</span></td>" + N8 + "<td><span class=\"text\">"
						+ comment + "&nbsp;" + "</span></td>");
				content.append(N7 + "</tr>");
			}
		}
		content.append(N6 + "</table>" + N5 + "</div>" + N4
				+ "<!-- END OF PACKAGE CONTENT -->");
		return content.toString();
	}

	/**
	 * Generates the HTML code for showing the imports in the FullClassDecl fcd
	 * 
	 * @param fcd
	 *            The FullClassDecl
	 * @return The HTML string
	 */
	public static String genImports(FullClassDecl fcd) {
		StringBuilder content;
		synchronized (fcd.state()) {

			if (fcd.getNumImport() == 0)
				return "";
			content = new StringBuilder();
			content.append(N4 + "<!-- IMPORTS -->");
			content.append(N4 + "<h2>Imports</h2>");
			content.append(N4 + "<div id=\"imports\">");
			for (int i = 0; i < fcd.getNumImport(); i++) {
				ImportClause ic = fcd.getImport(i);
				ic.getPackageName().name();
				boolean unknown = ic.findClassDecl().isUnknown();
				if (!unknown) {
					content.append(N5 + "<div class=\"text\">" + N6
							+ Generator.classDeclLink(ic.findClassDecl(), true)
							+ N5 + "</div>");
				} else {
					content.append(N5 + "<div class=\"text\">" + N6
							+ ic.getPackageName().name() + N5 + "</div>");
				}
			}
		}
		content.append(N4 + "</div>" + N4 + "<!-- END OF IMPORTS -->");
		return content.toString();
	}

	/**
	 * Generates the HTML code for showing the extensions in the FullClassDecl
	 * fcd
	 * 
	 * @param fcd
	 *            The FullClassDecl
	 * @return The HTML string
	 */
	public static String genExtensions(FullClassDecl fcd) {
		StringBuilder content;
		synchronized (fcd.state()) {
			if (fcd.getNumSuper() == 0)
				return "";
			content = new StringBuilder();
			content.append(N4 + "<!-- EXTENSIONS -->");
			content.append(N4 + "<h2>Extends</h2>");
			content.append(N4 + "<div id=\"extensions\">");
			for (int i = 0; i < fcd.getNumSuper(); i++) {
				if (fcd.getSuper(i).findClassDecl() instanceof UnknownClassDecl) {
					// content.append(N5 + "<div class=\"text\">" + N6 +
					// "Unknown Class" + N5 + "</div>");
				} else {
					content.append(N5
							+ "<div class=\"text\">"
							+ N6
							+ Generator.classDeclLink(fcd.getSuper(i)
									.findClassDecl(), true) + N5 + "</div>");
				}
			}
		}
		content.append(N4 + "</div>" + N4 + "<!-- END OF EXTENSIONS -->");
		return content.toString();
	}

	/**
	 * Generates the HTML code for showing the components in the FullClassDecl
	 * fcd
	 * 
	 * @param fcd
	 *            The FullClassDecl
	 * @return The HTML string
	 */
	public static String genComponents(FullClassDecl fcd) {
		synchronized (fcd.state()) {
			if (fcd.getNumComponentDecl() == 0)
				return "";
		}
		StringBuilder content = new StringBuilder();
		content.append(N4 + "<!-- COMPONENTS -->");
		content.append(N4
				+ "<h2> Components</h2>"
				+ N5
				+ "<div>"
				+ N6
				+ "<table BORDER=\"2\"  width=\"813\" CELLPADDING=\"3\" CELLSPACING=\"0\" >"
				+ N7 + "<tr BGCOLOR=\"#CCCCFF\" align=\"left\">" + N8
				+ "<td><b><span class=\"text\">Type</span></b></td>" + N8
				+ "<td><b><span class=\"text\">Name</span></b></td>" + N8
				+ "<td><b><span class=\"text\">Description</span></b></td></b>"
				+ N7 + "</tr>");
		synchronized (fcd.state()) {
			for (int i = 0; i < fcd.getNumComponentDecl(); i++) {
				content.append(N7 + "<tr>");
				ComponentDecl cd = fcd.getComponentDecl(i);
				String stringComment = "&nbsp;"; // without the html whitespace
													// the empty cell isn't
													// drawn properly(?)
				if (cd.getComment().hasStringComment()) {
					stringComment = Generator.modelicaToHTML(cd.getComment()
							.getStringComment().getComment());
				}
				Access a = cd.getClassName();
				String s = a.name(); // correct path
				ClassDecl cdd = cd.findClassDecl();
				if (cdd.isUnknown()) {
					content.append(N8 + "<td>" + "<span class=\"text\">" + s
							+ "</span></td>" + N8 + "<td><span class=\"text\">"
							+ cd.getName().getID() + "</span></td>" + N8
							+ "<td><span class=\"text\">" + stringComment
							+ "</span></td>");
				} else {
					content.append(N8 + "<td>"
							+ Generator.classDeclLink(cdd, false) + "</td>"
							+ N8 + "<td><span class=\"text\">"
							+ cd.getName().getID() + "</span></td>" + N8
							+ "<td><span class=\"text\">" + stringComment
							+ "</span></td>");
				}
				content.append(N7 + "</tr>");
			}
		}
		content.append(N6 + "</table>" + N5 + "</div>");
		content.append(N4 + "<!-- END OF COMPONENTS -->");
		return content.toString();
	}

	/**
	 * Generates the HTML code for showing the equations in the FullClassDecl
	 * fcd
	 * 
	 * @param fcd
	 *            The FullClassDecl
	 * @return The HTML string
	 */
	public static String genEquations(FullClassDecl fcd) {
		synchronized (fcd.state()) {
			if (fcd.getNumEquation() == 0)
				return "";
		}
		StringBuilder content = new StringBuilder();
		String blue = "codeBlue";
		String gray = "codeGray";
		int color = 0;
		content.append(N4 + "<!-- EQUATIONS -->");
		content.append(N4 + "<h2> Equations</h2>");
		content.append(N4 + "<div id=\"equations\">");
		synchronized (fcd.state()) {
			for (int i = 0; i < fcd.getNumEquation(); i++) {
				AbstractEquation ae = fcd.getEquation(i);
				String tmp = color % 2 == 0 ? blue : gray;
				content.append(N5 + "<div class=\"" + tmp + "\"> " + N6
						+ Generator.modelicaToHTML(ae.toString()) + N5
						+ "</div>");
				color++;
			}
		}
		content.append(N4 + "</div>" + N4 + "<!-- END OF EQUATIONS -->");
		return content.toString();
	}

	/**
	 * Generates the HTML code for showing the revision information of the
	 * FullClassDecl fcd
	 * 
	 * @param fcd
	 *            The FullClassDecl
	 * @param offline
	 *            Whether its used for documentation view or documentation
	 *            generation. In the latter case the revision information will
	 *            not be editable, and the 'Edit' button should not be included
	 * @return The HTML string
	 */
	public static String genRevisions(FullClassDecl fcd, boolean offline,
			SourceRoot sourceRoot, boolean forceDisabled) {
		StringBuilder content = new StringBuilder();
		String revision;
		boolean isLib;
		synchronized (fcd.state()) {
			try {
				IFile file = fcd.getDefinition().getFile();
				isLib = !(file != null && file.getProject() == sourceRoot
						.getProject());
			} catch (NullPointerException e) {
				isLib = true;
			}
		}
		synchronized (fcd.state()) {
			revision = processEmbeddedHTML(
					fcd.annotation().forPath("Documentation/revisions")
							.string(), fcd).trim();
			// cases in switch an empty string should be returned:
			// (1) is in a library AND there is no info
			if (isLib && (revision == null || revision.trim().equals("")))
				return "";
			// (2) is offline AND there is no rev
			if (offline && (revision == null || revision.trim().equals("")))
				return "";
		}
		content.append(N4 + "<!-- REVISIONS -->");
		if (offline) {
			content.append(N4 + "<h2 id=\"buttonInsertion\">" + N5
					+ "Revisions&nbsp;" + N4 + "</h2>");
		} else {
			String disabled = "";

			if (isLib || forceDisabled) {
				disabled = "disabled='disabled'";
			}
			String editRevisionsButton = "<input class='buttonIndent' type='button' "
					+ disabled
					+ " onclick='preRevEdit()' id='editRevisionButton' value='Edit..'/>";
			content.append(N4 + "<h2 id=\"buttonInsertion\">" + N5
					+ "Revisions&nbsp;" + editRevisionsButton + N4 + "</h2>");
		}
		content.append(N4
				+ "<!-- The embedded HTML code in the following DIV tag may not be indented in accordance with the rest of the document due to the frequent use of the PRE tag that displays all white spaces -->");
		content.append(N4 + Generator.REV_ID_OPEN_TAG + "\n");
		if (revision != null && !revision.equals("")) {
			content.append(revision);
		} else {
			content.append(N6 + NO_REV_AVAILABLE);
		}
		content.append(N4 + "" + Generator.REV_ID_CLOSE_TAG + N4
				+ "<!-- END OF REVISIONS -->");
		return content.toString();
	}

	/**
	 * NOTE: Currently does not add a footer. Appends a footer to the end of the
	 * document.
	 * 
	 * @param footer
	 * @return
	 */
	public static String genFooter(String footer) {
		StringBuilder content = new StringBuilder();
		content.append(N3 + "</div> <!-- END OF MAIN -->" + N2
				+ "</div> <!-- END OF WRAP -->"); // closing main and wrap
		// content.append(N2 + "<!-- FOOTER -->");
		// content.append(N2 + "<div id=\"footer\"> <hr>" + N3 + footer + N2 +
		// "</div>" + N2 + "<!-- END OF FOOTER -->"+ N1 + "</body>\n</html>");
		content.append(N2 + "<!-- END OF FOOTER -->" + N1 + "</body>\n</html>");
		return content.toString();
	}

	/**
	 * Generates the HTML code for showing the ShortClassDecl scd
	 * 
	 * @param scd
	 *            The ShortClassDecl
	 * @return The HTML string
	 */
	public static String genShortClassDecl(ShortClassDecl scd) {
		StringBuilder content = new StringBuilder();
		synchronized (scd.state()) {
			content.append(N4 + "<h1>" + scd.getRestriction() + " "
					+ scd.name() + "</h1>");
			content.append(N4 + "<div class=\"code\">" + N5
					+ scd.prettyPrint("") + N4 + "</div>");
		}
		return content.toString();
	}

	/**
	 * Generates the HTML code for showing the UnknownClassDecl fcd
	 * 
	 * @param fcd
	 *            The UnknownClassDecl
	 * @param className
	 *            The name of the class not found, since this can not be
	 *            extracted from fcd
	 * @return The HTML string
	 */
	public static String genUnknownClassDecl(UnknownClassDecl fcd) {
		// TODO remove second parameter
		return N5 + "<span>Error: The class <b>" + fcd.name()
				+ "</b> could not be found.</span>";
	}

	/**
	 * Extracts the actual path from a Modelica or HTTP link.
	 * 
	 * @param location
	 *            The location given by the browser
	 * @return The processed string
	 */
	public static String processLinkString(String location) {
		String s = location.startsWith("about:") ? location.substring("about:"
				.length()) : location;
		if (s.endsWith("/")) {
			s = s.substring(0, s.length() - 1);
		}
		return s.toLowerCase().startsWith("modelica://") ? s
				.substring("modelica://".length()) : s;
	}

	/**
	 * Generates the HTML code for a hyperlink for a given class declaration.
	 * 
	 * @param cd
	 *            The class declaration
	 * @param printFullPath
	 *            Whether the full path should be printed in the hyperlink, or
	 *            only the class name. The full path is always available by
	 *            hoovering over it with the mouse.
	 */
	public static String classDeclLink(ClassDecl cd, boolean printFullPath) {
		String fullPath = getFullPath(cd);
		String visiblePath = printFullPath ? fullPath : cd.name();
		return "<a href=\"" + fullPath + "\" title = \"" + fullPath + "\">"
				+ visiblePath + "</a>";
	}

	/**
	 * Determines the full modelica path for a given class declaration by
	 * traversing its parents.
	 * 
	 * @param cd
	 *            The class declaration
	 * @return The full path using the dotted notation
	 */
	public static String getFullPath(ClassDecl cd) {
		StringBuilder sb = new StringBuilder();
		ClassDecl tmp = cd;
		ArrayList<String> path = new ArrayList<String>();
		String name = cd.name();
		synchronized (cd.state()) {
			do {
				path.add(tmp.name());
				tmp = tmp.enclosingClassDecl();

			} while (tmp != null && !name.equals(tmp.name()));
		}
		for (int i = path.size() - 1; i >= 0; i--) {
			sb.append(path.get(i));
			if (i != 0) {
				sb.append(".");
			}
		}
		return sb.toString();
	}

	/**
	 * Removes all hyper links from the input, leaving only the content of the
	 * tag
	 * 
	 * @param htmlCode
	 *            Input string
	 * @return The input string with all hyper links removed
	 */
	/**
	 * private String removeLinks(String htmlCode) { String urlPrefix =
	 * "<a href="; Pattern urlPattern = Pattern.compile(urlPrefix + "\"(.+?)>",
	 * Pattern.CASE_INSENSITIVE | Pattern.CANON_EQ); Matcher urlMatcher =
	 * urlPattern.matcher(htmlCode); StringBuffer urlSb = new StringBuffer();
	 * while (urlMatcher.find()) { MatchResult mr = urlMatcher.toMatchResult();
	 * urlMatcher.appendReplacement(urlSb, ""); } urlMatcher.appendTail(urlSb);
	 * return urlSb.toString().replaceAll("</a>", ""); }
	 */

	/**
	 * Creates an .png image of the icon (32 by 32 px) associated with the full
	 * class declaration fcd, and return a HTML string containing an IMG tag
	 * linking to the file.
	 * 
	 * @param cd
	 *            The full class declaration associated with the icon.
	 * @param fullPath
	 *            The desired path and file name of the .png file.
	 * @return The HTML string
	 */
	public static String genIcon(ClassDecl cd, String fullPath) {
		return genIcon(cd, fullPath, 32, 32);
	}

	/**
	 * Creates an .PNG image of the icon associated with the full class
	 * declaration fcd, and return a HTML string containing an IMG tag linking
	 * to the file.
	 * 
	 * @param cd
	 *            The full class declaration associated with the icon.
	 * @param fullPath
	 *            The desired path and file name of the .png file.
	 * @param width
	 *            The width of the icon in pixels
	 * @param height
	 *            The height of the icon in pixels
	 * @return The HTML string
	 */
	public static String genIcon(ClassDecl cd, String fullPath, int width,
			int height) {
		if (!(cd instanceof FullClassDecl))
			return "";
		FullClassDecl fcd = (FullClassDecl) cd;
		if (renderIcon(fcd, fullPath, width, height)) {
			return "<img src=\"file:/" + fullPath + "\">";

		}
		return "<!-- No icon available -->";
	}

	/**
	 * Renders the icon and saves it to file as a .png
	 * 
	 * @param fcd
	 *            The FullClassDecl the icon belongs to
	 * @param folderPath
	 *            The location the icon should be saved it
	 * @param width
	 *            The width of the icon in pixels
	 * @param height
	 *            The height of the icon in pixels
	 * @return
	 */
	private static boolean renderIcon(FullClassDecl fcd, String folderPath,
			int width, int height) {
		if (fcd.hasIcon()) {
			try {
				Icon icon;
				synchronized (fcd.state()) {
					icon = fcd.icon();
				}
				BufferedImage bi = fcd.render(icon, width, height);
				String fileName = folderPath;
				File outputfile = new File(fileName);
				ImageIO.write(bi, "png", outputfile);
			} catch (IOException e) {
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
	public static String modelicaToHTML(String s) {
		s = s.replaceAll("<", "&#60;");
		s = s.replaceAll(">", "&#62;");
		return s;
	}

	/**
	 * Processes user input before it is saved to a .mo file by prepending the
	 * Modelica escape character \ to the symbols " and \
	 */
	public static String htmlToModelica(String s) {
		s = s.replace("\\", "\\\\");
		s = s.replace("\"", "\\\"");
		return s;
	}

	/**
	 * Removes the <HTML> tag that might be enclosing existing documentation to
	 * prevent nesting of <HTML> tags in the document
	 * 
	 * @param s
	 *            The String from which the tag should be removed.
	 * @return The same String stripped from the HTML tag.
	 */
	public static String removeHTMLTag(String s) {
		String open = "<html>";
		String close = "</html>";
		Pattern pattern;
		Matcher matcher;
		pattern = Pattern.compile(open, Pattern.CASE_INSENSITIVE
				| Pattern.CANON_EQ);
		matcher = pattern.matcher(s);
		StringBuffer sb = new StringBuffer();
		while (matcher.find()) {
			matcher.appendReplacement(sb, "");
		}
		matcher.appendTail(sb);
		s = sb.toString();
		pattern = Pattern.compile(close, Pattern.CASE_INSENSITIVE
				| Pattern.CANON_EQ);
		matcher = pattern.matcher(s);
		sb = new StringBuffer();
		while (matcher.find()) {
			matcher.appendReplacement(sb, "");
		}
		matcher.appendTail(sb);
		return sb.toString();
	}

	/**
	 * Processes the HTML documentation embedded in the annotation of Modelica
	 * code. This includes resolving hyperlink and image paths, as well as
	 * adding extra information available when hoovering over an element with
	 * the mouse.
	 * 
	 * @param htmlCode
	 *            The embedded HTML documentation
	 * @param cd
	 *            The class declaration this annotation is tied to
	 * @return
	 */
	public static String processEmbeddedHTML(String htmlCode, ClassDecl cd) {
		if (htmlCode == null || htmlCode.trim().equals(""))
			return "";
		// process <a href="...">
		htmlCode = removeHTMLTag(htmlCode); // don't want nested HTML tags
		// Add a title to every "a href="
		String urlPrefix = "a href=";
		Pattern urlPattern = Pattern.compile(urlPrefix + "\"(.+?)\"",
				Pattern.CASE_INSENSITIVE | Pattern.CANON_EQ);
		Matcher urlMatcher = urlPattern.matcher(htmlCode);
		StringBuffer urlSb = new StringBuffer();
		while (urlMatcher.find()) {
			MatchResult mr = urlMatcher.toMatchResult();
			String match = htmlCode.substring(mr.start() + urlPrefix.length(),
					mr.end()); // e.g "Modelica://Modelica.UsersGuide.Overview"
			urlMatcher.appendReplacement(urlSb,
					htmlCode.substring(mr.start(), mr.end()) + " title="
							+ match);
		}
		urlMatcher.appendTail(urlSb);
		// process <img src="...">
		String code = urlSb.toString();
		String imPrefix = "img src=";
		Pattern imgPattern = Pattern.compile(imPrefix + "\"(.+?)\"",
				Pattern.CASE_INSENSITIVE | Pattern.CANON_EQ);
		Matcher imgMatcher = imgPattern.matcher(code);
		StringBuffer imgSb = new StringBuffer();
		while (imgMatcher.find()) {
			MatchResult mr = imgMatcher.toMatchResult();
			String match = code.substring(mr.start() + imPrefix.length() + 1,
					mr.end() - 1);
			if (match.startsWith("../")) {
				match = match.substring("../".length());
			}
			String absPath;
			synchronized (cd.state()) {
				absPath = cd.uri2path(match);
			}
			if (absPath == null)
				absPath = match;
			String imgTag;

			imgTag = "img src=\"" + absPath + "\"" + " title=\"" + absPath
					+ "\"";
			imgTag = imgTag.replace("\\", "\\\\");

			imgMatcher.appendReplacement(imgSb, imgTag);
		}
		imgMatcher.appendTail(imgSb);
		return imgSb.toString();
	}

	/**
	 * Copies a file. If present, HTML (file://) and Modelica (Modelica://)
	 * prefixes are removed.
	 * 
	 * @param srFile
	 *            The source file
	 * @param dtFile
	 *            The destination file
	 * @return
	 */
	private static boolean copyFile(String srFile, String dtFile) {
		try {
			if (srFile.startsWith("file://"))
				srFile = srFile.substring("file://".length());
			if (srFile.startsWith("modelica://")
					|| srFile.startsWith("Modelica://"))
				srFile = srFile.substring("modelica://".length());
			File f1 = new File(srFile);
			if (dtFile.startsWith("modelica://")
					|| dtFile.startsWith("Modelica://"))
				dtFile = dtFile.substring("modelica://".length());
			if (dtFile.startsWith("file://"))
				dtFile = dtFile.substring("file://".length());
			File f2 = new File(dtFile);
			InputStream in = new FileInputStream(f1);
			OutputStream out = new FileOutputStream(f2);
			byte[] buf = new byte[1024];
			int len;
			while ((len = in.read(buf)) > 0) {
				out.write(buf, 0, len);
			}
			in.close();
			out.close();
		} catch (FileNotFoundException ex) {
			return false;
		} catch (IOException e) {
			return false;
		}
		return true;
	}

	/**
	 * Generates all the documentation for a given ClassDecl cd, and classes
	 * below it, to file
	 * 
	 * @param cd
	 *            The ClassDecl
	 * @param sourceRoot
	 *            the current source root, needed for class lookups
	 * @param path
	 *            The path to the icon
	 * @param footer
	 *            String appended to the end of the document
	 * @param className
	 *            The name of the class (in case cd is an instance of an
	 *            UnknownClassDecl)
	 * @param rootPath
	 *            The path to the destination of the generation
	 * @param libName
	 *            The name of the library containing cd
	 * @param options
	 *            What part of the class should be generated (comment, info,
	 *            imports etc.)
	 * @return The HTML string describing the ClassDecl
	 */
	public static String genDocumentation(ClassDecl cd, SourceRoot sourceRoot,
			String path, String footer, String className, String rootPath,
			String libName, HashMap<String, Boolean> options) {
		StringBuilder content = new StringBuilder();
		content.append(Generator.genHead());
		// don't generate JavaScript
		content.append(genHeader());
		content.append(genBreadCrumBar(cd, sourceRoot.getProgram()));
		if (cd instanceof ShortClassDecl) {
			content.append(genShortClassDecl((ShortClassDecl) cd));
			content.append(genFooter(footer));
			return resolveLinksForGenDoc(content.toString(), rootPath, libName,
					cd);
		}
		if (cd instanceof UnknownClassDecl) {
			content.append(genUnknownClassDecl((UnknownClassDecl) cd));
			content.append(genFooter(footer));
			return resolveLinksForGenDoc(content.toString(), rootPath, libName,
					cd);
		}
		if (!(cd instanceof FullClassDecl))
			return "";
		FullClassDecl fcd = (FullClassDecl) cd;
		content.append(genTitle(fcd, path, true));
		if (options.get(GenDocWizard.COMMENT))
			content.append(genComment(fcd));
		if (options.get(GenDocWizard.INFORMATION))
			content.append(genInfo(fcd, true, sourceRoot, false));
		if (options.get(GenDocWizard.IMPORTS))
			content.append(genImports(fcd));
		if (options.get(GenDocWizard.EXTENSIONS))
			content.append(genExtensions(fcd));
		content.append(genClasses(fcd));
		if (options.get(GenDocWizard.COMPONENTS))
			content.append(genComponents(fcd));
		if (options.get(GenDocWizard.EQUATIONS))
			content.append(genEquations(fcd));
		if (options.get(GenDocWizard.REVISIONS))
			content.append(genRevisions(fcd, true, sourceRoot, false));
		content.append(genFooter(footer));
		return resolveLinksForGenDoc(content.toString(), rootPath, libName, cd);
	}

	/**
	 * Makes all links relative for offline documentation generation
	 * 
	 * @param documentation
	 *            The HTML string of the class
	 * @param rootPath
	 *            The destination folder of the generation
	 * @param libName
	 *            The name of the library
	 * @param cd
	 *            The ClassDecl
	 * @return
	 */
	private static String resolveLinksForGenDoc(String documentation,
			String rootPath, String libName, ClassDecl cd) {
		// make all links relative to "libName"
		// start by figuring out the path from libName to cd
		String path = getFullPath(cd);
		// rootPath = rootPath.replace("\\", "/");
		Pattern urlPattern = Pattern.compile("<a[^>]*>(.*?)</a>",
				Pattern.CASE_INSENSITIVE | Pattern.CANON_EQ);
		Matcher urlMatcher = urlPattern.matcher(documentation);
		StringBuffer urlSb = new StringBuffer();
		while (urlMatcher.find()) {
			MatchResult mr = urlMatcher.toMatchResult();
			String match = documentation.substring(mr.start(), mr.end()); // e.g
																			// "Modelica://Modelica.UsersGuide.Overview"
			Pattern refP = Pattern.compile("href=\"(.+?)\"",
					Pattern.CASE_INSENSITIVE | Pattern.CANON_EQ);
			Matcher refM = refP.matcher(match);
			if (refM.find()) {
				MatchResult refMr = refM.toMatchResult();
				String ref = match.substring(
						refMr.start() + "href=\"".length(), refMr.end() - 1);
				// remove modelica://, if present
				if (ref.toLowerCase().startsWith("modelica://")) {
					ref = ref.substring("modelica://".length());
				}
				if (ref.toLowerCase().startsWith(libName.toLowerCase())) {
					String relativePath = findRelativePath(path, ref); // path
																		// is
																		// the
																		// modelica
																		// path
																		// of
																		// the
																		// cd,
																		// ref
																		// is
																		// the
																		// modelica
																		// path
																		// of
																		// the
																		// link
					// match = match.replaceAll("href=\"(.+?)\"",
					// "href=\"file://" + rootPath + ref.replace(".","/" ) +
					// "/index.html\"");
					match = match.replaceAll("href=\"(.+?)\"", "href=\""
							+ relativePath + "index.html\"");

					urlMatcher.appendReplacement(urlSb, match);
				} else {
					if (ref.toLowerCase().startsWith("modelica://")) {
						urlMatcher.appendReplacement(urlSb,
								ref.substring("modelica://".length()));
					} else {
						urlMatcher.appendReplacement(urlSb, ref);
					}
				}
			}
		}
		urlMatcher.appendTail(urlSb);
		// img handling
		String imgRegex = "<img[^>]+src\\s*=\\s*['\"]([^'\"]+)['\"][^>]*>";
		Pattern imgPattern = Pattern.compile(imgRegex);// ,
														// Pattern.CASE_INSENSITIVE
														// | Pattern.CANON_EQ);
		Matcher imgMatcher = imgPattern.matcher(urlSb.toString());
		StringBuffer imgSb = new StringBuffer();
		while (imgMatcher.find()) {
			MatchResult mr = imgMatcher.toMatchResult();
			String match = urlSb.toString().substring(mr.start(), mr.end()); // e.g
																				// "Modelica://Modelica.UsersGuide.Overview"
			Pattern refP = Pattern.compile("src=\"(.+?)\"",
					Pattern.CASE_INSENSITIVE | Pattern.CANON_EQ);
			Matcher refM = refP.matcher(match);
			if (refM.find()) {
				MatchResult refMr = refM.toMatchResult();
				String ref = match.substring(refMr.start() + "src=\"".length(),
						refMr.end() - 1);
				// remove modelica://, if present
				if (ref.toLowerCase().startsWith("modelica://")) {
					ref = ref.substring("modelica://".length());
				}
				String fileName;
				ref = ref.replace("\\", "/");
				if (ref.lastIndexOf("/") != -1) {
					fileName = ref.substring(ref.lastIndexOf("/") + 1);
				} else {
					fileName = ref;
				}
				String relativePath = path.replace(".", "/") + "/" + fileName;
				copyFile(ref, rootPath + relativePath);
				// create relative path in the offline docs.
				imgMatcher.appendReplacement(imgSb, "<img src=\"" + fileName
						+ "\" \\>");
			}
		}
		imgMatcher.appendTail(imgSb);

		return imgSb.toString();
	}

	/**
	 * Given two Modelica links, returns a string that describes the directory
	 * navigation required to go from 'from' to 'to'
	 * 
	 * Exampel: from = Modelica.Analog.Electrical.Resistor to =
	 * Modelica.Analog.Inductive.Capacitance return =
	 * ../../Inductive/Capacitance
	 * 
	 * @param from
	 *            The source
	 * @param to
	 *            The destination
	 * @return the relative path from source to destination
	 */
	public static String findRelativePath(String from, String to) {
		String[] fromArray = from.split("\\.");
		String[] toArray = to.split("\\.");
		int fromDepth = fromArray.length;
		int toDepth = toArray.length;
		int commonDepth = 0;
		for (int i = 0; i < Math.min(fromArray.length, toArray.length); i++) {
			if (fromArray[i].equals(toArray[i])) {
				commonDepth++;
			} else {
				break;
			}
		}
		StringBuilder relPath = new StringBuilder();
		int up = fromDepth - commonDepth;
		for (int i = 0; i < up; i++) {
			relPath.append("../");
		}
		int down = toDepth - commonDepth;
		for (int i = 0; i < down; i++) {
			relPath.append(toArray[i + commonDepth] + "/");
		}
		return relPath.toString();
	}

	/**
	 * Renders a class declaration. This includes appending a head,
	 * breadcrumbar, header, title, body content and footer. The body may,
	 * depending on what type of class it is, contain properties such as classes
	 * contained in a package, equations, components, extensions revision
	 * information etc. Called when the users ask for a new class declaration to
	 * be rendered by pressing a link or navigating in the browser history.
	 * 
	 * @param fcd
	 *            The class declaration to be rendered
	 */
	public static String renderClassDecl(ClassDecl fcd, SourceRoot sourceRoot,
			String tinymcePath, String classCodeSourcePath) {
		StringBuilder content = new StringBuilder();
		content = new StringBuilder();
		content.append(Generator.genHead());
		content.append(Generator.genJavaScript(tinymcePath, false));
		content.append(Generator.genHeader());
		content.append(Generator.genBreadCrumBar(fcd, sourceRoot.getProgram()));
		if (fcd instanceof UnknownClassDecl) {
			content.append(Generator
					.genUnknownClassDecl((UnknownClassDecl) fcd));
		} else if (fcd instanceof FullClassDecl) {
			content.append(renderFullClassDecl((FullClassDecl) fcd, sourceRoot,
					classCodeSourcePath));
		} else if (fcd instanceof ShortClassDecl) {
			content.append(Generator.genShortClassDecl((ShortClassDecl) fcd));
		}
		content.append(Generator.genFooter(FOOTER));
		return content.toString();
	}

	/**
	 * Appends HTML code that's specific to the ClassDecl subclass
	 * FullClassDecl. This includes: title, info, imports, extensions, classes,
	 * components, equations, revision This does NOT include: head
	 * (initialization, css and javascript), header (document header), breadcrum
	 * bar which are found in all ClassDecl.
	 * 
	 * @param fcd
	 */
	private static String renderFullClassDecl(FullClassDecl fcd,
			SourceRoot sourceRoot, String classCodeSourcePath) {
		StringBuilder content = new StringBuilder();
		content.append(Generator.genTitle(fcd, classCodeSourcePath, false));
		content.append(Generator.genComment(fcd));
		content.append(Generator.genInfo(fcd, false, sourceRoot, false));
		content.append(Generator.genImports(fcd));
		content.append(Generator.genExtensions(fcd));
		content.append(Generator.genClasses(fcd));
		content.append(Generator.genComponents(fcd));
		content.append(Generator.genEquations(fcd));
		content.append(Generator.genRevisions(fcd, false, sourceRoot, false));
		return content.toString();
	}

	/**
	 * Does the following: Collect the wizard information (inclusions and path).
	 * Generates documentation for the full class declaration Recursively
	 * generates documentation for all the classes in the full class
	 * declaration. Called when the user presses 'finish' in the wizard.
	 */
	public static boolean genDocWizardPerformFinish(FullClassDecl fcd,
			String rootPath, SourceRoot sourceRoot,
			HashMap<String, Boolean> checkBoxes) {
		ArrayList<ClassDecl> children = new ArrayList<ClassDecl>();
		String path = rootPath + fcd.getName().getID();
		String libName = fcd.getName().getID();
		if (!(new File(path)).exists()) {
			if (!(new File(path)).mkdirs()) {
				System.err
						.println("Unable to create a new directory. Aborting documentation save...");
				return true;
			}
		}
		collectChildren(fcd, children);

		String code = Generator.genDocumentation(fcd, sourceRoot, path + "\\",
				FOOTER, "Unknown Class Decl", rootPath, libName, checkBoxes);
		try {
			FileWriter fstream = new FileWriter(path + "\\index.html");
			BufferedWriter out = new BufferedWriter(fstream);
			out.write(code);
			out.close();
		} catch (Exception ex) {
			System.err.println("Unable to save to file");
		}
		for (ClassDecl cd : children) {
			String newPath = rootPath + "/"
					+ Generator.getFullPath(cd).replace(".", "/");
			(new File(newPath)).mkdirs();
			try {
				FileWriter fstream = new FileWriter(newPath + "\\index.html");
				BufferedWriter out = new BufferedWriter(fstream);
				out.write(Generator.genDocumentation(cd, sourceRoot, newPath
						+ "/", FOOTER, "Unknown class decl", rootPath, libName,
						checkBoxes));
				out.close();
			} catch (Exception ex) {
				System.err.println("Unable to save to file");
			}
		}
		return true;
	}

	/**
	 * Saves all the classes found in the full class declaration fcd into
	 * children
	 * 
	 * @param fcd
	 * @param children
	 */
	private static void collectChildren(FullClassDecl fcd,
			ArrayList<ClassDecl> children) {
		if (fcd.classes() == null || fcd.classes().size() == 0)
			return;
		for (ClassDecl child : fcd.classes()) {
			if (!children.contains(child)) {
				children.add(child);
				if (child instanceof FullClassDecl) {
					collectChildren((FullClassDecl) child, children);
				}
			}
		}
	}
}