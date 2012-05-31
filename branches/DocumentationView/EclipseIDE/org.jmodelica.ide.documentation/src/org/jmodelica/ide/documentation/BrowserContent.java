package org.jmodelica.ide.documentation;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Stack;

import org.eclipse.swt.browser.Browser;
import org.eclipse.swt.browser.LocationEvent;
import org.eclipse.swt.browser.LocationListener;
import org.jmodelica.modelica.compiler.AbstractEquation;
import org.jmodelica.modelica.compiler.Access;
import org.jmodelica.modelica.compiler.Algorithm;
import org.jmodelica.modelica.compiler.Annotation;
import org.jmodelica.modelica.compiler.AnnotationNode;
import org.jmodelica.modelica.compiler.CMAnnotationNode;
import org.jmodelica.modelica.compiler.ClassDecl;
import org.jmodelica.modelica.compiler.ClassModification;
import org.jmodelica.modelica.compiler.Comment;
import org.jmodelica.modelica.compiler.ComponentDecl;
import org.jmodelica.modelica.compiler.ConstrainingClause;
import org.jmodelica.modelica.compiler.Dot;
import org.jmodelica.modelica.compiler.Encapsulated;
import org.jmodelica.modelica.compiler.ExtendsClause;
import org.jmodelica.modelica.compiler.ExtendsClauseShortClass;
import org.jmodelica.modelica.compiler.ExternalClause;
import org.jmodelica.modelica.compiler.Final;
import org.jmodelica.modelica.compiler.FullClassDecl;
import org.jmodelica.modelica.compiler.IdDecl;
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

public class BrowserContent implements LocationListener{

	private StringBuilder content;
	private Browser browser;
	private HashMap<String, ClassDecl> hyperlinks;
	private ArrayList<String> history;
	private int histIndex;
	private Stack<String> breadCrumBar;
	private int histSize;
	private InstClassDecl icd;
	private static final String FORWARD = "f";
	private static final String BACK = "b";
	private static final String HTMLHeader =
					"<head><style type=\"text/css\">body{background-color:#fffffa;}" +
					"h1{font-family:\"Arial\";color:black;text-align:center;}" +
					"h2{margin-left:20;color:black;text-align:left}" +
					"p{margin-left:20;font-family:\"Times New Roman\";font-size:16px;}" +
					"</style></head><body>";

	
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
	public BrowserContent(FullClassDecl fullClassDecl, Browser browser, InstClassDecl icd){
		this.icd = icd; //unused
		hyperlinks = new HashMap<String, ClassDecl>();
		history = new ArrayList<String>();
		histIndex = 0;
		histSize = 0;
		hyperlinks.put(fullClassDecl.name(), fullClassDecl);
		history.add(fullClassDecl.name());
		this.browser = browser;
		browser.addLocationListener(this);
		renderClassDecl(hyperlinks.get(fullClassDecl.name()));
	}
	
	private void renderClassDecl(ClassDecl fcd){
		
		content = new StringBuilder(HTMLHeader);
		if(histIndex > 0){
			content.append("<h2><a href=\"" + BACK + "\"><</a>");
		}else{
			content.append("<h2>");
		}
		if (histSize > histIndex){
			content.append(" <a href=\"" + FORWARD + "\">></a></h2>");
		}else{
			content.append("</h2>");
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
	
	private void renderPackage(FullClassDecl fcd){
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
				
				content.append("<p><a href=\"" + c.name() + "\">" + c.name() + "</a>" + comment + "</p>");
			}else if (cd instanceof ShortClassDecl){
				ShortClassDecl scd = (ShortClassDecl) cd;
				hyperlinks.put(scd.name(), scd);
				content.append("<p><a href=\"" + scd.name() + "\">" + scd.name() + "</a></p>");
			}

		}
		browser.setText(content.toString());
	}
	
	private void renderFullClassDecl(FullClassDecl fcd){
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
			content.append(fcd.stringComment() + "<br>");
			Opt<StringComment> opt = fcd.getStringCommentOpt();
		}
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

