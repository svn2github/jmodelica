/**
 * 
 */
package org.jmodelica.test.ast;

import org.jmodelica.parser.ModelicaParser;
import org.jmodelica.parser.FlatModelicaParser;
import org.jmodelica.ast.*;

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
		str.append(indent+"ErrorTestCase: ");
		if (testMe())
			str.append("PASS\n");
		else
			str.append("FAIL\n");
		str.append(indent+" Name:                     "+getName()+"\n");
		str.append(indent+" Description:              "+getDescription()+"\n");
		str.append(indent+" Source file:              "+getSourceFileName()+"\n");
		str.append(indent+" Class name:               "+getClassName()+"\n");

	}

	/* (non-Javadoc)
	 * @see org.jmodelica.test.ast.TestCase#dumpJunit(java.lang.StringBuffer, int)
	 */
	@Override
	public void dumpJunit(StringBuffer str, int index) {
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
	   
		if (sr.errorCheck()) {
	    	System.out.println("***** Errors in Class!");
	    	return false;
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
	    return true;
	    		
		
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
