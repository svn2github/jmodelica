package org.jmodelica.ide.documentation;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.regex.MatchResult;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import org.eclipse.core.runtime.SafeRunner;
import org.eclipse.swt.browser.Browser;
import org.eclipse.swt.browser.LocationEvent;
import org.eclipse.swt.browser.LocationListener;
import org.eclipse.swt.browser.TitleEvent;
import org.eclipse.swt.browser.TitleListener;
import org.eclipse.swt.events.MouseEvent;
import org.eclipse.swt.events.MouseListener;
import org.jmodelica.ide.documentation.commands.NavigationProvider;
import org.jmodelica.modelica.compiler.AbstractEquation;
import org.jmodelica.modelica.compiler.Access;
import org.jmodelica.modelica.compiler.Algorithm;
import org.jmodelica.modelica.compiler.ClassDecl;
import org.jmodelica.modelica.compiler.Comment;
import org.jmodelica.modelica.compiler.ComponentDecl;
import org.jmodelica.modelica.compiler.ConstrainingClause;
import org.jmodelica.modelica.compiler.Encapsulated;
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
import org.jmodelica.modelica.compiler.StringLitExp;
import org.jmodelica.modelica.compiler.TypePrefixFlow;
import org.jmodelica.modelica.compiler.UnknownClassDecl;
import org.jmodelica.modelica.compiler.VisibilityType;

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
	private static final String SAVE_SCRIPT =
			"var area = document.getElementsByTagName('TEXTAREA')[0];"+
			"var y = document.createElement('P');"+
			"var z = area.parentNode;"+
			"var tmp = area.value;"+
			"y.innerHTML = area.value;"+
			"z.insertBefore(y,area);"+
			"z.removeChild(area);"+
			"z.removeChild(document.getElementsByTagName('button')[0]);"+
			"editing = false;"+
			"document.title = \"\";"+
			"return tmp;";
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
	
	public BrowserContent(FullClassDecl fullClassDecl, Browser browser, InstClassDecl icd, Program program, NavigationProvider navProv){
		this.navProv = navProv;
		this.program = program;
		String path = this.getClass().getProtectionDomain().getCodeSource().getLocation() + this.getClass().getResource("/resources/script.js").getPath();
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
		browser.addTitleListener(this);
		renderClassDecl(hyperlinks.get(fullClassDecl.name()));
	}

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
	
	private void renderClassDecl(ClassDecl fcd){
		content = new StringBuilder(head);
		genBreadCrumBar(fcd);
		genHeader();
		genFooter();

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
		content.append("<span class=\"text\">Error: The class <b>" + history.get(histIndex) + "</b> could not be found."+
										" To get the latest version of the Modelica standard library, please visit " +
										"<a href=\"https://www.modelica.org/libraries/Modelica\">https://www.modelica.org/libraries/Modelica</a></span>");
		browser.setText(content.toString());

	}

	public String processEmbeddedHTML(String htmlCode){
		String urlPrefix = "a href=";
		Pattern urlPattern = Pattern.compile(urlPrefix + "\"(.+)\"", Pattern.CASE_INSENSITIVE | Pattern.CANON_EQ);
		Matcher urlMatcher = urlPattern.matcher(htmlCode);
		StringBuffer urlSb = new StringBuffer();
		while (urlMatcher.find()){
			//append hoover text
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
		
		String code = urlSb.toString();
		String imPrefix = "img src=";
		Pattern imgPattern = Pattern.compile(imPrefix + "\"(.+)\"", Pattern.CASE_INSENSITIVE | Pattern.CANON_EQ);
		Matcher imgMatcher = imgPattern.matcher(code);
		StringBuffer imgSb = new StringBuffer();
		while(imgMatcher.find()){
			MatchResult mr = imgMatcher.toMatchResult();
			String match = code.substring(mr.start() + imPrefix.length(), mr.end());
			imgMatcher.appendReplacement(imgSb, code.substring(mr.start(), mr.end()) + " title=" + match);
		}
		imgMatcher.appendTail(imgSb);
		
		return imgSb.toString();
	}
	
	public void saveNewDocumentationAnnotation(String newVal){
		ClassDecl fcd = hyperlinks.get(history.get(histIndex));
		StringLitExp exp = new StringLitExp(newVal);
		fcd.annotation().forPath("Documentation/info").setValue(exp);
		SaveSafeRunnable ssr = new SaveSafeRunnable(fcd);
		SafeRunner.run(ssr);
//		try {
//			definition.getFile().setContents(new ByteArrayInputStream(s.getBytes()), false, true, null);
//		} catch (CoreException e) {
//			e.printStackTrace();
//		}
	}
	
	private void renderPackage(FullClassDecl fcd){
		content.append("<h1>" + fcd.getRestriction() + " " + fcd.getName().getID() + "</h1>");
		if(fcd.hasStringComment()){
			content.append("<div class=\"text\"><i>" + fcd.stringComment() + "</i></div>");
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
				"<td><b><span class=\"text\">Class</span></b></td>" + 
				"<td><b><span class=\"text\">Type</span></b></td>" +
				"<td><b><span class=\"text\">Description</span></b></td></b></tr>");
		for (ClassDecl cd : fcds){
			content.append("<tr>");
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
				comment = cd.stringComment();
			}

			content.append("<td>" + classDeclLink(cd, false) + "</td>" + 
					"<td><span class=\"text\">" + classCategory + "</span></td>" + "<td><span class=\"text\">" + comment + "&nbsp;" + "</span></td>");
			content.append("</tr>");
		}
		content.append("</table>");
		browser.setText(content.toString());
	}

	private void renderFullClassDecl(FullClassDecl fcd){
		String name = fcd.getName().getID();
		content.append("<h1>" + fcd.getRestriction() + " " + name + "</h1>");
		if(fcd.hasStringComment()){
			content.append("<div class=\"text\"><i>" + fcd.stringComment() + "</i></div>");
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
		if (bcd == null) return; //link that didnt fall under any existing category and therefore is assumed its a classDecl
								// even if it isnt.
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
		//TODO header
	}
	
	public void genFooter(){
		//TODO footer
	}

	private String stripAbout(String location){
		return location.contains(":") ? location.substring(location.lastIndexOf(":")+1) : location;
	}

	public boolean forward(){
		histIndex++;
		String location = history.get(histIndex);
		renderLink(location);
		//renderClassDecl(hyperlinks.get(location));
		return histSize > histIndex;
	}
	
	public boolean back(){
		histIndex--;
		String location = history.get(histIndex);
		renderLink(location);
		return histIndex > 0;
	}

	public void renderLink(String link){
		navProv.setBackEnabled(histIndex > 0 ? true : false);
		navProv.setForwardEnabled(histSize > histIndex ? true : false);
		if (link.startsWith("//www")){
			renderHTTP(link);
		}else{
			String s = link.startsWith("//Modelica") ? link.substring("//".length(), link.length()-1) : link;
			renderClassDecl(hyperlinks.get(s));
		}
//		}else if (link.startsWith("//Modelica")){
//			renderModelica(link);
//		}else{
//			renderClassDecl(hyperlinks.get(link));
//		}
	}
	
	public void renderHTTP(String url){
		//String content = browser.gettext();
		//browser.setUrl(url);
		//browser.setText("rendered http");
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

		String location = stripAbout(event.location).replace("/", "");

		if (location.equals("blank")) return;
		histIndex++;
		if (histIndex >= history.size()){
			history.add(location);
		}else{
			history.set(histIndex, location);
		}
		histSize = histIndex;
		renderLink(location);
	}

//	public boolean save(ClassDecl cd){
//		StoredDefinition definition = cd.getDefinition();
//		String s = definition.prettyPrintFormatted();
//		try {
//			definition.getFile().setContents(new ByteArrayInputStream(s.getBytes()), false, true, null);
//		} catch (CoreException e) {
//			// TODO Auto-generated catch block
//			e.printStackTrace();
//		}
//
//		SafeRunner.run(new SafeRunnable() {
//			public void run() throws Exception {
//				StoredDefinition definition = cd.getDefinition();
//				
//				definition.getFile().setContents(new ByteArrayInputStream(definition.prettyPrintFormatted().getBytes()), false, true, null);
//			}
//		});
//		return true;
//	}
	
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

	@Override
	public void changed(TitleEvent event) {
		if (((String)browser.evaluate("return document.title")).equals("dynamicChange")){
			String s = (String)browser.evaluate(SAVE_SCRIPT);
			browser.evaluate("document.title = \"\"");
			saveNewDocumentationAnnotation("<p>" + s + "</p>");
		}
	}
}
