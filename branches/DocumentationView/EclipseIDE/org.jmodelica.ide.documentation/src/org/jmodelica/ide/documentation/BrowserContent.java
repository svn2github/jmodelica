package org.jmodelica.ide.documentation;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedList;
import java.util.Map;

import org.eclipse.swt.browser.Browser;
import org.eclipse.swt.browser.LocationEvent;
import org.eclipse.swt.browser.LocationListener;
import org.eclipse.swt.events.MouseEvent;
import org.eclipse.swt.events.MouseListener;
import org.eclipse.ui.AbstractSourceProvider;
import org.eclipse.ui.ISources;
import org.eclipse.ui.services.ISourceProviderService;
import org.jmodelica.ide.documentation.commands.NavigationProvider;
import org.jmodelica.modelica.compiler.AbstractEquation;
import org.jmodelica.modelica.compiler.Access;
import org.jmodelica.modelica.compiler.Algorithm;
import org.jmodelica.modelica.compiler.AnnotationNode;
import org.jmodelica.modelica.compiler.BaseClassDecl;
import org.jmodelica.modelica.compiler.ClassDecl;
import org.jmodelica.modelica.compiler.Comment;
import org.jmodelica.modelica.compiler.ComponentDecl;
import org.jmodelica.modelica.compiler.ConstrainingClause;
import org.jmodelica.modelica.compiler.Encapsulated;
import org.jmodelica.modelica.compiler.ExtendsClause;
import org.jmodelica.modelica.compiler.ExternalClause;
import org.jmodelica.modelica.compiler.Final;
import org.jmodelica.modelica.compiler.FullClassDecl;
import org.jmodelica.modelica.compiler.ImportClause;
import org.jmodelica.modelica.compiler.Inner;
import org.jmodelica.modelica.compiler.InstClassDecl;
import org.jmodelica.modelica.compiler.List;
import org.jmodelica.modelica.compiler.Modification;
import org.jmodelica.modelica.compiler.Opt;
import org.jmodelica.modelica.compiler.Outer;
import org.jmodelica.modelica.compiler.Partial;
import org.jmodelica.modelica.compiler.Program;
import org.jmodelica.modelica.compiler.Redeclare;
import org.jmodelica.modelica.compiler.Replaceable;
import org.jmodelica.modelica.compiler.ShortClassDecl;
import org.jmodelica.modelica.compiler.StringComment;
import org.jmodelica.modelica.compiler.TypePrefixFlow;
import org.jmodelica.modelica.compiler.UnknownClassDecl;
import org.jmodelica.modelica.compiler.VisibilityType;

public class BrowserContent implements LocationListener, MouseListener{

	private StringBuilder content;
	private Browser browser;
	private HashMap<String, ClassDecl> hyperlinks;
	private ArrayList<String> history;
	private int histIndex;
	private int histSize;
	private InstClassDecl icd;
	private static final String FORWARD = "f";
	private static final String BACK = "b";
	private static final String PRIMITIVE_TYPE = "primitive type";
	private String head;
	private Program program;
	private boolean forwardEnabled, backEnabled;
	private NavigationProvider navProv;
	private void genHead(String scriptPath){
		head = "<head><style type=\"text/css\">body{background-color:#fffffa;}" +
				"h1{margin-left:20;font-family:\"Arial\";color:black;font-size:32px;}" +
				"h2{margin-left:20;color:black;text-align:left;font-size:24px;}" +
				"h3{margin-left:20;color:black;text-align:left;font-size:20px;font-style=\"bold\";}" +
				"span{font-family:Georgia, \"Times New Roman\", Times, serif;font-size:18px;}" +
				"span.text {}" +
				"span.code {font-family:Monospace, \"Courier New\", Times, serif;}" +
				"div{margin-left:20; font-family:Georgia, \"Times New Roman\", Times, serif;font-size:18px;}" +
				"div.text {}" +
				"div.code {font-family:Monospace, \"Courier New\", Times, serif;}" +
				"a {font-family:Georgia, \"Times New Roman\", Times, serif;font-size:18px;cursor: auto}" +
				"a:link {color:blue;}" +
				"a:visited {color: #660066;}" +
				"a:hover {text-decoration: none;}" +
				"a:active {text-decoration: none}" +
				"p{margin-top:10; margin-bottom:10;margin-left:20;font-family:Georgia, \"Times New Roman\", Times, serif;font-size:18px;}" +
				"</style><script type=\"text/javascript\" src=\"" + scriptPath + "\"></script>" +
				"</head><body>";
	}
	private static final String EDIT_SCRIPT = 
			"var editing  = false;" +

