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

public class FlattenOModel {
	
	  public static void main(String args[]) {
		    
		  long startTime = System.currentTimeMillis();
		  	if(args.length != 2) {
		      System.out.println("FlattenOModel expects a file name and a class name as command line arguments");
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
		      
		      
		      //sr.dumpTree("");
		      
		      sr.setFileName(name);
		      
		      sr.options.addModelicaLibrary("Modelica","3.0.1",
    		  "/Users/jakesson/projects/ModelicaStandardLibrary/ModelicaStandardLibrary_v3/Modelica 3.0.1/");
              sr.options.setStringOption("default_msl_version","3.0.1");

		      
		      StringBuffer str2 = new StringBuffer();
//		      sr.getProgram().prettyPrint(str2,"");
		      //p.debugPrint("Pretty Printing of original program finished");
//		      System.out.println(str2.toString());
		      /*
		      p.setFName(name);
		      reader.close();
		      */
		      
		      InstProgramRoot ipr = sr.getProgram().getInstProgramRoot();		      
		      long parseTime = System.currentTimeMillis();
		      
		      
		      
		     // p.getLibrary(0).trigImportAccess();
		      
		      //p.getLibrary(0).prettyPrintLibrary("");
		      
		      //p.getLibrary(0).dumpTree("");
		      /*
		      System.out.println("Checking for errors in Standard Lib...");	      
		      ErrorManager errMsl = new ErrorManager();
		      p.getLibrary(0).collectErrors(errMsl);
		      errMsl.printErrors();
		      */
		      
		      
		      //p.getLibrary(0).dumpTree("");
		      /*
		      BufferedReader keyboard = new BufferedReader(new InputStreamReader(System.in));
				try {
					keyboard.readLine();
				} catch (Exception e) { e.printStackTrace();}
				*/
		     
		      //p.dumpTree("");  

		      
		      System.out.println("Checking for errors...");	   
		      System.out.println("Inst checking:");
		      try {
		      boolean instErr = ipr.checkErrorsInInstClass(cl);
		      if (instErr) {
		    	  System.exit(0);
		      }

		      } catch(Exception e) {
		    	  e.printStackTrace();
		      }

		      
		      long errcheckTime = System.currentTimeMillis();
		      
		    
		      
		      long printTime = System.currentTimeMillis();
		      long instTime = System.currentTimeMillis();
		      
		      FlatRoot flatRoot = new FlatRoot();
		      flatRoot.setFileName(name);
		      FOptClass fc = new FOptClass();
		      flatRoot.setFClass(fc);		      
	    	  StringBuffer str = new StringBuffer();

		    	  System.out.println("Flattening starts...");
		    	  InstNode ir = ipr.findFlattenInst(cl,fc);
		    	  if (ir==null) {
		    		  System.out.println("Error:");
		    		  System.out.println("   Did not find the class: " + cl);
		    		  System.exit(0);
		    	  }
		    	  instTime = System.currentTimeMillis();
		    	  fc.dumpTree("");
		    	  System.out.println(fc.prettyPrint(""));
		    	  System.out.println(str.toString());
		    	  printTime = System.currentTimeMillis();

		
		      System.err.println("Parse time:         " + ((double)(parseTime-startTime))/1000.0);
		      System.err.println("Error check time:   " + ((double)(errcheckTime-parseTime))/1000.0);
		      System.err.println("Instantiation time: " + ((double)(instTime-errcheckTime))/1000.0);
		      System.err.println("Print time:         " + ((double)(printTime-instTime))/1000.0);
		      System.err.println("Total time:         " + ((double)(printTime-startTime))/1000.0);

		      
		      /*
		      long startTime2 = System.currentTimeMillis();
			  ModelicaParser parser2 = new ModelicaParser();
		   
		      Reader reader2 = new FileReader(name);
		      ModelicaScanner scanner2 = new ModelicaScanner(new BufferedReader(reader2));
		      System.out.println("Parsing "+name+"...");
		     
		      Program p2 = (Program)parser2.parse(scanner2);
		      
		      p2.setFName(name);
		      reader2.close();
		      long parseTime2 = System.currentTimeMillis();
		      		      
		      System.out.println("Checking for errors...");	      
		      ErrorManager errM2 = new ErrorManager();
		      p2.collectErrors(errM2);
		      errM2.printErrors();
		      long errcheckTime2 = System.currentTimeMillis();
		      
		    
		      long instTime2 = 0;
		      long printTime2 = 0;
		      
		      FClass fc2 = new FClass();
	    	  StringBuffer str2 = new StringBuffer();
		      if (errM2.getNumErrors()==0) {
		    	  System.out.println("Instantiation starts...");
		    	  p2.findInstantiate(cl,fc2);
		    	  instTime2 = System.currentTimeMillis();
		    	  //fc.dumpTree("");
		    	  fc2._prettyPrint(str2,"");
		    	  System.out.println(str2.toString());
		    	  printTime2 = System.currentTimeMillis();
		      }
		
		      System.err.println("Parse time:         " + ((double)(parseTime2-startTime2))/1000.0);
		      System.err.println("Error check time:   " + ((double)(errcheckTime2-parseTime2))/1000.0);
		      System.err.println("Instantiation time: " + ((double)(instTime2-errcheckTime2))/1000.0);
		      System.err.println("Print time:         " + ((double)(printTime2-instTime2))/1000.0);
		      System.err.println("Total time:         " + ((double)(printTime2-startTime2))/1000.0);
		      
		      
		      */
		      
		      
		      
		      
		      
		      
		      
		      
			  /*
			  Collection errors = p.errors();
		      if(!errors.isEmpty()) {
		        for(Iterator iter = errors.iterator(); iter.hasNext(); )
		          System.out.println(iter.next());
		      }
		      else {
		        System.out.println("OK");
		      }*/
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
