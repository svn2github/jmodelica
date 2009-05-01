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


package org.jmodelica.test.ast;
import org.jmodelica.parser.ModelicaParser;
import org.jmodelica.parser.FlatModelicaParser;
import org.jmodelica.ast.*;

/**
 * @author jakesson
 *
 */
public class TransformCanonicalTestCase extends TestCase {
	private String flatModel = "";
    private String flatModelFileName = "";
    private boolean resultOnFile = false;
	
    private ModelicaParser parser = new ModelicaParser();
    private FlatModelicaParser flatParser = new FlatModelicaParser();
    
	public TransformCanonicalTestCase() {}
    
	/**
	 * @param name
	 * @param description
	 * @param sourceFileName
	 * @param className
	 * @param flatModel
	 * @param flatModelFileName
	 * @param resultOnFile
	 */
	public TransformCanonicalTestCase(String name, 
			                  String description,
			                  String sourceFileName, 
			                  String className, 
			                  String result,
			                  boolean resultOnFile) {
		super(name, description, sourceFileName, className);
		this.resultOnFile = resultOnFile;		
		if (!resultOnFile) {
			this.flatModel = result;
		} else {
			this.flatModelFileName = result;
		}
		
	}

	public void dump(StringBuffer str,String indent) {
		str.append(indent+"TransformCanonicalTestCase: \n");
		if (testMe())
			str.append("PASS\n");
		else
			str.append("FAIL\n");
		str.append(indent+" Name:                     "+getName()+"\n");
		str.append(indent+" Description:              "+getDescription()+"\n");
		str.append(indent+" Source file:              "+getSourceFileName()+"\n");
		str.append(indent+" Class name:               "+getClassName()+"\n");
		if (!isResultOnFile())
			str.append(indent+" Flat model:\n"+getFlatModel()+"\n");
		else
			str.append(indent+" Flat model file name: "+getFlatModelFileName()+"\n");
		
	}

	public String toString() {
		StringBuffer str = new StringBuffer();
		str.append("TransformCanonicalTestCase: \n");
		str.append(" Name:                     "+getName()+"\n");
		str.append(" Description:              "+getDescription()+"\n");
		str.append(" Source file:              "+getSourceFileName()+"\n");
		str.append(" Class name:               "+getClassName()+"\n");
		if (!isResultOnFile())
			str.append(" Flat model:\n"+getFlatModel()+"\n");
		else
			str.append(" Flat model file name: "+getFlatModelFileName()+"\n");
		return str.toString();
	}
	
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
	
	public void dumpJunit(StringBuffer str, int index) {
		//StringBuffer strd=new StringBuffer();
		//dump(strd,"");
		testMe();
		//System.out.println(strd);
		str.append("  @Test public void " + getName() + "() {\n");
		str.append("    assertTrue(ts.get("+index+").testMe());\n");
	    str.append("  }\n\n");
	}
	
	public boolean testMe() {
        System.out.println("Running test: " + getClassName());
		SourceRoot sr = parser.parseFile(getSourceFileName());
		sr.setFileName(getSourceFileName());
	    InstProgramRoot ipr = sr.getProgram().getInstProgramRoot();
	    if (ipr.checkErrorsInInstClass(getClassName())) {
	    	//System.out.println("***** Errors in Class!");
	    	return false;
	    }

	    
	    //sr.retrieveFullClassDecl("NameTests.ImportTest1").dumpTree("");
/*
	    if (sr.checkErrorsInClass(getClassName())) {
	    	//System.out.println("***** Errors in Class!");
	    	return false;
	    }
*/
	    
	    FlatRoot flatRoot = new FlatRoot();
	    flatRoot.setFileName(getSourceFileName());
	    FClass fc = new FClass();
	    flatRoot.setFClass(fc);
	    
		//FClass fc = new FClass();
	    InstNode ir = ipr.findFlattenInst(getClassName(), fc);
	    
	    
	    
   	  	if (ir==null) {
   		    return false;
   	    }
   	    
//   	  	StringBuffer str = new StringBuffer();
//   	    if (ir.errorCheck(str)) {
//   	    	System.out.println(getClassName());
//   		    System.out.println(str.toString());
//   	    	return false;
//   	    }
		//if (fc.errorCheck()) {
	    	//System.out.println("***** Errors in Class!");
	    //	return false;			
		//}
		//System.out.println(fc.prettyPrint(""));
		//System.out.println(getFlatModel());
   	  	fc.transformCanonical();
		TokenTester tt = new TokenTester();
		String testModel = fc.prettyPrint("");
		String correctModel = getFlatModel();
		
		boolean result =  tt.test(testModel,correctModel);
		/*if (!result) {
			System.out.println(fc.prettyPrint("").equals(getFlatModel()));
			sr.retrieveFullClassDecl("NameTests.ImportTest1").dumpTree("");
			fc.dumpTreeBasic("");
			try {
     			System.in.read();
			} catch (Exception e){}
		}*/
		return result;
	}
	
	/**
	 * @return the flatModel
	 */
	public String getFlatModel() {
		return flatModel;
	}
	/**
	 * @param flatModel the flatModel to set
	 */
	public void setFlatModel(String flatModel) {
		this.flatModel = flatModel;
		this.flatModelFileName = "";
		this.resultOnFile = false;
	}
	/**
	 * @return the flatModelFileName
	 */
	public String getFlatModelFileName() {
		return flatModelFileName;
	}
	/**
	 * @param flatModelFileName the flatModelFileName to set
	 */
	public void setFlatModelFileName(String flatModelFileName) {
		this.flatModelFileName = flatModelFileName;
		this.flatModel = "";
		this.resultOnFile = true;
	}
	/**
	 * @return the resultOnFile
	 */
	public boolean isResultOnFile() {
		return resultOnFile;
	}
	
	/**
	 * @param resultOnFile the resultOnFile to set
	 */
	public void setResultOnFile(boolean resultOnFile) {
		this.resultOnFile = resultOnFile;
	}
    
	
	
}
