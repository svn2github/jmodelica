package org.jmodelica.applications;
import org.jmodelica.ast.*;
import java.io.*;
import org.jmodelica.parser.*;

public class FlattenModel {
	
	  public static void main(String args[]) {
		    
		  long startTime = System.currentTimeMillis();
		  	if(args.length != 2) {
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
		      
		      //sr.dumpTree("");
		      
		      
		      sr.setFileName(name);
		      sr.prettyPrint("");
		      
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
		      boolean instErr = ipr.checkErrorsInInstClass(cl);
		      System.out.println("Source checking:");
		      boolean sourceErr = sr.checkErrorsInClass(cl);
		      

		      
		      if (instErr || sourceErr)
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
	    	  StringBuffer str = new StringBuffer();
		    	  System.out.println("Flattening starts...");
		    	  InstNode ir = ipr.findFlattenInst(cl,fc);
		    	  if (ir==null) {
		    		  System.out.println("Error:");
		    		  System.out.println("   Did not find the class: " + cl);
		    		  System.exit(0);
		    	  }
		    	  ir.dumpTree("");
		    	  
//		    	  if (ir.errorCheck())
//		    		  System.exit(0);
	    	  /*
		      System.out.println("Checking for errors...");	      
	    	  if (fc.errorCheck()) {
	    		  System.exit(0);
	    	  }	
	    	  */	    	  
		    	  instTime = System.currentTimeMillis();
		    	 //fc.dumpTree("");
		    	  fc.prettyPrint(str,"");
		    	  System.out.println(str.toString());
		    	  printTime = System.currentTimeMillis();
		
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
