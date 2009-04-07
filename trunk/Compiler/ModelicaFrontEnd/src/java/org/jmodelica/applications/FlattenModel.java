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
import org.jmodelica.ast.*;
import java.io.*;
import org.jmodelica.parser.*;
import org.jmodelica.codegen.GenericGenerator;

public class FlattenModel {
	
	  public static void main(String args[]) {
		    
		  long startTime = System.currentTimeMillis();
		  	if(args.length < 2) {
		      System.out.println("FlattenModel expects a file name and a class name as command line arguments");
		      System.exit(1);
		    }
		  
		    ModelicaParser parser = new ModelicaParser();
		    String name = args[0];
		    
		    try {
		      String cl = args[1];
		      Reader reader = new FileReader(name);
		      ModelicaScanner scanner = new ModelicaScanner(new BufferedReader(reader));
		      System.out.println("Parsing "+name+"...");
		     
		      
		      SourceRoot sr = (SourceRoot)parser.parse(scanner);
		      
		      sr.options.addModelicaLibrary("Modelica","3.0.1",
		    		  "/Users/jakesson/projects/ModelicaStandardLibrary/ModelicaStandardLibrary_v3/Modelica 3.0.1/");
		      sr.options.setStringOption("default_msl_version","3.0.1");
		      
//		      sr.getProgram().dumpClasses("");
		      
		      //sr.dumpTree("");
		      
		      for (StoredDefinition sd : sr.getProgram().getUnstructuredEntitys()) {
		    	  sd.setFileName(name);
		      }
		      
//		      sr.prettyPrint("");
		      
		      InstProgramRoot ipr = sr.getProgram().getInstProgramRoot();
		      //ipr.dumpTree("");
		      
		      long parseTime = System.currentTimeMillis();
		      
		      System.out.println("Checking for errors...");	      
		      /* This is very strange. If errorCheck() is run instead of
		       *  checkErrorsInClass(cl), we get incorrect results for 
		       *  scripts/linux/flattenmm src/test/modelica/NameTests.mo NameTests.ImportTest1
		       *  TODO: fix this!!!
		       *  
		       */

//		      ipr.dumpTree("");		      
		      
		      System.out.println("Inst checking:");
		      boolean instErr = false;
//		      try {
		      instErr = ipr.checkErrorsInInstClass(cl);
//		      } catch(Exception e) {
//		    	  e.printStackTrace();
//		      }
//		      System.out.println("Source checking:");
//		      boolean sourceErr = sr.checkErrorsInClass(cl);
		      

		      if (instErr)
		    	  System.exit(0);
		      
/*		      
		      if (ipr.checkErrorsInInstClass(cl)) {
			      //if (sr.errorCheck()) {
		    		  System.exit(0);
		    	  }
		      
		      if (sr.checkErrorsInClass(cl)) {
		      //if (sr.errorCheck()) {
	    		  System.exit(0);
	    	  }
*/		      
		      
		      long errcheckTime = System.currentTimeMillis();
		      
		      long printTime = System.currentTimeMillis();
		      long instTime = System.currentTimeMillis();
		      FlatRoot flatRoot = new FlatRoot();
		      flatRoot.setFileName(name);
		      FClass fc = new FClass();
		      flatRoot.setFClass(fc);
		    	  System.out.println("Flattening starts...");
		    	  InstNode ir = ipr.findFlattenInst(cl,fc);
		    	  if (ir==null) {
		    		  System.out.println("Error:");
		    		  System.out.println("   Did not find the class: " + cl);
		    		  System.exit(0);
		    	  }
		    	  ir.dumpTree("");
		    	/*
		    	  for (FVariable fv : fc.getFVariables()) {
		    		  System.out.println(fv.name() + " = " + fv.ceval());
		    	  }
		    	  */
//		    	  if (ir.errorCheck())
//		    		  System.exit(0);
	    	  /*
		      System.out.println("Checking for errors...");	      
	    	  if (fc.errorCheck()) {
	    		  System.exit(0);
	    	  }	
	    	  */	    	  
		    	  instTime = System.currentTimeMillis();
		    	  fc.dumpTree("");
		    	  System.out.println(fc.diagnostics());
		    	  System.out.print(fc.prettyPrint(""));
		    	  printTime = System.currentTimeMillis();
		
		      // Generate code?
		      if (args.length==4) {
		    	  GenericGenerator generator = 
		    		  new GenericGenerator(new PrettyPrinter(), '$',fc);
		    	  System.out.println(generator.toString());
		    	  generator.generate(args[2],args[3]);

		      }
		    	  
		      System.err.println("Parse time:         " + ((double)(parseTime-startTime))/1000.0);
		      System.err.println("Error check time:   " + ((double)(errcheckTime-parseTime))/1000.0);
		      System.err.println("Instantiation time: " + ((double)(instTime-errcheckTime))/1000.0);
		      System.err.println("Print time:         " + ((double)(printTime-instTime))/1000.0);
		      System.err.println("Total time:         " + ((double)(printTime-startTime))/1000.0);

		      
		    } catch (Error e){
		    	System.out.println("In file: '"+name + "':");
				System.err.println(e.getMessage());
		        System.exit(1);
		    	
		    
		    } catch (FileNotFoundException e) {
		      e.printStackTrace();
		      return;
		    } catch (IOException e) {
		      System.err.println(e);
		      e.printStackTrace();
		      return;
		    } catch (Exception e) {
		      System.err.println(e);
		      e.printStackTrace();
		      return;
		    }
		  }
}
