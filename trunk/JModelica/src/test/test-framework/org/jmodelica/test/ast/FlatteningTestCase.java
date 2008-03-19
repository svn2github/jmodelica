package org.jmodelica.test.ast;
import org.jmodelica.parser.ModelicaParser;
import org.jmodelica.parser.FlatModelicaParser;
import org.jmodelica.ast.*;

/**
 * @author jakesson
 *
 */
public class FlatteningTestCase extends TestCase {
	private String flatModel = "";
    private String flatModelFileName = "";
    private boolean resultOnFile = false;
	
    private ModelicaParser parser = new ModelicaParser();
    private FlatModelicaParser flatParser = new FlatModelicaParser();
    
	public FlatteningTestCase() {}
    
	/**
	 * @param name
	 * @param description
	 * @param sourceFileName
	 * @param className
	 * @param flatModel
	 * @param flatModelFileName
	 * @param resultOnFile
	 */
	public FlatteningTestCase(String name, 
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
		str.append(indent+"FlatteningTestCase: ");
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
		StringBuffer strd=new StringBuffer();
		dump(strd,"");
		System.out.println(strd);
		str.append("  @Test public void " + getName() + "() {\n");
		str.append("    assertTrue(ts.get("+index+").testMe());\n");
	    str.append("  }\n\n");
	}
	
	public boolean testMe() {
		SourceRoot sr = parser.parseFile(getSourceFileName());
		sr.setFileName(getSourceFileName());
		//sr.retrieveFullClassDecl("NameTests.ImportTest1").dumpTree("");
	    if (sr.checkErrorsInClass(getClassName())) {
	    	System.out.println("***** Errors in Class!");
	    	return false;
	    }
	    FlatRoot flatRoot = new FlatRoot();
	    //flatRoot.setFileName(name);
	    FClass fc = new FClass();
	    flatRoot.setFClass(fc);
	    
		//FClass fc = new FClass();
		sr.findFlatten(getClassName(), fc);
		/*if (fc.errorCheck()) {
	    	System.out.println("***** Errors in Class!");
	    	return false;			
		}*/
		System.out.println(fc.prettyPrint(""));
		System.out.println(getFlatModel());
		TokenTester tt = new TokenTester();
		
		boolean result =  tt.test(fc.prettyPrint(""),getFlatModel());
		if (!result) {
			System.out.println(fc.prettyPrint("").equals(getFlatModel()));
			sr.retrieveFullClassDecl("NameTests.ImportTest1").dumpTree("");
			fc.dumpTreeBasic("");
			try {
     			System.in.read();
			} catch (Exception e){}
		}
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
