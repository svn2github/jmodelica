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


/** \file OptTag.java
 *  \brief OptTag class.
 */


package org.jmodelica.codegen;

import org.jmodelica.ast.*;

/**
 * C code generation tag for use with flattened Optimica models.
 *
 */
public abstract class OptTag extends AbstractTag {
	/**
	 * FClass object.
	 */
	protected FOptClass foptclass;
	
	/**
	 * Default constructor.
	 * 
	 * @param name Tag name.
	 * @param description Tag description.
	 * @param myGenerator The tag's generator.
	 * @param fclass An FOptClass object used as a basis in the code generation.
	 */
	public OptTag(String name, String description, 
	  AbstractGenerator myGenerator, FOptClass foptclass) {
		super(name,description,myGenerator);
		this.foptclass = foptclass;
	}
	
	/**
	 * Get the FOptClass object.
	 * @return The FOptClass object.
	 */
	public FOptClass getFOptClass() {
		return foptclass;
	}
}

