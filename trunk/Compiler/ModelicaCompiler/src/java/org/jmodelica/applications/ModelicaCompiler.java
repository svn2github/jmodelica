/*
    Copyright (C) 2009 Modelon AB

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, version 3 of the License.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

package org.jmodelica.applications;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.io.Reader;
import java.util.Collection;
import java.util.logging.ConsoleHandler;
import java.util.logging.Level;
import java.util.logging.LogRecord;
import java.util.logging.Logger;
import java.util.logging.SimpleFormatter;

import org.jmodelica.ast.FClass;
import org.jmodelica.ast.FlatRoot;
import org.jmodelica.ast.InstNode;
import org.jmodelica.ast.InstProgramRoot;
import org.jmodelica.ast.PrettyPrinter;
import org.jmodelica.ast.SourceRoot;
import org.jmodelica.ast.StoredDefinition;
import org.jmodelica.codegen.CGenerator;
import org.jmodelica.codegen.XMLGenerator;
import org.jmodelica.parser.ModelicaParser;
import org.jmodelica.parser.ModelicaScanner;
import org.jmodelica.ast.Problem;
import org.jmodelica.ast.CompilerException;
import org.jmodelica.ast.ModelicaClassNotFoundException;

import beaver.Parser.Exception;

/**
 * 
 * Main compiler class which bundles the tasks needed to compile a Modelica model.
 * 
 *  There are two usages with this class:
 *  1. Compile in one step with command line arguments using this class only.
 *  2. Split compilation into several steps by calling the static methods in your own class/module.
 *  
 *  Use (1) for a simple and compact way of compiling a Modelica model. As a minimum, provide 
 *  the modelfile name and class name as command line arguments. Optional arguments are XML 
 *  template and c template files which are needed for code generation. If any of these are 
 *  ommitted no code generation will be performed.
 *  
 *  Example without code generation: 
 *  org.jmodelica.applications.ModelicaCompiler myModels/models.mo models.model1
 *  
 *  Example with code generation:
 *  org.jmodelica.applications.ModelicaCompiler myModels/models.mo models.model1 templates/XMLtemplate.xml templates/cppTemplate.cpp
 *  
 *  Logging can be set with the optional argument -i, -w or -e where:
 *  
 *  -i : log info, warning and error messages
 *	-w : log warning and error messages
 *  -e : log error messages only (default if the log option is not used)
 *  
 *  Example with log level set to INFO:
 *  org.jmodelica.applications.ModelicaCompiler -i myModels/models.mo models.model1
 *  
 *  The logs will be printed to standard out.
 *  
 *  
 *  For method (2), the compilation steps are divided into 4 tasks which can be used via the methods:
 *  1. parseModel (source code -> attributed source representation)
 *  2. instantiateModel (source representation -> instance model)
 *  3. flattenModel (instance model -> flattened model)
 *  4. generateCode (flattened model -> c code and XML code)
 *  
 *  They must be called in this order. Use provided methods to get/set logging level. 
 *  
 */
public class ModelicaCompiler {

//	private static final Logger logger = Logger.getLogger("JModelica.ModelicaCompiler");
	private static final Logger logger = ModelicaLoggers.getConsoleLogger("JModelica.ModelicaCompiler");
	public static final String INFO = "i";
	public static final String WARNING = "w";
	public static final String ERROR = "e";
	public static final String INHERITED = "inh";
	
	
	
	public static void main(String args[]) {
		if(args.length < 1) {
			logger.severe("ModelicaCompiler expects the command line arguments: [-i/w/e] <file name> <class name> [<xml template> <c template>]");
			System.exit(1);
		}
		int arg = 0;
		if(args[arg].trim().substring(0,1).equals("-")) {
			//has logger option
			setLogLevel(args[arg].trim().substring(1));
			arg++;
		} else {
			setLogLevel(ModelicaCompiler.ERROR);
		}

		if (args.length < arg+2) {
			logger.severe("ModelicaCompiler expects a file name and a class name as command line arguments.");
			System.exit(1);
		}		
		
		String name = args[arg];
		String cl = args[arg+1];
		String xmltempl = null;
		String ctempl = null;
		
		if (args.length >= arg+4) {
			xmltempl = args[arg+2];
			ctempl = args[arg+3];
		}
		
		try {
			compileModel(name, cl, xmltempl, ctempl);
		} catch  (ModelicaClassNotFoundException e){
			logger.severe("Could not find the class "+ cl);
			System.exit(0);
		} catch (CompilerException ce) {
			StringBuffer str = new StringBuffer();
			str.append(ce.getProblems().size() + " errors found:\n");
			for (Problem p : ce.getProblems()) {
				str.append(p.toString()+"\n");
			}
			logger.severe(str.toString());
			System.exit(0);
		} catch (Error e) {
			logger.severe("In file: '" + name + "':"+e.getMessage());
			System.exit(0);
		} catch (FileNotFoundException e) {
			logger.severe("Could not find file: " + name);
			System.exit(0);
		} catch (IOException e) {
			logger.severe(e.getMessage());
			e.printStackTrace();
			System.exit(0);
		} catch (Exception e) {
			logger.severe(e.getMessage());
			e.printStackTrace();
			System.exit(0);
		}

	}	
	
