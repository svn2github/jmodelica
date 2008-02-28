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
		      
		      /*
		      StringBuffer str2 = new StringBuffer();
		      p._prettyPrint(str2,"");
		      p.debugPrint("Pretty Printing of original program finished");
		      System.out.println(str2.toString());
		      
		      p.setFName(name);
		      reader.close();
		      */
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
		      ErrorManager errM = new ErrorManager();
		      if (!sr.checkErrors(cl,errM)) {
	    		  System.out.println("Error:");
	    		  System.out.println("   Did not find the class: " + cl);
	    		  System.exit(0);
	    	  }
		      
		      errM.printErrors();
		      
		      long errcheckTime = System.currentTimeMillis();
		      
		    
		      
		      long printTime = System.currentTimeMillis();
		      long instTime = System.currentTimeMillis();
		      
		      FClass fc = new FClass();
	    	  StringBuffer str = new StringBuffer();
		      if (errM.getNumErrors()==0) {
		    	  System.out.println("Flattening starts...");
		    	  InstNode ir = sr.findFlatten(cl,fc);
		    	  if (ir==null) {
		    		  System.out.println("Error:");
		    		  System.out.println("   Did not find the class: " + cl);
		    		  System.exit(0);
		    	  }
		    	  instTime = System.currentTimeMillis();
		    	 //fc.dumpTree("");
		    	  fc.prettyPrint(str,"");
		    	  System.out.println(str.toString());
		    	  printTime = System.currentTimeMillis();
		      }
		
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