	"if (document.getElementById && document.createElement) {"+
	"var butt = document.createElement('BUTTON');"+
	"var buttext = document.createTextNode('Ready!');"+
	"butt.appendChild(buttext);"+
	"butt.onclick = saveEdit;"+
	"}"+

	"function catchIt(e) {"+
	"if (editing) return;"+
	"	if (!document.getElementById || !document.createElement) return;"+
	"	if (!e) var obj = window.event.srcElement;"+
	"	else var obj = e.target;"+
	"	while (obj.nodeType != 1) {"+
	"		obj = obj.parentNode;"+
	"	}"+
	"	if (obj.tagName == 'TEXTAREA' || obj.tagName == 'A') return;"+
	"	while (obj.nodeName != 'P' && obj.nodeName != 'HTML') {"+
	"		obj = obj.parentNode;"+
	"	}"+
	"	if (obj.nodeName == 'HTML') return;"+
	"	var x = obj.innerHTML;"+
	"	var y = document.createElement('TEXTAREA');"+
	"	var z = obj.parentNode;"+
	"	z.insertBefore(y,obj);"+
	"	z.insertBefore(butt,obj);"+
	"	z.removeChild(obj);"+
	"	y.value = x;"+
	"	y.focus();"+
	"	editing = true;"+
	"}"+
	"function saveEdit() {"+
	"	var area = document.getElementsByTagName('TEXTAREA')[0];"+
	"	var y = document.createElement('P');"+
	"	var z = area.parentNode;"+
	"	y.innerHTML = area.value;"+
	"	z.insertBefore(y,area);"+
	"	z.removeChild(area);"+
	"	z.removeChild(document.getElementsByTagName('button')[0]);"+
	"	editing = false;"+
	"}"+
	"document.onclick = catchIt;";

	/*
	 * 
	 * abstract BaseClassDecl : ClassDecl ::= VisibilityType 
									   [Encapsulated] 
	                                   [Partial] 
	                                   Restriction 
	                                   Name:IdDecl  
                                       [Redeclare]
	                                   [Final]
	                                   [Inner]
	                                   [Outer]
	                                   [Replaceable]
	                                   [ConstrainingClause]
                                       [ConstrainingClauseComment:Comment];
	 */

	/*
	 * FullClassDecl : BaseClassDecl ::= [StringComment]  
                                  Equation:AbstractEquation* 
                                  Algorithm*
                                  Super:ExtendsClause*  
                                  Import:ImportClause* 
                                  ClassDecl* 
                                  ComponentDecl*
                                  Annotation* 
                                  [ExternalClause] 
                                  EndDecl;
	 */
	public BrowserContent(FullClassDecl fullClassDecl, Browser browser, InstClassDecl icd, Program program, NavigationProvider navProv){
		this.navProv = navProv;
		this.program = program;
		this.icd = icd; //unused
		String path = this.getClass().getProtectionDomain().getCodeSource().getLocation() + this.getClass().getResource("/resources/script.js").getPath();
		//		URL url2 = this.getClass().getProtectionDomain().getCodeSource().getLocation();
		//		URL url = this.getClass().getResource("/resources/script.js");
		//		String urlPath = url.getPath();
		//		String t = url2 + urlPath;
		genHead(path);
		hyperlinks = new HashMap<String, ClassDecl>();
		history = new ArrayList<String>();
		histIndex = 0;
		histSize = 0;
		hyperlinks.put(fullClassDecl.name(), fullClassDecl);
		history.add(fullClassDecl.name());
		this.browser = browser;
		browser.addLocationListener(this);
		browser.addMouseListener(this);
		renderClassDecl(hyperlinks.get(fullClassDecl.name()));
	}

