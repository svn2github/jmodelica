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
import org.jmodelica.ast.*;
import org.jmodelica.codegen.*;


public class XMLCodeGenTestCase extends CodeGenTestCase {
    
	public XMLCodeGenTestCase() {}
    
	public XMLCodeGenTestCase(String name, 
			                  String description,
			                  String sourceFileName, 
			                  String className, 
			                  String result,
			                  boolean resultOnFile,
			                  String template,
			                  boolean templateOnFile) {
		super(name, description, sourceFileName, className,result,
				resultOnFile,template,templateOnFile);
	}

	public AbstractGenerator createGenerator(FClass fc) {
		return new XMLGenerator(new PrettyPrinter(), '$',fc);		
	}
	
}
