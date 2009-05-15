
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

/** \file XMLGenerator.java
*  \brief XMLGenerator class.
*/

package org.jmodelica.codegen;

import java.io.PrintStream;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Stack;

import org.jmodelica.ast.FBooleanVariable;
import org.jmodelica.ast.FClass;
import org.jmodelica.ast.FIntegerVariable;
import org.jmodelica.ast.FRealVariable;
import org.jmodelica.ast.FStringVariable;
import org.jmodelica.ast.FVariable;
import org.jmodelica.ast.Printer;

/**
 * A generator class for XML code generation which takes a model described by
 * <FClass> and provides an XML document for the meta-data in the model. Uses a
 * template for the static general structure of tags and an internal class
 * <TagGenerator> for the parts of the XML that are dynamic, that is, may vary
 * depending on the contents of the underlying model.
 * 
 * @see AbstractGenerator
 * 
 */
public class OptimicaXMLGenerator extends XMLGenerator {
		

	/**
	 * Constructor.
	 * 
	 * @param expPrinter Printer object used to generate code for expressions.
	 * @param escapeCharacter Escape characters used to decode tags.
	 * @param fclass An FClass object used as a basis for the code generation.
	 */
	public OptimicaXMLGenerator(Printer expPrinter, char escapeCharacter,
			FClass fclass) {
		super(expPrinter,escapeCharacter, fclass);
		
		// Create tags			
		AbstractTag tag = null;

//		tag = new DAETag_XML_modelName(this,fclass);
//		tagMap.put(tag.getName(), tag);

	}

}

