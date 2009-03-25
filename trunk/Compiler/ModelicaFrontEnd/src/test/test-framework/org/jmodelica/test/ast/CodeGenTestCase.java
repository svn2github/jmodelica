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
import java.io.BufferedReader;
import java.io.PrintStream;
import java.io.OutputStream;
import java.io.StringReader;
import org.jmodelica.codegen.*;

public abstract class CodeGenTestCase extends TestCase {
	private String genCode = "";
    private String genCodeFileName = "";
    private boolean resultOnFile = false;
	private String template = "";
    private String templateFileName = "";
    private boolean templateOnFile = false;
    
    private ModelicaParser parser = new ModelicaParser();
    
	public CodeGenTestCase() {}
    
	public CodeGenTestCase(String name, 
			                  String description,
			                  String sourceFileName, 
			                  String className, 
			                  String result,
			                  boolean resultOnFile,
			                  String template,
			                  boolean templateOnFile) {
		super(name, description, sourceFileName, className);
		this.resultOnFile = resultOnFile;		
		if (!resultOnFile) {
			this.genCode = result;
		} else {
			this.genCodeFileName = result;
		}
		this.templateOnFile = resultOnFile;		
		if (!resultOnFile) {
			this.template = result;
		} else {
			this.templateFileName = result;
		}
	}

	public abstract AbstractGenerator createGenerator(FClass fc);
	
	public void dump(StringBuffer str,String indent) {
		str.append(indent+"CodeGenTestCase: \n");
		if (testMe())
			str.append("PASS\n");
		else
			str.append("FAIL\n");
		str.append(indent+" Name:                     "+getName()+"\n");
		str.append(indent+" Description:              "+getDescription()+"\n");
		str.append(indent+" Source file:              "+getSourceFileName()+"\n");
		str.append(indent+" Class name:               "+getClassName()+"\n");
		if (!isResultOnFile())
			str.append(indent+" Generated code:\n"+getGenCode()+"\n");
		else
			str.append(indent+" Generated code file name: "+getGenCodeFileName()+"\n");
		
	}

	public String toString() {
		StringBuffer str = new StringBuffer();
		str.append("CodeGenTestCase: \n");
		str.append(" Name:                     "+getName()+"\n");
		str.append(" Description:              "+getDescription()+"\n");
		str.append(" Source file:              "+getSourceFileName()+"\n");
		str.append(" Class name:               "+getClassName()+"\n");
		if (!isResultOnFile())
			str.append(" Generated code:\n"+getGenCode()+"\n");
		else
			str.append(" Generated code file name: "+getGenCodeFileName()+"\n");
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
   	  	fc.genBindingEquations();
   	  	// Assume that result and template is not on file.
  	    StringOutputStream os = new StringOutputStream();
  	    AbstractGenerator generator = createGenerator(fc);
	    generator.generate(new BufferedReader(new StringReader(getTemplate())),
	    		           new PrintStream(os));

   	  	
		return os.toString().equals(getGenCode());
	}
	
	public String getGenCode() {
		return genCode;
	}
	
	public void setGenCode(String genCode) {
		this.genCode = genCode;
		this.genCodeFileName = "";
		this.resultOnFile = false;
	}

	public String getGenCodeFileName() {
		return genCodeFileName;
	}
	
	public void setGenCodeFileName(String flatModelFileName) {
		this.genCodeFileName = flatModelFileName;
		this.genCode = "";
		this.resultOnFile = true;
	}
	
	public boolean isResultOnFile() {
		return resultOnFile;
	}
	
	public void setResultOnFile(boolean resultOnFile) {
		this.resultOnFile = resultOnFile;
	}

	public String getTemplate() {
		return template;
	}
	
	public void setTemplate(String template) {
		this.template = template;
		this.templateFileName = "";
		this.templateOnFile = false;
	}

	public String templateFileName() {
		return templateFileName;
	}
	
	public void templateFileName(String templateFileName) {
		this.templateFileName = templateFileName;
		this.template = "";
		this.resultOnFile = true;
	}
	
	public boolean isTemplateOnFile() {
		return templateOnFile;
	}
	
	public void setTemplateOnFile(boolean resultOnFile) {
		this.templateOnFile = templateOnFile;
	}

	
	
}
