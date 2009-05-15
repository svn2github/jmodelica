
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

/** \file CGenerator.java
*  \brief CGenerator class.
*/

package org.jmodelica.codegen;

import java.io.*;
import org.jmodelica.ast.*;


public class OptimicaCGenerator extends CGenerator {
	
	
	/**
	 * Constructor.
	 * 
	 * @param expPrinter Printer object used to generate code for expressions.
	 * @param escapeCharacter Escape characters used to decode tags.
	 * @param fclass An FClass object used as a basis for the code generation.
	 */
	public OptimicaCGenerator(Printer expPrinter, char escapeCharacter,
			FOptClass fclass) {
		super(expPrinter,escapeCharacter, fclass);

		// Create tags			
		AbstractTag tag = null;
		
		//tag = new DAETag_C_equationResiduals(this,fclass);
		//tagMap.put(tag.getName(),tag);
		
	}

}

