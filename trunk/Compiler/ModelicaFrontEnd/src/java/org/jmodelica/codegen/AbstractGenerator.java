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

/** \file AbstractGenerator.java
 *  \brief AbstractGenerator class.
 */

/**
 * A package offering a basic code generation framework.
 */
package org.jmodelica.codegen;

import java.util.HashMap;
import org.jmodelica.ast.*;
import java.io.*;

/**
 * Abstract base class for code generation classes. 
 * 
 * The code generation framework is based on templates and tags. A template is
 * a file containing the structure of the generated code, annotated with
 * tags. During code generation, tags are then replaced by the generated code.
 * As an example, consider the template code fragment:
 * 
 *  ...
 *  #define numEquations = $n_equations$
 *  ...
 *  
 * Here, the tag $n_equations$ corresponds to the number of equations in a 
 * model. Accordingly, the generated code would then look like, e.g.,
 * 
 *  ...
 *  #define numEquations = 22
 *  ...
 *  
 * Tags are represented in the generator by Tag objects. Each Tag contains
 * essentially its name (the string enclosed by an escape character, $ in the 
 * example above), and a method for generating the corresponding code.
 * 
 * When the method generate is invoked, template file is loaded and an output
 * file is written where all tags has been replaced with their corresponding
 * generated code.
 *
 */
public abstract class AbstractGenerator {
    
	/** \brief A HasMap containing all tags */
	protected HashMap<String,AbstractTag> tagMap;
	/** \brief A Printer object used to generated code for expressions */
	protected Printer expPrinter;
	/** \brief A character used as escape character when decoding tags during
	 * code generation. 
	 */
	protected int escapeCharacter;
	
	/**
	 * \brief Constructor for AbstractGenerator.
	 * 
	 * @param expPrinter A Printer for code generation of expressions.
	 * @param escapeCharacter Escape character used when decoding tags.
	 */
	public AbstractGenerator(Printer expPrinter, char escapeCharacter) {
		this.expPrinter = expPrinter;
		this.escapeCharacter = (int)escapeCharacter;
		tagMap = new HashMap<String,AbstractTag>();
	}

	/**
	 * \brief Method for performing code generation. 
	 * 
	 * The method performs the following steps:
	 *  
	 *   1. Load the template file
	 *   2. Read a character, 'c', from the template
	 *   3. If 'c' is not the escape character 
	 *   3a.  Write 'c' to the output file
	 *   3b.  Else continue to read characters until the escape character is
	 *        encountered. Build the tag name from the read characters.
	 *   3c.  Retrieve the corresponding tag
	 *   3d.  Invoke the code generation method for the tag
	 *   4.   Repeat 2 until EOF 
	 *   
	 * 
	 * @param templateFile A file containing the code generation template
	 * @param outputFile The name of the output file
	 * @throws FileNotFoundException An exception is thrown if the template
	 * file is not found.
	 */
	public void generate(String templateFile, String outputFile) 
	  throws FileNotFoundException {
		generate(new BufferedReader(new FileReader(new File(templateFile))),
		  new PrintStream(new File(outputFile)));
	}

	/**
	 * \brief See generate(String templateFile, String outputFile).
	 * 
	 * @param templateReader A BufferedReader object from which the template 
	 * file can be used.
	 * @param genPrinter A PrintStream object to which the generated code
	 * is written.
	 */
	public void generate(BufferedReader templateReader, 
	  PrintStream genPrinter) {

		try {
		AbstractTag tag = null;
		int c = templateReader.read();
		int mode = 0;
		String tag_name = "";
		while (c != -1) {
			if (mode==0 && c==escapeCharacter) {
				mode = 1;
				tag_name = "";
			} else if (mode==0 && c!=escapeCharacter) {
				genPrinter.print((char)c);
			} else if (mode==1 && c!=escapeCharacter) {
				tag_name += (char)c;
			} else {
			    mode = 0;
				tag = tagMap.get(tag_name);
				if (tag != null) {
					tag.generate(genPrinter);
				} else {
					throw new RuntimeException("Unknown tag: "+ tag_name);
				}
			}
			c = templateReader.read();			
		}
		} catch (IOException e) {
		     throw new RuntimeException("IOException during code generation");
		}
	}	

	/**
	 * \brief Prints out all registered tags in the generator.	
	 */
	public String toString() {
		StringBuffer str = new StringBuffer();
		for (AbstractTag t : tagMap.values()) {
			str.append(t.toString()+"\n");
		}
		return str.toString();
	}
}
