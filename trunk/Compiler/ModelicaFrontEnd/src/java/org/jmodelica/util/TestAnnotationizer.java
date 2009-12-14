package org.jmodelica.util;

import java.io.BufferedReader;
import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileReader;
import java.io.InputStreamReader;
import java.io.PrintStream;
import java.io.StringReader;
import java.lang.reflect.Constructor;
import org.jmodelica.modelica.compiler.*;

abstract public class TestAnnotationizer {

	public static void main(String[] args) throws Exception {
		if (args.length == 0) 
			usageError(1);
		
		String filePath = args[0];
		String testType = null;
		String className = getPackageName(filePath);
		String description = "";
		String data = null;
		boolean write = false;
		
		for (int i = 1; i < args.length; i++) {
			String arg = (args[i].length() > 3) ? args[i].substring(3) : "";
			if (args[i].startsWith("-t=")) 
				testType = arg;
			else if (args[i].startsWith("-c=")) 
				className = composeClassName(className, arg);
			else if (args[i].startsWith("-d=")) 
				data = arg;
			else if (args[i].equals("-w")) 
				write = true;
			else if (args[i].equals("-h")) 
				usageError(0);
			else if (args[i].startsWith("-")) 
				System.err.println("Unrecognized option: " + args[i] + "\nUse -h for help.");
			else
				description += " " + args[i];
		}
		description = description.trim();
		
		BufferedReader in = new BufferedReader(new InputStreamReader(System.in));
		if (!className.contains(".")) {
			System.out.print("Enter class name: ");
			System.out.flush();
			className = composeClassName(className, in.readLine().trim());
		}
		if (testType == null) {
			System.out.print("Enter type of test: ");
			System.out.flush();
			testType = in.readLine().trim();			
		}
		
		for (Class cl : TestAnnotationizer.class.getClasses()) {
			if (cl.getSimpleName().equals(testType)) {
				Constructor constructor = cl.getConstructor(String.class, String.class, String.class, String.class);
				TestAnnotationizer ta = (TestAnnotationizer) constructor.newInstance(filePath, className, description, data);
				if (write)
					ta.writeAnnotation();
				else
					ta.printAnnotation();
				System.exit(0);
			}
		}
		
		System.out.println("Test type " + testType + " not found.");
	}

	private static String composeClassName(String extracted, String entered) {
		if (entered.contains("."))
			return entered;
		else
			return extracted + "." + entered;
	}

	private static void usageError(int errorLevel) throws Exception {
		System.out.println("Usage: java TestAnnotationizer <.mo file path> [options...] [<description>]");
		System.out.println("  Options:");
		System.out.println("    -w           write result to file instead of stdout");
		System.out.println("    -t=<type>    set type of test, e.g. CCodeGenTestCase");
		System.out.println("    -c=<class>   set name of class to generate annotation for, if name ");
		System.out.println("                 does not contain a dot, base name of .mo file is prepended");
		System.out.println("    -d=<data>    set extra data to send to the specific generator");
		System.out.println("    -h           print this help");
		System.out.println("  User will be prompted for type and/or class if not set with options.");
		System.out.println("  Available test types:");
		for (Class cl : TestAnnotationizer.class.getClasses()) 
			cl.getMethod("usage", String.class, String.class).invoke(null, cl.getSimpleName(), null);
		System.exit(errorLevel);
	}
	
	public static void usage(String cl, String extra) {
		System.out.print("    " + cl);
		if (extra != null && !extra.equals(""))
			System.out.print(",  data = " + extra);
		System.out.println();
	}

	private static String getPackageName(String filePath) {
		String[] parts = filePath.split(File.separator);
		return parts[parts.length - 1].split("\\.")[0];
	}

	protected String filePath;
	protected String className;
	protected String testName;
	protected String description;
	protected ModelicaCompiler mc;
	protected SourceRoot root;
	
	public TestAnnotationizer(String filePath, String className, String description, String data) throws Exception {
		this.filePath = filePath;
		this.className = className;
		this.description = description;
		testName = className.substring(className.lastIndexOf('.') + 1);
		
		String filesep = File.separator;
		String optionsfile = System.getenv("JMODELICA_HOME")+filesep+"Options"+filesep+"options.xml";
		OptionRegistry or = new OptionRegistry(optionsfile);
		String modelicapath = System.getenv("JMODELICA_HOME")+filesep+"ThirdParty"+filesep+"MSL";
		or.setStringOption("MODELICAPATH", modelicapath);
		ModelicaCompiler.setLogLevel("JModelica.ModelicaCompiler", ModelicaCompiler.WARNING);
		mc = new ModelicaCompiler(or, null, null, null);
		root = mc.parseModel(new String[] { filePath });
	}