	/**
	 * Sets logging to the level specified. Valid values are:
	 * ModelicaCompiler.INFO, ModelicaCompiler.WARNING or ModelicaCompiler.ERROR
	 * 
	 * Default log level setting is ERROR. Messages will be printed to the 
	 * standard out.
	 * 
	 * @param level The level of logging to use as of now.
	 */
	public static void setLogLevel(String level) {
		if(level.equals(ModelicaCompiler.INFO)) {
			logger.setLevel(Level.INFO);
		} else if(level.equals(ModelicaCompiler.WARNING)) {
			logger.setLevel(Level.WARNING);
		} else if(level.equals(ModelicaCompiler.ERROR)){
			logger.setLevel(Level.SEVERE);
		} else {
			//severe is default
			logger.setLevel(Level.SEVERE);
		}
	}
	
	/**
	 * Returns the log level that is currently set.
	 * 
	 * @return Log level setting for this class.
	 */
	public static String getLogLevel() {
		return logger.getLevel() != null ? logger.getLevel().toString():ModelicaCompiler.INHERITED;
	}
	
	/**
	 * Compiles a Modelica model. A model file name and class must be provided. A 
	 * template file for XML and one for c can be provided to generatate code for 
	 * this model. Prints an error and returns without completion if, for example, 
	 * a file can not be found or if the parsing fails. 
	 * 
	 * @param name The name of the model file.
	 * @param cl The name of the class in the model file to compile.
	 * @param xmlTemplatefile The XML template file (optional).
	 * @param cTemplatefile The c template file (optional).
	 */
	public static void compileModel(String name, String cl, String xmlTemplatefile, String cTemplatefile) 
	  throws ModelicaClassNotFoundException, CompilerException, FileNotFoundException, IOException, Exception {
		logger.info("======= Compiling model =======");
		
		// build source tree
		SourceRoot sr = parseModel(name);

		// compute instance tree
		InstProgramRoot ipr = instantiateModel(sr, cl);
			
		// flattening
		FClass fc = flattenModel(name, cl, ipr);

		// Generate code?
		if (xmlTemplatefile != null && cTemplatefile != null) {
			generateCode(fc, xmlTemplatefile, cTemplatefile);
		}
		
		logger.info("====== Model compiled successfully =======");
	}

	/**
	 * 
	 * Parses a model and returns a reference to the root of the source tree. 
	 * Options related to the compilation are also loaded here and added to the 
	 * source tree representation.
	 * 
	 * @param name The name of the model file.
	 * @return The root of the source tree.
	 * @throws FileNotFoundException
	 * @throws IOException
	 * @throws Exception
	 */
	public static SourceRoot parseModel(String name) 
	  throws FileNotFoundException, IOException, Exception, CompilerException{
		ModelicaParser parser = new ModelicaParser();
//		ModelicaParser.CollectingReport report = new ModelicaParser.CollectingReport();
//		parser.setReport(report);
		Reader reader = new FileReader(name);
		ModelicaScanner scanner = new ModelicaScanner(new BufferedReader(reader));
	/*
		if (report.hasErrors()) {
			CompilerException ce = new CompilerException();
			for (Problem p : report.getErrors()) {
				ce.addProblem(p);
			}
			throw ce;
		}
		*/
		logger.info("Parsing " + name + "...");
		SourceRoot sr;
		try {
			sr = (SourceRoot) parser.parse(scanner);
		} catch (ModelicaParser.ParserException e) {
			e.getProblem().setFileName(name);
			CompilerException ce = new CompilerException();
			ce.addProblem(e.getProblem());
			throw ce;
		}

		loadOptions(sr);

		for (StoredDefinition sd : sr.getProgram().getUnstructuredEntitys()) {
			sd.setFileName(name);
		}

		return sr;
	}

