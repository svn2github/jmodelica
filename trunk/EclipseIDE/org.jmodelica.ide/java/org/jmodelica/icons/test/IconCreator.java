package org.jmodelica.icons.test;
//
//import java.io.FileNotFoundException;
//import java.io.IOException;
//import java.net.URL;
//import java.util.ArrayList;
//
//import javax.xml.parsers.ParserConfigurationException;
//import javax.xml.xpath.XPathExpressionException;
//
//import org.eclipse.core.runtime.FileLocator;
//import org.eclipse.core.runtime.IPath;
//import org.eclipse.core.runtime.Path;
//import org.eclipse.ui.IEditorPart;
//import org.eclipse.ui.IWorkbenchPage;
//import org.eclipse.ui.IWorkbenchWindow;
//import org.eclipse.ui.PlatformUI;
//import org.jmodelica.icons.ComponentConstructor;
//import org.jmodelica.icons.IconCompiler;
//import org.jmodelica.icons.exceptions.FailedConstructionException;
//import org.jmodelica.icons.exceptions.NotEnoughParametersException;
//import org.jmodelica.icons.msl.ClassIcon;
//import org.jmodelica.ide.Activator;
//import org.jmodelica.ide.IDEConstants;
//import org.jmodelica.ide.editor.Editor;
//import org.jmodelica.modelica.compiler.AnnotationNode;
//import org.jmodelica.modelica.compiler.BaseClassDecl;
//import org.jmodelica.modelica.compiler.ClassDecl;
//import org.jmodelica.modelica.compiler.ComponentDecl;
//import org.jmodelica.modelica.compiler.Connector;
//import org.jmodelica.modelica.compiler.ExtendsClause;
//import org.jmodelica.modelica.compiler.InstBaseClassDecl;
//import org.jmodelica.modelica.compiler.InstClassDecl;
//import org.jmodelica.modelica.compiler.InstComponentDecl;
//import org.jmodelica.modelica.compiler.InstExtends;
//import org.jmodelica.modelica.compiler.InstRestriction;
//import org.jmodelica.modelica.compiler.MType;
//import org.jmodelica.modelica.compiler.Program;
//import org.jmodelica.util.OptionRegistry;
//import org.xml.sax.SAXException;
//
//public abstract class IconCreator {
//	
//	/**
//	 * Used for finding the full name of a Modelica class.
//	 */
//	private static String MSL_PATH = "../JModelica/ThirdParty/MSL/";
//	
//	//private static final String options_filename = "c:/tmp/options.xml";
//	private static final String options_filename = "resources/options.xml";
//	//private static final String options_filename = "./Resources/options.xml";
//	//private static final String options_filename = IDEConstants.DEF_OPTIONS_URL;
//	private static final String cTpl_filename = "./Resources/jmi_modelica_template.c";
//	private static final String xmlTpl_filename = "./Resources/jmodelica_model_description.tpl";
//	private static final String xmlValuesTpl_filename = "./Resources/jmodelica_model_values.tpl";
//	
//	private static IconCompiler compiler;
//	private static Program program;
//	
//	private static final String rootStr = "../JModelica/ThirdParty/MSL/Modelica";
//	
//	static {
//		compiler = null;
////		URL url = FileLocator.find(Activator.getDefault().getBundle(), new Path(options_filename), null);
////		System.out.println("url = " + url);
////		System.out.println("toExternalForm = " + url.toExternalForm());
//		String mslRootStr = "";
//		String optionsStr = "";
//		if (Activator.getDefault().getBundle() != null) {
//			URL optionsUrl = Activator.getDefault().getBundle().getEntry(options_filename);
//			try {
//				optionsUrl = FileLocator.resolve(optionsUrl);
//			} catch (IOException e) {}
//			optionsStr = optionsUrl.getFile();
//			
//			URL mslRootUrl = Activator.getDefault().getBundle().getEntry(rootStr);
//			try {
//				mslRootUrl = FileLocator.resolve(mslRootUrl);
//			} catch (IOException e) {}
//			mslRootStr = mslRootUrl.getFile();
//		} else {
//			mslRootStr = rootStr;
//			optionsStr = options_filename;
//		}
//		
//		try {
//			compiler = new IconCompiler(
//					false,
//					new OptionRegistry(optionsStr),
//					cTpl_filename, 
//					xmlTpl_filename, 
//					xmlValuesTpl_filename, 
//					ModelicaFileFinder.getFiles(mslRootStr)
//			);
//		} catch (FileNotFoundException e) {
//			e.printStackTrace();
//		} catch (IOException e) {
//			e.printStackTrace();
//		} catch (XPathExpressionException e) {
//			e.printStackTrace();
//		} catch (ParserConfigurationException e) {
//			e.printStackTrace();
//		} catch (SAXException e) {
//			e.printStackTrace();
//		} catch (FailedConstructionException e) {
//			e.printStackTrace();
//		}
//		program = compiler.getProgram();
//	}
//	
//	
//	
//	 public static ClassIcon createIcon(ClassDecl classDecl) 
//		throws NotEnoughParametersException, FailedConstructionException {
//		 ClassIcon icon = null;
//			 
//		 AnnotationNode annotation = classDecl.annotation();
//		 if (annotation == AnnotationNode.NO_ANNOTATION) {
////			 System.out.println("NullAnnotationNode hittad. ");
////			 System.out.println("Namn: " + classDecl.qualifiedName());
////			 System.out.println("Klass: " + classDecl.getClass().getName());
//			 //throw new FailedConstructionException("Component");
//			 return ClassIcon.NULL_ICON;
//		 }
//		 icon = ComponentConstructor.construct(
//				 annotation, 
//				 classDecl.qualifiedName()
//		 );
//		 
//		 // Vi skippar detta tills vi får lookup-funktionerna att funka i pluginen:
//		 
//		 String fullClassName = getFullNameNoContext(classDecl);
//		 
//		 if (fullClassName != null) {
//			 
//			 // Find superclasses.
//			 for (ExtendsClause e : classDecl.superClasses()) {
//				 //String fullClassName = getFullName(classDecl);
//				 String superName = getFullName(e.getSuper().name(), fullClassName);
//				 if (superName != null) {		 
//					 if (!superName.equals(fullClassName)) {
//						 ClassDecl superClassDecl = lookup(superName);
//						 if (superClassDecl != null) {
//							 icon.addSupercomponent(createIcon(superClassDecl));
//						 } else {
//							 //System.out.println("Warning - superclass class not found: " + superName);
//						 }
//					 }
//				 }else {
//					 //System.out.println("Warning - superclass class not found: " + superName);
//				 }
//			 }
///*	
//			 // Find subcomponents.
//			 for (ComponentDecl cd : classDecl.components()) {
//				 String subName = cd.getClassName().name();
//				 AnnotationNode placementAnnotation = cd.annotation().forPath("Placement");
//				 // Ingen Placement-annotering --> vi skiter i den här komponenten.
//				 if (!placementAnnotation.equals(AnnotationNode.NO_ANNOTATION)) {
//					 String fullName = getFullName(subName, fullClassName);
//					 ClassDecl subClassDecl = lookup(fullName);
//					 if (subClassDecl != null && subClassDecl instanceof BaseClassDecl) {
//						 if (!(((BaseClassDecl)subClassDecl).getRestriction() instanceof MType)){
//							 ClassIcon subComp = createIcon(subClassDecl);
//							 subComp.setComponentName(cd.name());
//							 subComp.setClassName(subName);
//							 subComp.setIsProtected(
//									 cd.getVisibilityType().isProtected()
//							 );
//							 subComp.setPlacement(ComponentConstructor.constructPlacement(
//									 placementAnnotation)
//							 );	
//							 subComp.setIsConnector(
//									 ((BaseClassDecl)subClassDecl).getRestriction() instanceof Connector
//							 );
//							 icon.addSubcomponent(subComp);
//						 }
//					 } else {
//						 //System.out.println("Warning - subcomponent class not found: " + subName);
//					 }
//				 } else {
//					 //System.out.println("Warning - no Placement found for component " + subName);
//				 }
//			 }
//		 } else {
//			 // Hittar inte klassens fulla namn. Antingen finns den inte, eller så
//			 // finns det flera klasser med samma namn.
//			 //System.out.println("Unable to find full name of class: " + classDecl.name());
//*/		 }
//
//		 return icon;
//	}
//	 
//	 private static String getCurrentPath() {
//		 IWorkbenchWindow window = PlatformUI.getWorkbench().getActiveWorkbenchWindow();
//		 if (window != null) {
//		     IWorkbenchPage page = window.getActivePage();
//		     if (page != null) {
//		         IEditorPart editorPart = page.getActiveEditor();
//		         Editor editor = (Editor)editorPart;
//		         // Ger "Basic.mo":
//		         //return editor.getPartName();
//		         return editor.getTitleToolTip();
//		     }
//		 }
//		 return null;
//	 }
//	 
//	 private static ClassDecl lookupFile(String className) {
//		 for (ClassDecl decl : program.classes()) {
//			 String fullName = getFullName(decl);
//			 if (className.equals(fullName)) {
//				 return decl;
//			 }
//		 }
//		 while (className.contains(".")) {
//			 className = className.substring(0, className.lastIndexOf('.'));
//			 for (ClassDecl decl : program.classes()) {
//				 String fullName = getFullName(decl);
//				 if (fullName.equals(className)) {
//					 return decl;
//				 }
//			 }
//		 }
//		 return null;
//	 }
//	 
//	 public static ClassDecl lookup(String className) {
//		 if (className == null) {
//			 return null;
//		 }
//		 ClassDecl fileDecl = lookupFile(className);
//		 if (className.equals(getFullName(fileDecl))) {
//			 return fileDecl;
//		 }
//		 if (fileDecl == null) {
//			 return null;
//		 }
//		 ClassDecl decl = lookupClassInFile(className, fileDecl); 
//		 return decl;
//	 }
//	 
//	 private static ClassDecl lookupClassInFile(String className, ClassDecl file) {
//		 if (className.equals(getFullName(file))) {
//			 return file;
//		 }
//		 int lastDotIndex = className.indexOf('.', getFullName(file).length()+1);
//		 if (lastDotIndex == -1) {
//			 lastDotIndex = className.length();
//		 }
//		 String s = className.substring(0, lastDotIndex);
//		 for (ClassDecl decl : file.classes()) {
//			 if (s.equals(getFullName(decl))) {
//				 return lookupClassInFile(className, decl);
//			 }
//		 }
//		 return null;
//	 }
//	 
//	 private static String getFullName(ClassDecl decl) {
//		if (decl == null) {
//			return null;
//		}
//		String qName = decl.qualifiedName();
//		String dir = decl.dirName();
//		String s = decl.getFileName();
////		System.out.println("Classname = " + decl.getClass().getName());
////		System.out.println("dir = " + dir);
//		String fixedDir = dir.substring(MSL_PATH.length()).replace('\\', '.');
//		int lastDotIndex = fixedDir.lastIndexOf(".");
//		
//		// Pga. paket som heter samma sak som sin mapp:
//		// TODO: Kanske finns bättre metod än qualifiedName?
//		String lastNameInDir = fixedDir.substring(lastDotIndex+1);
//		int firstDotIndex = decl.qualifiedName().indexOf(".");
//		if (firstDotIndex == -1) {
//			firstDotIndex = decl.qualifiedName().length();
//		}
//		String firstName = decl.qualifiedName().substring(0, firstDotIndex);
//		if (lastNameInDir.equals(firstName)) {
//			String name = decl.qualifiedName().substring(
//					firstName.length(), 
//					decl.qualifiedName().length()
//			);
//			return fixedDir.concat(name);
//		}
//		return fixedDir.concat(".").concat(decl.qualifiedName());
//	 }
//	 
//	private static String getMainClassName(String fileName) {
//		 if (fileName == null) {
//			 return null;
//		 }
//		 String className = fileName;
//		 className = className.substring(className.indexOf("\\Modelica")+1);
//		 className = className.substring(0, className.lastIndexOf('.'));
//		 if (fileName.endsWith("package.mo")) {
//			 className = className.substring(0, className.lastIndexOf('\\')); 
//		 }
//		 return className.replace('\\', '.');
//	}
//	 
//	 public static String getFullNameInCurrentDoc(ClassDecl decl) {
//		 if (decl == null) {
//			 return null;
//		 }
//		 String currentPath = getCurrentPath();
//		 if (currentPath == null) {
//			 return null;
//		 }
//		 String fullName = currentPath;
//		 fullName = fullName.substring(fullName.indexOf("\\Modelica")+1);
//		 fullName = fullName.substring(0, fullName.lastIndexOf('\\'));
//		 fullName = fullName.replace('\\', '.'); 
//		 if (currentPath.endsWith("package.mo")) {
//			 return fullName;
//		 }
//		 return	fullName.concat(".").concat(decl.qualifiedName());
//	 }
//	 
//	 public static String getFullNameNoContext(ClassDecl decl) {
//		 ArrayList<String> candidates = getFullNameCandidates(decl);
//		 if (candidates.size() == 1) {
//			 return candidates.get(0);
//		 }
//		 return null;
//	 }
//	 
//	 public static ArrayList<String> getFullNameCandidates(ClassDecl decl) {
//		 ArrayList<String> candidates = new ArrayList<String>();
//		 String name = decl.name();
//		 for (ClassDecl c : program.classes()) {
//			 if (c.name().equals(name)) {
//				 candidates.add(getFullName(c));
//			 }
//			 candidates.addAll(getFullNameCandidates(decl, c));
//		 }
//		 return candidates;
//	 }
//	 
//	 private static ArrayList<String> getFullNameCandidates(ClassDecl decl, ClassDecl pack) {
//		 ArrayList<String> candidates = new ArrayList<String>();
//		 String name = decl.name();
//		 for (ClassDecl c : pack.classes()) {
//			 if (c.name().equals(name)) {
//				 candidates.add(getFullName(c));
//			 }
//			 candidates.addAll(getFullNameCandidates(decl, c));
//		 }		 
//		 return candidates;
//	 }
//
//	 private static String getFullName(String className, String context) {
//		 String fullName; 
//		 while (context.contains(".")) {
//			 context = context.substring(0, context.lastIndexOf("."));
//			 fullName = context.concat(".").concat(className);
//			 ClassDecl decl = lookup(fullName);
//			 if (decl != null) {
//				 return fullName;
//			 }
//		 }
//		 
//		 fullName = className;
//		 if (lookup(fullName) != null) {
//			 return fullName;
//		 }
//		 
//		 return null;
//	 }
//	 
//	 public static ClassIcon createIcon(InstClassDecl inst) 
//		throws FailedConstructionException, NotEnoughParametersException {
////	 System.out.println("createComponent. inst = " + inst.qualifiedName() + 
////			 ", annotation() = " + inst.annotation().toString());
//	 
//		 ClassIcon component;
//		 AnnotationNode annotation = inst.annotation();
//		 if (annotation == AnnotationNode.NO_ANNOTATION) {
//			 //System.out.println("NullAnnotationNode hittad. ");
//			 //System.out.println("Namn: " + inst.qualifiedName());
//			 //System.out.println("Klass: " + inst.getClass().getName());
//			 //throw new FailedConstructionException("Component");
//			 return ClassIcon.NULL_ICON;
//		 }
//		 component = ComponentConstructor.construct(
//				 annotation, 
//				 inst.qualifiedName()
//		 );
////		 component.setClassName(inst.qualifiedName());
//		 
//		 // Find superclasses.
//		 for (InstExtends ie : inst.instExtends()) {
//			 /*String baseClassName = inst.name();
//			 String superClassName = ie.myInstClass().name();
//			 System.out.println(baseClassName + " ärver " + superClassName);*/
//			 component.addSupercomponent(
//					createIcon(
//							ie.myInstClass()
//					) 
//			 );
//		 }
//
//		 // Find subcomponents.
//		 for (InstComponentDecl cd : inst.instComponentDecls()) {
//			 if (cd.myInstClass() instanceof InstBaseClassDecl) {
//				 AnnotationNode placementAnnotation = cd.annotation().forPath("Placement");
//				 if (placementAnnotation != AnnotationNode.NO_ANNOTATION) {
//					 InstBaseClassDecl compClassDecl = (InstBaseClassDecl)cd.myInstClass();
//					 InstRestriction restriction = compClassDecl.getInstRestriction();
//					 boolean isConnector = restriction.isConnector();
//					 boolean isFunction = restriction.isFunction();
//					 if (isConnector || isFunction) {
//						 ClassIcon subComp = createIcon(compClassDecl);
//						 //AnnotationNode placementAnnotation = cd.annotation();
//						 //System.out.println(placementAnnotation.name());
///*						 subComp.setComponentName(cd.name());
//						 subComp.setIsProtected(
//								 cd.getComponentDecl().getVisibilityType().isProtected()
//						 );
//						 subComp.setPlacement(ComponentConstructor.constructPlacement(
//								 placementAnnotation)
//						 );
//						 subComp.setIsConnector(compClassDecl.getInstRestriction().isConnector());
//*/						 component.addSubcomponent(subComp);
//					 }
//				 }
//			 }
//		 }
//		 
//		 //System.out.println("Created icon for: " + component.getClassName());
//		 
//		 return component;
//	}
//	 
//	 public static IconCompiler getCompiler() {
//		 return compiler;
//	 }
//
//}