	public void printAnnotation() throws Exception {
		System.out.println("Annotation:\n=====================");
		outputAnnotation(System.out);
		System.out.println("\n=====================");		
	}

	public void writeAnnotation() throws Exception {
		File old = new File(filePath);
		BufferedReader in = new BufferedReader(new FileReader(old));
        File altered = File.createTempFile(className, ".mo");
        PrintStream out = new PrintStream(altered);
        for (int i = 0, n = getLine(); i < n; i++)
        	out.println(in.readLine());
		outputAnnotation(out);
		for (String line = in.readLine(); line != null; line = in.readLine())
			out.println(line);
		out.close();
		if (!altered.renameTo(old)) {
			in = new BufferedReader(new FileReader(altered));
	        out = new PrintStream(old);
			for (String line = in.readLine(); line != null; line = in.readLine())
				out.println(line);
			altered.delete();
		}
		System.out.println("File " + old.getName() + " updated.");
	}

	public void outputAnnotation(PrintStream out) throws Exception {
		out.println(" annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={");
		out.println("     JModelica.UnitTesting." + getClass().getSimpleName() + "(");
		out.println("         name=\"" + testName + "\",");
		out.println("         description=\"" + description + "\",");
		printSpecific(out, "         ");
		out.println(")})));\n");
	}
	
	protected int getLine() throws Exception {
		return root.getProgram().getInstProgramRoot().simpleLookupInstClassDecl(className).beginLine();
	}

	protected FClass compile() throws Exception {
		InstClassDecl icl = instantiate();		
	    FClass fc = flatten(icl);
	    fc.transformCanonical();
	    return fc;
	}

	protected FClass flatten(InstClassDecl icl) {
		FlatRoot flatRoot = new FlatRoot();
	    flatRoot.setFileName(filePath);
	    FClass fc = new FClass();
	    flatRoot.setFClass(fc);
		flatRoot.options = new OptionRegistry(icl.root().options);
		icl.flattenInstClassDecl(fc);
		return fc;
	}

	protected InstClassDecl instantiate() {
		InstProgramRoot ipr = root.getProgram().getInstProgramRoot();
		ipr.options = new OptionRegistry(root.options);
		InstClassDecl icl = ipr.simpleLookupInstClassDecl(className);
		return icl;
	}

	abstract protected void printSpecific(PrintStream out, String indent) throws Exception;

	public static class CCodeGenTestCase extends TestAnnotationizer {

		private String template;
		private String code;

		public CCodeGenTestCase(String filePath, String className, String description, String data) throws Exception {
			super(filePath, className, description, data);
			template = data.replaceAll("\\\\n", "\n");
			FClass fc = compile();
			CGenerator cgenerator = new CGenerator(new PrettyPrinter(), '$', fc);
			ByteArrayOutputStream os = new ByteArrayOutputStream();
			cgenerator.generate(new StringReader(template), new PrintStream(os));
			code = os.toString();
		}
		
		public static void usage(String cl, String extra) {
			TestAnnotationizer.usage(cl, "C code template");
		}

		@Override
		protected void printSpecific(PrintStream out, String indent) throws Exception {
			out.print(indent + "template=\"\n" + template);
			out.print("\n\",\n" + indent + "generatedCode=\"\n" + code);
			out.print("\"");
		}
		
	}

	public static class FlatteningTestCase extends TestAnnotationizer {
		
		protected FClass fc;

		public FlatteningTestCase(String filePath, String className, String description, String data) throws Exception {
			super(filePath, className, description, data);
			fc = flatten(instantiate());
		}

		@Override
		protected void printSpecific(PrintStream out, String indent) throws Exception {
			out.println(indent + "flatModel=\"");
			fc.prettyPrint(out, "");
			out.print("\"");
		}
		
	}

	public static class TransformCanonicalTestCase extends FlatteningTestCase {

		public TransformCanonicalTestCase(String filePath, String className, String description, String data) throws Exception {
			super(filePath, className, description, data);
			fc.transformCanonical();
		}
		
	}

	public static class ErrorTestCase extends TestAnnotationizer {

		private String message;

		public ErrorTestCase(String filePath, String className, String description, String data) throws Exception {
			super(filePath, className, description, data);
			try {
				mc.instantiateModel(root, className);
			} catch (CompilerException e) {
				StringBuffer str = new StringBuffer();
				str.append(e.getProblems().size() + " errors found:\n");
				for (Problem p : e.getProblems()) {
					str.append(p.toString()+"\n");
				}
				message = str.toString();
			}
		}

		@Override
		protected void printSpecific(PrintStream out, String indent) throws Exception {
			out.print(indent + "errorMessage=\"\n" + message + "\"");
		}

	}

}