	/**
	 * 
	 * Computes a model instance tree from a source tree. Some error checks 
	 * such as type checking is performed during the computation.
	 * 
	 * @param sr The reference to the model source root.
	 * @param cl The name of the class in the model file to compile.
	 * @return The root of the instance tree.
	 */
	public static InstProgramRoot instantiateModel(SourceRoot sr, String cl) throws ModelicaClassNotFoundException, CompilerException{
		InstProgramRoot ipr = sr.getProgram().getInstProgramRoot();

		logger.info("Checking for errors...");
		Collection<Problem> problems = ipr.checkErrorsInInstClass(cl);
		if (problems.size()>0) {
			CompilerException ce = new CompilerException();
			for (Problem p : problems) {
				ce.addProblem(p);
			}
			throw ce;
		}
		
		return ipr;		
	}
	
	/**
	 * Computes the flattened model representation from the parsed instance model.
	 * 
	 * @param name The name of the model file.
	 * @param cl The name of the class in the model file to compile.
	 * @param ipr The reference to the instance tree root.
	 * @return FClass object representing the flattened model.
	 */
	public static FClass flattenModel(String name, String cl, InstProgramRoot ipr) 
		throws CompilerException, ModelicaClassNotFoundException, IOException {
		FlatRoot flatRoot = new FlatRoot();
		flatRoot.setFileName(name);
		FClass fc = new FClass();
		flatRoot.setFClass(fc);

		logger.info("Flattening starts...");
		
		ipr.findFlattenInst(cl, fc);
		
		fc.transformCanonical();

		Collection<Problem> problems = fc.errorCheck();
		if (problems.size()>0) {
			CompilerException ce = new CompilerException();
			for (Problem p : problems) {
				ce.addProblem(p);
			}
			throw ce;
		}
				
		logger.info("Creating .mof file...");
	    	    	// Create file 
	   	FileWriter fstream = new FileWriter(cl+".mof");
	   	BufferedWriter out = new BufferedWriter(fstream);
	   	out.write(fc.prettyPrint(""));
	   	//Close the output stream
	   	out.close();
	   
	    logger.info("... .mof file created.");
	    
		if(getLogLevel().equals("INFO")) {
			System.out.println(fc.diagnostics());
			System.out.print(fc.prettyPrint(""));
		}
		
		return fc;
	}

	/**
	 * 
	 * Generates XML and c code for a flattened model represented as an 
	 * instance of FClass using template files. The XML and c files are 
	 * given the default names <modelname>.xml and <modelname>.c respectively.
	 * 
	 * @param fc The FClass instance for which the code generation should be computed.
	 * @param xmltemplate The path to the XML template file.
	 * @param ctemplate The path to the c template file.
	 * @throws FileNotFoundException Throws the exception if either of the two files are not found.
	 */
	public static void generateCode(FClass fc, String xmltemplate, String ctemplate) throws FileNotFoundException {
		logger.info("Generating code...");
		
		XMLGenerator generator = new XMLGenerator(new PrettyPrinter(), '$', fc);
		String output = fc.nameUnderscore()+".xml";
		generator.generate(xmltemplate, output);

		CGenerator cgenerator = new CGenerator(new PrettyPrinter(), '$', fc);
		output = fc.nameUnderscore() + ".c";
		cgenerator.generate(ctemplate, output);

		logger.info("...code generated.");
	}

	/**
	 * Loads the options provided, either hardcoded or from a file.
	 * 
	 * @param sr
	 *            The source root belonging to the model for which the options
	 *            should be set.
	 */
	private static void loadOptions(SourceRoot sr) {
		logger.info("Loading options...");
		
		sr.options.addModelicaLibrary(
						"Modelica",
						"3.0.1",
						"Z:\\jakesson\\projects\\ModelicaStandardLibrary\\ModelicaStandardLibrary_v3\\Modelica 3.0.1");
		sr.options.setStringOption("default_msl_version", "3.0.1");

	}
	
	private static class ModelicaLoggers {

		public static Logger getConsoleLogger(String name) {
			Logger l = Logger.getLogger(name);
			l.setUseParentHandlers(false);
			ConsoleHandler ch = new ConsoleHandler();
			ch.setFormatter(new ConsoleFormatter());
			l.addHandler(ch);
			l.setLevel(Level.INFO);
			return l;
		}
	
		private static class ConsoleFormatter extends SimpleFormatter {
			public ConsoleFormatter() {
				super();
			}
			@Override
			public String format(LogRecord record) {
				return record.getMessage()+"\n";
			}
		
		}
	}
}
