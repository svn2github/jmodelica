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


/** \file DAETag.java
 *  \brief DAETag class.
 */


package org.jmodelica.modelica.codegen;

import org.jmodelica.modelica.ast.*;

/**
 * A tag class intended for use as base class for tags using the DAE
 * interface.
 *
 */
public abstract class DAETag extends AbstractTag {
	/**
	 * FClass object.
	 */
	protected FClass fclass;
	
	/**
	 * Default constructor.
	 * 
	 * @param name Tag name.
	 * @param description Tag description.
	 * @param myGenerator The tag's generator.
	 * @param fclass An FClass object used as a basis in the code generation.
	 */
	public DAETag(String name, String description, 
	  AbstractGenerator myGenerator, FClass fclass) {
		super(name,description,myGenerator);
		this.fclass = fclass;
	}
	
	/**
	 * Get the FClass object.
	 * @return The FClass object.
	 */
	public FClass getFClass() {
		return fclass;
	}
}

