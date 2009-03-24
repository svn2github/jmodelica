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

/** \file AbstractTag.java
 *  \brief AbstractTag class.
 */

package org.jmodelica.codegen;

import java.io.*;

/**
 * A base class for tags used in the code generation framework.
 * 
 * Abstract tag contains the name of the tag, a description of the tag
 * and a method to generate the code corresponding to the tag.
 *
 */
public abstract class AbstractTag {
	/**
	 * Name of the tag
	 */
	protected String name;
	/**
	 * Description of the tag
	 */
	protected String description;
	/**
	 * A reference to the tag's generator
	 */
	protected AbstractGenerator myGenerator;	
		
	/**
	 * Constructor.
	 * 
	 * @param name Name of the tag.
	 * @param description Description of the tag.
	 * @param myGenerator The generator of the tag.
	 */
	public AbstractTag(String name, String description, 
	  AbstractGenerator myGenerator) {
		this.name = name;
		this.description = description;
		this.myGenerator = myGenerator;
	}

	/**
	 * Method for generating code corresponding to the tag.
	 * 
	 * @param genPrinter A PrintStream object for output of the generated code.
	 */
	public abstract void generate(PrintStream genPrinter);
	
	/**
	 * Get the name of the tag.
	 * 
	 * @return The name of the tag.
	 */
	public String getName() {
		return name;
	}

	/**
	 * Get the description of the tag.
	 * 
	 * @return The description.
	 */
	public String getDescription() {
		return description;
	}

	/**
	 * Return a string composed of the name of the tag and its description.
	 */
	public String toString() {
		return "\'"+name+"\': " + description; 
	}
	
}