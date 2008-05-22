/**
 * 
 */
package org.jmodelica.test.ast;

import org.jmodelica.parser.ModelicaParser;
import org.jmodelica.parser.FlatModelicaParser;
import org.jmodelica.ast.*;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.StringReader;

/**
 * @author jakesson
 *
 */
public class ErrorTestCase extends TestCase {

	String errorMessage="";
	
	private ModelicaParser parser = new ModelicaParser();
	private FlatModelicaParser flatParser = new FlatModelicaParser();
	
	public ErrorTestCase() {}
	
	public ErrorTestCase(String errorMessage) {
		this.errorMessage = errorMessage;
	}
	
	/* (non-Javadoc)
	 * @see org.jmodelica.test.ast.TestCase#dump(java.lang.StringBuffer, java.lang.String)
	 */
	@Override
	public void dump(StringBuffer str, String indent) {
		str.append(indent+"ErrorTestCase: \n");
		if (testMe())
			str.append("PASS\n");
		else
			str.append("FAIL\n");
		str.append(indent+" Name:                     "+getName()+"\n");
		str.append(indent+" Description:              "+getDescription()+"\n");
		str.append(indent+" Source file:              "+getSourceFileName()+"\n");
		str.append(indent+" Class name:               "+getClassName()+"\n");

	}

	public String toString() {
		StringBuffer str = new StringBuffer();
		str.append("ErrorTestCase: \n");
		str.append(" Name:                     "+getName()+"\n");
		str.append(" Description:              "+getDescription()+"\n");
		str.append(" Source file:              "+getSourceFileName()+"\n");
		str.append(" Class name:               "+getClassName()+"\n");
		return str.toString();
		
	}

	
	
	/* (non-Javadoc)
	 * @see org.jmodelica.test.ast.TestCase#dumpJunit(java.lang.StringBuffer, int)
	 */
	@Override
	public void dumpJunit(StringBuffer str, int index) {
		testMe();
		str.append("  @Test public void " + getName() + "() {\n");
		str.append("    assertTrue(ts.get("+index+").testMe());\n");
	    str.append("  }\n\n");
	}

	/* (non-Javadoc)
	 * @see org.jmodelica.test.ast.TestCase#printTest(java.lang.StringBuffer)
	 */
	@Override
	public boolean printTest(StringBuffer str) {
		str.append("TestCase: " + getName() +": ");
		if (testMe()) {
			str.append("PASS\n");
			return true;
		}else {
			str.append("FAIL\n");
			return false;
		}
	}

	/* (non-Javadoc)
	 * @see org.jmodelica.test.ast.TestCase#testMe()
	 */
	@Override
	public boolean testMe() {
		SourceRoot sr = parser.parseFile(getSourceFileName());
		sr.setFileName(getSourceFileName());
	    StringBuffer str = new StringBuffer();
	    if (sr.checkErrorsInClass(getClassName(),str)) {
	    	String testErrorMsg = filterErrorMessages(str.toString());
	    	String correctErrorMsg = filterErrorMessages(getErrorMessage());
			if (testErrorMsg.equals(correctErrorMsg))
	    		return true;
	    }
	
	  FClass fc = new FClass();  
	  InstNode ir = sr.findFlatten(getClassName(),fc);
  	  if (ir.errorCheck(str)) {
	    	String testErrorMsg = filterErrorMessages(str.toString());
	    	String correctErrorMsg = filterErrorMessages(getErrorMessage());
	    	if (testErrorMsg.equals(correctErrorMsg))
	    		return true;
  	  }
	    
		/*
		ErrorManager errM = new ErrorManager();
	    //System.out.println(sr.checkErrors(getClassName(),errM));
	    //System.out.println(getClassName());
	    //StringBuffer str0 = new StringBuffer();
	    //sr.dumpTree("");
	    if (!sr.checkErrors(getClassName(),errM))
	    	return false;
	    if (errM.getNumErrors()==0)
	    	return false;
	    */
	    //StringBuffer str = new StringBuffer();
	    //errM.printErrors(str);
	    //System.out.println(str.toString());
	    //System.out.println(errorMessage);
	    //if (!errorMessage.equals(str.toString()))
	    //	return false;
	    return false;
	    		
		
	}

	public String filterErrorMessages(String str) {
		StringBuffer filteredStr = new StringBuffer();
		BufferedReader origStr = new BufferedReader(new StringReader(str));
		String line;
		
		try {
			line = origStr.readLine();
		} catch (IOException e) {
			e.printStackTrace();
			return filteredStr.toString();
		}
		while (line!=null) {
			try {
			
				line = origStr.readLine();
				
			if (line!=null && line.contains("Semantic error at line")) {
	
					line = origStr.readLine();
				filteredStr.append(line+"\n");
			
			}
			
			} catch (IOException e) {
				e.printStackTrace();
				return filteredStr.toString();
			}	

			
		}
		
	return filteredStr.toString();
	}
	
	/**
	 * @return the errorMessage
	 */
	public String getErrorMessage() {
		return errorMessage;
	}

	/**
	 * @param errorMessage the errorMessage to set
	 */
	public void setErrorMessage(String errorMessage) {
		this.errorMessage = errorMessage;
	}

}