	private void renderClassDecl(ClassDecl fcd){
		content = new StringBuilder(head);
		genBreadCrumBar(fcd);
		genHeader();
		genFooter();
		if(histIndex > 0){
			navProv.setBackEnabled(true);
		}else{
			navProv.setBackEnabled(false);
		}
		if (histSize > histIndex){
			navProv.setForwardEnabled(true);
		}else{
			navProv.setForwardEnabled(false);
		}
		if (fcd instanceof UnknownClassDecl){
			renderUnknownClassDecl((UnknownClassDecl)fcd);
			return;
		}
		if (fcd instanceof FullClassDecl){
			FullClassDecl fcd2 = (FullClassDecl) fcd;
			if (fcd2.getRestriction().getNodeName().equals("MPackage")){
				renderPackage(fcd2);
			}else{
				renderFullClassDecl((FullClassDecl) fcd);
			}
			return;
		}
		if (fcd instanceof ShortClassDecl){
			renderShortClassDecl((ShortClassDecl) fcd);
			return;
		}

	}

	private void renderUnknownClassDecl(UnknownClassDecl fcd) {
		content.append("<span class=\"text\">Error: unknown class declaration</span>");
		browser.setText(content.toString());

	}

	public String processEmbeddedHTML(String htmlCode){
		return htmlCode; //TODO replace links, remove <html> etc.
		//also parse in full-path-on-hoover for all links!
	}
	private void renderPackage(FullClassDecl fcd){
		content.append("<h1>" + fcd.getRestriction() + " " + fcd.getName().getID() + "</h1>");
		if(fcd.hasStringComment()){
			content.append("<div class=\"text\"><i>" + fcd.stringComment() + "</i></div>");
			Opt<StringComment> opt = fcd.getStringCommentOpt();
		}
		//ANNOTATION
		String embeddedHTML = fcd.annotation().forPath("Documentation/info").string();
		if (embeddedHTML != null){
			content.append("<h2>Information</h2>");
			content.append(processEmbeddedHTML(embeddedHTML));
		}
		content.append("<h2>Containing Classes</h2>");
		ArrayList<ClassDecl> fcds = fcd.classes();
		content.append("<table BORDER=\"3\" CELLPADDING=\"3\" CELLSPACING=\"0\" >" +
				"<tr BGCOLOR=\"#CCCCFF\" align=\"center\">" + 
				"<td><b><span class=\"text\">Class</span></b></td><td><b><span class=\"text\">Type</span></b></td><td><b><span class=\"text\">Description</span></b></td></b></tr>");
		for (ClassDecl cd : fcds){
			content.append("<tr>");
			hyperlinks.put(cd.name(), cd);
			String name = cd.name();
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
				comment = cd.stringComment();
			}

			content.append("<td><a href=\"" + cd.name() + "\" title = \"" + cd.name() + "\">" + cd.name() + "</a></td>" + 
					"<td><span class=\"text\">" + classCategory + "</span></td>" + "<td><span class=\"text\">" + comment + "&nbsp;" + "</span></td>");
			content.append("</tr>");
		}
		content.append("</table>");
		browser.setText(content.toString());
	}

	private void renderFullClassDecl(FullClassDecl fcd){
		Redeclare rd;
		if(fcd.hasRedeclare()){
			rd = fcd.getRedeclare();
		}
		List<Algorithm> al = fcd.getAlgorithmList();
		List<ClassDecl> classDecls = fcd.getClassDeclList();
		if (fcd.hasExternalClause()){
			ExternalClause ec = fcd.getExternalClause();
			System.out.println("");
		}
		if (fcd.hasEncapsulated()){
			Encapsulated e = fcd.getEncapsulated();
		}
		if (fcd.hasReplaceable()){
			Replaceable r = fcd.getReplaceable();
		}
		if (fcd.hasPartial()){
			Partial p = fcd.getPartial();
		}
		String name = fcd.getName().getID();
		content.append("<h1>" + fcd.getRestriction() + " " + name + "</h1>");
		if(fcd.hasStringComment()){
			content.append("<div class=\"text\"><i>" + fcd.stringComment() + "</i></div>");
			Opt<StringComment> opt = fcd.getStringCommentOpt();
		}

		//ANNOTATION
		String embeddedHTML = fcd.annotation().forPath("Documentation/info").string();
		if (embeddedHTML != null){
			content.append("<h2>Information</h2>");
			content.append(processEmbeddedHTML(embeddedHTML));
		}
		//IMPORTS
		if (fcd.getNumImport() > 0){
			content.append("<h2>Imports</h2>");
			for (int i = 0; i < fcd.getNumImport(); i++){
				ImportClause ic = fcd.getImport(i);
				ic.findClassDecl();
				content.append("<div class=\"text\">" + classDeclLink(ic.findClassDecl(), true) + "</div>");
			}
		}
		//EXTENSIONS
		if (fcd.getNumSuper() > 0){
			content.append("<h2>Extends</h2>");
			for (int i=0; i < fcd.getNumSuper(); i++) {
				content.append("<div class=\"text\">" + classDeclLink(fcd.getSuper(i).findClassDecl(), true) + "</div>");
			}
		}

		//COMPONENTS
		if (fcd.getNumComponentDecl() > 0){
			content.append("<h2> Components</h2><table BORDER=\"3\" CELLPADDING=\"3\" CELLSPACING=\"0\" >" +
					"<tr BGCOLOR=\"#CCCCFF\" align=\"center\">" + 
					"<td><b><span class=\"text\">Type</span></b></td><td><b><span class=\"text\">Name</span></b></td><td><b><span class=\"text\">Description</span></b></td></b></tr>");
			for (int i=0;i<fcd.getNumComponentDecl();i++){
				content.append("<tr>");
				ComponentDecl cd = fcd.getComponentDecl(i);
				String stringComment = "&nbsp;"; //without the html whitespace the cell isn't drawn properly, tmp fix
				if (cd.getComment().hasStringComment()){
					stringComment = cd.getComment().getStringComment().stringComment();
					stringComment = cd.getComment().getStringComment().getComment();
				}
				Access a = cd.getClassName();
				String s = a.name(); //correct path
				ClassDecl cdd = cd.findClassDecl();
				if (cdd.isUnknown()){//just print its name without a hyperlink
					content.append("<td>" + "<span class=\"text\">" + s + "</span></td><td><span class=\"text\">" + cd.getName().getID() + "</span></td><td><span class=\"text\">" + stringComment + "</span></td>");
				}else{
					content.append("<td>" + classDeclLink(cdd, false) + "</td><td><span class=\"text\">" + cd.getName().getID() + "</span></td><td><span class=\"text\">" + stringComment + "</span></td>");
				}

				VisibilityType vt = cd.getVisibilityType();
				Comment c1 = cd.getCCComment();
				Comment c2 = cd.getComment();
				Modification m;
				ConstrainingClause cc;
				if (cd.hasRedeclare()){
					Redeclare r = cd.getRedeclare();
				}
				if (cd.hasFinal()){
					Final f = cd.getFinal();
				}
				if (cd.hasInner()){
					Inner in = cd.getInner();
				}
				if (cd.hasOuter()){
					Outer o = cd.getOuter();
				}
				if (cd.hasReplaceable()){
					Replaceable r = cd.getReplaceable();
				}
				if (cd.hasTypePrefixFlow()){
					TypePrefixFlow  tpf = cd.getTypePrefixFlow();
				}

				if (cd.hasModification()){
					m = cd.getModification();
				}
				if (cd.hasConstrainingClause()){
					cc = cd.getConstrainingClause();
				}
				content.append("</tr>");
			}
			content.append("</table>");
		}

		//EQUATIONS

		if (fcd.getNumEquation() > 0){
			content.append("<h2> Equations</h2>");
			for (int i=0;i<fcd.getNumEquation();i++) {
				AbstractEquation ae = fcd.getEquation(i);
				content.append("<div class=\"code\"> " + ae + "</div>");
			}
		}
		//link style: code.append("<a href=\"Modelica://MultiBody.Tutorial\">MultiBody.Tutorial</a>");
		browser.setText(content.toString());
	}

	private void renderShortClassDecl(ShortClassDecl scd){
		content.append("<h1>" + scd.getRestriction() + " " + scd.name() + "</h1>");
		content.append("<div class=\"code\">" + scd.prettyPrint("") + "</div>" + " (<span class=\"text\"><i>This is a ShortClassDecl, currently just prettyPrinting it.</i>)</span>");
		browser.setText(content.toString());
	}

	public String classDeclLink(ClassDecl bcd, boolean printFullPath){
		String fullPath = getFullPath(bcd);
		hyperlinks.put(fullPath, bcd);
		String visiblePath = printFullPath ? fullPath : bcd.name();
		return "<a href=\"" + fullPath + "\" title = \"" + fullPath + "\">" + visiblePath + "</a>";
	}

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
	private void genBreadCrumBar(ClassDecl bcd) {
		StringBuilder sb = new StringBuilder();
		ClassDecl tmp = bcd;
		ArrayList<String> path = new ArrayList<String>();
		String name2 = bcd.name();
		do{
			path.add(tmp.name());
			tmp = tmp.enclosingClassDecl();

		}while(tmp != null && !name2.equals(tmp.name()));
		for (int i = path.size() - 1; i >= 0; i--){
			sb.append(path.get(i));
			if (i == 0) {//dont add link to self
				content.append("<span class=\"text\">" + program.simpleLookupClassDotted(sb.toString()).name() + "</span>");
			}else{
				content.append(classDeclLink(program.simpleLookupClassDotted(sb.toString()), false));
			}
			if (i != 0){
				sb.append(".");
				content.append(".");
			}
		}
		content.append("<br><hr>");
	}

	public void genHeader(){
		//TODO ?
	}
	public void genFooter(){
		//TODO ?
	}

	private String stripAbout(String location){
		return location.contains(":") ? location.substring(location.lastIndexOf(":")+1) : location;
	}

	@Override
	public void changing(LocationEvent event) {
		String location = stripAbout(event.location);
		if (!location.equals(history.get(histIndex))){
			event.doit = true;
		}else{
			event.doit = false;
		}
	}

	public boolean forward(){
		histIndex++;
		String location = history.get(histIndex);
		renderClassDecl(hyperlinks.get(location));
		return histSize > histIndex;
	}
	public boolean back(){
		histIndex--;
		String location = history.get(histIndex);
		renderClassDecl(hyperlinks.get(location));
		return histIndex > 0;
	}

	@Override
	public void changed(LocationEvent event) {

		String location = stripAbout(event.location);

		if (location.equals("blank")) return;
		if (location.startsWith("http://")){
			//TODO: just render the website, not the class decl. Update history though
		}
		histIndex++;
		if (histIndex >= history.size()){
			history.add(location);
		}else{
			history.set(histIndex, location);
		}
		histSize = histIndex;
		renderClassDecl(hyperlinks.get(location));
	}

	@Override
	public String toString(){
		return content.toString();
	}

	@Override
	public void mouseDoubleClick(MouseEvent e) {
		// TODO Auto-generated method stub

	}

	@Override
	public void mouseDown(MouseEvent e) {
		//TODO 
	}

	@Override
	public void mouseUp(MouseEvent e) {
		// TODO Auto-generated method stub

	}
}
