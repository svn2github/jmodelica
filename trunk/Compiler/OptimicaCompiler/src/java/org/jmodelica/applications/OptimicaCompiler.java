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

import java.io.BufferedWriter;
import java.io.FileNotFoundException;
import java.io.FileWriter;
import java.io.IOException;
import java.util.Collection;
import java.util.logging.Logger;

import org.jmodelica.ast.CompilerException;
import org.jmodelica.ast.FOptClass;
import org.jmodelica.ast.FlatRoot;
import org.jmodelica.ast.InstProgramRoot;
import org.jmodelica.ast.ModelicaClassNotFoundException;
import org.jmodelica.ast.PrettyPrinter;
import org.jmodelica.ast.Problem;
import org.jmodelica.ast.SourceRoot;
import org.jmodelica.codegen.OptimicaCGenerator;
import org.jmodelica.codegen.OptimicaXMLVariableGenerator;
import org.jmodelica.codegen.XMLProblemVariableGenerator;
import org.jmodelica.codegen.XMLValueGenerator;

import beaver.Parser.Exception;

/**
 * 
 * Main compiler class which bundles the tasks needed to compile an Optimica model. This class
 * is an extension of ModelicaCompiler.
 * 
 *  There are two usages with this class:
 *  1. Compile in one step with command line arguments using this class only.
 *  2. Split compilation into several steps by calling the static methods in your own class/module.
 *  
 *  Use (1) for a simple and compact way of compiling an Optimica model. As a minimum, provide 
 *  the modelfile name and class name as command line arguments. Optional arguments are XML 
 *  templates and c template files which are needed for code generation. If any of these are 
 *  ommitted no code generation will be performed.
 *  
 *  Example without code generation: 
 *  org.jmodelica.applications.OptimicaCompiler myModels/models.mo models.model1
 *  
 *  Example with code generation:
 *  org.jmodelica.applications.OptimicaCompiler myModels/models.mo models.model1 
 *  templates/XMLtemplate1.xml templates/XMLtemplate2.xml templates/XMLtemplate3.xml templates/cppTemplate.cpp
 *  
 *  Logging can be set with the optional argument -i, -w or -e where:
 *  
 *  -i : log info, warning and error messages
 *	-w : log warning and error messages
 *  -e : log error messages only (default if the log option is not used)
 *  
 *  Example with log level set to INFO:
 *  org.jmodelica.applications.OptimicaCompiler -i myModels/models.mo models.model1
 *  
 *  The logs will be printed to standard out.
 *  
 *  
 *  For method (2), the compilation steps are divided into 4 tasks which can be used via the methods:
 *  1. parseModel (source code -> attributed source representation) - ModelicaCompiler
 *  2. instantiateModel (source representation -> instance model) - ModelicaCompiler
 *  3. flattenModel (instance model -> flattened model)
 *  4. generateCode (flattened model -> c code and XML code)
 *  
 *  They must be called in this order. Use provided methods in ModelicaCompiler to get/set logging level. 
 *  
 */
public class OptimicaCompiler extends ModelicaCompiler{

	private static final Logger logger = ModelicaLoggers.getConsoleLogger("JModelica.OptimicaCompiler");
	