			content.append("<a href=\"" + extension.name() + "\">" + ec.getSuper().name() + "</a>"); 
		}
		if (fcd.getNumSuper() == 0){
			content.append("None</p>");
		}
		//COMPONENTS
		if (fcd.getNumComponentDecl() > 0){
			content.append("<h3> Components</h3><p><table border=\"1\" cellpadding=\"5\">" +
					"<tr align=\"center\"><td><b>Type</b></td><td><b>Name</b></td><td><b>Description</b></td></tr>");
			for (int i=0;i<fcd.getNumComponentDecl();i++){
				content.append("<tr>");
				ComponentDecl cd = fcd.getComponentDecl(i);
				String stringComment = "None";
				if (cd.getComment().hasStringComment()){
					stringComment = cd.getComment().getStringComment().stringComment();
					stringComment = cd.getComment().getStringComment().getComment();
				}
//				if (cd.getName().getID().equals("greaterEqual")){
//					ClassDecl x = cd.findClassDecl();
//					boolean unknown = x instanceof UnknownClassDecl;
//					if (unknown){
//						UnknownClassDecl y = (UnknownClassDecl) x;
//						InstClassDecl icd3 = icd.lookupInstClassDotted(cd.getName().getID());
//					}
//				}
				content.append("<td>" + componentLink(cd) + "</td><td>" + cd.getName().getID() + "</td><td>" + stringComment + "</td>");

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
		content.append("<h3> Equations</h3><p>");
		for (int i=0;i<fcd.getNumEquation();i++) {
			AbstractEquation ae = fcd.getEquation(i);
			content.append(ae + "<br>");
		}
		if (fcd.getNumEquation() == 0){
			content.append("None");
		}
		content.append("</p>");
		//annotation
		AnnotationNode annotationNode = fcd.annotation();
		AnnotationNode annotationNodeHTML = annotationNode.forPath("html");
		String annotationNodeHTMLString = annotationNodeHTML.string() == null ? "None" : annotationNodeHTML.string();
		content.append("<h3>HTML annotation</h3><p>" + annotationNodeHTMLString + "</p>");
		//link style: code.append("<a href=\"Modelica://MultiBody.Tutorial\">MultiBody.Tutorial</a>");
		browser.setText(content.toString());
	}
	
	private void renderShortClassDecl(ShortClassDecl scd){
		content.append("<h1>" + scd.getRestriction() + " " + scd.name() + "</h1>");
		content.append(scd.prettyPrint(""));
		browser.setText(content.toString());
	}

	public String componentLink(ComponentDecl cd){
		hyperlinks.put(cd.getClassName().name(), cd.findClassDecl());
		return "<a href=\"" + cd.getClassName().name() + "\">" + cd.getClassName().name() + "</a>"; 
		//		if (cd.findClassDecl() instanceof FullClassDecl){
		//			hyperlinkMap.put(cd.getClassName().name(), (FullClassDecl) cd.findClassDecl());
		//			return "<a href=\"" + cd.getClassName().name() + "\">" + cd.getClassName().name() + "</a>"; 
		//		}else if (cd.findClassDecl() instanceof ShortClassDecl){
		//			scdHyperlinkMap.put(cd.getClassName().name(), (ShortClassDecl) cd.findClassDecl());
		//			ShortClassDecl scd = (ShortClassDecl) cd.findClassDecl();
		//			ExtendsClauseShortClass ecsc = scd.getExtendsClauseShortClass();
		//			return cd.getClassName().name()+ " (ShortClassDecl)" + scd.prettyPrint("");
		//		}else{
		//			return cd.getClassName().name() + ": neither full or short";
		//		}
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
			location = history.get(histIndex-1);
			histIndex--;
		}else if (location.equals(FORWARD)){
			histIndex++;
			location = history.get(histIndex);


		}else{
			histIndex++;
			if (histIndex >= history.size()){ //double buffer
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
}
