package org.jmodelica.ide.documentation;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedList;

import org.eclipse.swt.browser.Browser;
import org.eclipse.swt.browser.LocationEvent;
import org.eclipse.swt.browser.LocationListener;
import org.eclipse.swt.events.MouseEvent;
import org.eclipse.swt.events.MouseListener;
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
	private String head;
	private Program program;
	private void genHead(String scriptPath){
		head = "<head><style type=\"text/css\">body{background-color:#fffffa;}" +
				"h1{font-family:\"Arial\";color:black;text-align:center;}" +
				"h2{margin-left:20;color:black;text-align:left}" +
				"a {font-family:Georgia, \"Times New Roman\", Times, serif;font-size:18px;cursor: auto}" +
//				"a:link {color:blue;}" +
//				"a:visited {color: #660066;}" +
//				"a:hover {text-decoration: none; color: #ff9900; font-weight:bold;}" +
//				"a:active {color: #ff0000;text-decoration: none}" +
				"p{margin-top:10; margin-bottom:10;margin-left:20;font-family:\"Times New Roman\";font-size:18px;}" +
				"span{id=\"text\"; font-family:Georgia, \"Times New Roman\", Times, serif;font-size:18px;}" +
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
	public BrowserContent(FullClassDecl fullClassDecl, Browser browser, InstClassDecl icd, Program program){
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
		if(histIndex > 0){
			content.append("<h2><a href=\"" + BACK + "\">< </a>");
		}else{
			content.append("<h2>");
		}
		if (histSize > histIndex){
			content.append(" <a href=\"" + FORWARD + "\">></a></h2>");
		}else{
			content.append("</h2>");
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
		content.append("<p>Error: unknown class declaration</p>");
		browser.setText(content.toString());
		
	}

	private void renderPackage(FullClassDecl fcd){
		genBreadCrumBar(fcd);
		content.append("<h1>" + fcd.getRestriction() + " " + fcd.getName().getID() + "</h1><h2>Containing Classes</h2>");
		ArrayList<ClassDecl> fcds = fcd.classes();
		for (ClassDecl cd : fcds){
			if (cd instanceof FullClassDecl){

				FullClassDecl c = (FullClassDecl) cd;
				hyperlinks.put(c.name(), c);
				
				String comment = "";
				if(c.hasStringComment()){
					comment = " - " + c.stringComment();
				}
				
				content.append("<p><a href=\"" + c.name() + "\" title = \"" + c.name() + "\">" + c.name() + "</a>" + comment + "</p>");
			}else if (cd instanceof ShortClassDecl){
				ShortClassDecl scd = (ShortClassDecl) cd;
				hyperlinks.put(scd.name(), scd);
				content.append("<p><a href=\"" + scd.name() + "\" title = \"" + scd.name() + "\">" + scd.name() + "</a></p>");
			}

		}
		browser.setText(content.toString());
	}
	
	private void renderFullClassDecl(FullClassDecl fcd){
		genBreadCrumBar((BaseClassDecl)fcd);
		Redeclare rd;
		if(fcd.hasRedeclare()){
			rd = fcd.getRedeclare();
			System.out.println("");
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
			content.append("<p>" + fcd.stringComment() + "</p>");
			Opt<StringComment> opt = fcd.getStringCommentOpt();
		}
		
		//ANNOTATION
		AnnotationNode annotationNode = fcd.annotation();
		AnnotationNode annotationNodeHTML = annotationNode.forPath("html");
		String annotationNodeHTMLString = annotationNodeHTML.string() == null ? "<p><i>No HTML annotation available</i></p>" : annotationNodeHTML.string();
		content.append(annotationNodeHTMLString);
		//IMPORTS
		content.append("<h3>Imports</h3><p>");
		for (int i = 0; i < fcd.getNumImport(); i++){
			ImportClause ic = fcd.getImport(i);
			content.append(ic.toString());
			for (int j = 0; j < ic.getNumChild(); j++){
				if (ic.getChild(i).toString().length() > 0){
					content.append(ic.getChild(j) + "<br>");
				}
			}

		}
		if (fcd.getNumImport() == 0){
			content.append("None</p>");
		}
		//EXTENSIONS
		content.append("<h3>Extensions</h3><p>");
		for (int i=0; i < fcd.getNumSuper(); i++) {
			ExtendsClause ec = fcd.getSuper(i);
			VisibilityType vt = ec.getVisibilityType();
			Access a = ec.getSuper();
			FullClassDecl extension = (FullClassDecl) ec.findClassDecl();
			hyperlinks.put(extension.name(), extension);

			content.append("<a href=\"" + extension.name() + "\" title = \"" + extension.name() + "\">" + ec.getSuper().name() + "</a>"); 
		}
		if (fcd.getNumSuper() == 0){
			content.append("None");
		}
		content.append("</p>");
		//COMPONENTS
		if (fcd.getNumComponentDecl() > 0){
			content.append("<h3> Components</h3><table border=\"1\" cellpadding=\"5\">" +
					"<tr align=\"center\"><td><b>Type</b></td><td><b>Name</b></td><td><b>Description</b></td></tr>");
			for (int i=0;i<fcd.getNumComponentDecl();i++){
				content.append("<tr>");
				ComponentDecl cd = fcd.getComponentDecl(i);
				String stringComment = "None";
				if (cd.getComment().hasStringComment()){
					stringComment = cd.getComment().getStringComment().stringComment();
					stringComment = cd.getComment().getStringComment().getComment();
				}
				content.append("<td>" + componentLink(cd) + "</td><td>" + cd.getName().getID() + "</td><td><p>" + stringComment + "</p></td>");

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
		}else{
			content.append("None");
		}

		//EQUATIONS
		content.append("<h3> Equations</h3>");
		for (int i=0;i<fcd.getNumEquation();i++) {
			AbstractEquation ae = fcd.getEquation(i);
			content.append("<p><code>" + ae + "</code></p>");
		}
		if (fcd.getNumEquation() == 0){
			content.append("None");
		}
		//link style: code.append("<a href=\"Modelica://MultiBody.Tutorial\">MultiBody.Tutorial</a>");
		browser.setText(content.toString());
	}

	private void renderShortClassDecl(ShortClassDecl scd){
		genBreadCrumBar(scd);
		content.append("<h1>" + scd.getRestriction() + " " + scd.name() + "</h1>");
		content.append("<code>" + scd.prettyPrint("") + "</code>" + ". (<i>This is a ShortClassDecl, currently just prettyPrinting it.</i>)");
		browser.setText(content.toString());
	}

	public String componentLink(ComponentDecl cd){
		hyperlinks.put(cd.getClassName().name(), cd.findClassDecl());
		String s = cd.getClassName().name();
		String name = s.contains(".") ? s.substring(s.lastIndexOf(".") + 1, s.length()) : s;
		
		return "<a href=\"" + cd.getClassName().name() + "\" title = \"" + cd.getClassName().name() + "\">" + name + "</a>"; 
	}
	
	public String classDeclLink(ClassDecl bcd, String path){
		hyperlinks.put(path, bcd);
		return "<a href=\"" + path + "\" title = \"" + path + "\">" + bcd.name() + "</a>";
	}

	private void genBreadCrumBar(BaseClassDecl bcd) {
		StringBuilder sb = new StringBuilder();
		BaseClassDecl tmp = bcd;
		ArrayList<String> path = new ArrayList<String>();
		String name2 = bcd.name();
		do{
			path.add(tmp.name());
			tmp = tmp.enclosingClassDecl();
			
		}while(tmp != null && !name2.equals(tmp.name()));
		for (int i = path.size() - 1; i >= 0; i--){
			sb.append(path.get(i));
			if (i == 0) {//dont add link to self
				content.append("<span id=\"text\">" + program.simpleLookupClassDotted(sb.toString()).name() + "</span>");
			}else{
				content.append(classDeclLink(program.simpleLookupClassDotted(sb.toString()), sb.toString()));
			}
			if (i != 0){
				sb.append(".");
				content.append(".");
			}
		}
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

	@Override
	public void changed(LocationEvent event) {

		String location = stripAbout(event.location);
		if (location.equals("blank")) return;
		if (location.equals(BACK)){
			histIndex--;
			location = history.get(histIndex);
		}else if (location.equals(FORWARD)){
			histIndex++;
			location = history.get(histIndex);
		}else{
			histIndex++;
			if (histIndex >= history.size()){
				history.add(location);
			}else{
				history.set(histIndex, location);
			}
			histSize = histIndex;
		}
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
		
	}

	@Override
	public void mouseUp(MouseEvent e) {
		// TODO Auto-generated method stub
		
	}
}