	public static void main(String args[]) {
		if(args.length < 1) {
			logger.severe("OptimicaCompiler expects the command line arguments: [-i/w/e] <file name> <class name> [<xml template> <c template>]");
			System.exit(1);
		}
		int arg = 0;
		if(args[arg].trim().substring(0,1).equals("-")) {
			//has logger option
			setLogLevel(args[arg].trim().substring(1));
			arg++;
		} else {
			setLogLevel(OptimicaCompiler.ERROR);
		}

		if (args.length < arg+2) {
			logger.severe("OptimicaCompiler expects a file name and a class name as command line arguments.");
			System.exit(1);
		}		
		
		String name = args[arg];
		String cl = args[arg+1];
		String xmlVariablesTempl = null;
		String xmlProblVariablesTempl = null;
		String xmlValuesTempl = null;
		String ctempl = null;
		
		if (args.length >= arg+6) {
			xmlVariablesTempl = args[arg+2];
			xmlProblVariablesTempl = args[arg+3];
			xmlValuesTempl = args[arg+4];
			ctempl = args[arg+5];
		}
		
		try {
			compileModel(name, cl, xmlVariablesTempl, xmlProblVariablesTempl, xmlValuesTempl, ctempl);
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
	 * Compiles an Optimica model. A model file name and class must be provided. A 
	 * template file for XML and one for c can be provided to generatate code for 
	 * this model. Prints an error and returns without completion if, for example, 
	 * a file can not be found or if the parsing fails. 
	 * 
	 * @param name The name of the model file.
	 * @param cl The name of the class in the model file to compile.
	 * @param xmlVariablesTempl The XML template file for model variables (optional).
	 * @param xmlProblVariablesTempl The XML template file for the optimization problem variables (optional).
	 * @param xmlValuesTempl The XML template file for independent parameter values (optional).
	 * @param cTemplatefile The c template file (optional).
	 */
	public static void compileModel(String name, String cl, String xmlVariablesTempl, String xmlProblVariablesTempl, String xmlValuesTempl, String cTemplatefile) 
	  throws ModelicaClassNotFoundException, CompilerException, FileNotFoundException, IOException, Exception {
		logger.info("======= Compiling model =======");
		
		// build source tree
		SourceRoot sr = parseModel(name);

		// compute instance tree
		InstProgramRoot ipr = instantiateModel(sr, cl);
			
		// flattening
		FOptClass fc = flattenModel(name, cl, ipr);

		// Generate code?
		if (xmlVariablesTempl != null && cTemplatefile != null) {
			generateCode(fc, xmlVariablesTempl,xmlProblVariablesTempl, xmlValuesTempl, cTemplatefile);
		}
		
		logger.info("====== Model compiled successfully =======");
	}
	
	/**
	 * Computes the flattened model representation from the parsed instance model.
	 * 
	 * @param name The name of the model file.
	 * @param cl The name of the class in the model file to compile.
	 * @param ipr The reference to the instance tree root.
	 * @return FClass object representing the flattened model.
	 */
	public static FOptClass flattenModel(String name, String cl, InstProgramRoot ipr) 
		throws CompilerException, ModelicaClassNotFoundException, IOException {
		FlatRoot flatRoot = new FlatRoot();
		flatRoot.setFileName(name);
		FOptClass fc = new FOptClass();
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
	 * @param xmlVariablesTempl The XML template file for model variables (optional).
	 * @param xmlProblVariablesTempl The XML template file for the optimization problem variables (optional).
	 * @param xmlValuesTempl The XML template file for independent parameter values (optional).
	 * @param ctemplate The path to the c template file.
	 * @throws FileNotFoundException Throws the exception if either of the two files are not found.
	 */
	public static void generateCode(FOptClass fc, String xmlVariablesTempl, String xmlProblVariablesTempl, String xmlValuesTempl, String ctemplate) throws FileNotFoundException {
		logger.info("Generating code...");
		
		OptimicaXMLVariableGenerator variablegenerator = new OptimicaXMLVariableGenerator(new PrettyPrinter(), '$', fc);
		String output = fc.nameUnderscore() + "_variables.xml";
		variablegenerator.generate(xmlVariablesTempl, output);
		
		XMLProblemVariableGenerator problVariableGenerator = new XMLProblemVariableGenerator(new PrettyPrinter(), '$', fc);
		output = fc.nameUnderscore() + "_problvariables.xml";
		problVariableGenerator.generate(xmlProblVariablesTempl, output);
		
		XMLValueGenerator valuegenerator = new XMLValueGenerator(new PrettyPrinter(), '$', fc);
		output = fc.nameUnderscore() + "_values.xml";
		valuegenerator.generate(xmlValuesTempl, output);
		
		OptimicaCGenerator cgenerator = new OptimicaCGenerator(new PrettyPrinter(), '$', fc);
		output = fc.nameUnderscore() + ".c";
		cgenerator.generate(ctemplate, output);

		logger.info("...code generated.");
	}
}
