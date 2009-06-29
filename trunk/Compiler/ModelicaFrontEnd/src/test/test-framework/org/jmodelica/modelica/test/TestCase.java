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


package org.jmodelica.modelica.test;

/**
 * @author jakesson
 *
 */
abstract public class TestCase {

	private String name;
	private String description;
	private String sourceFileName;
	private String className;

	public TestCase() {}
	
	/**
	 * @param name
	 * @param description
	 * @param sourceFileName
	 * @param className
	 */
	public TestCase(String name, 
			        String description, 
			        String sourceFileName,
			        String className) {
		super();
		this.name = name;
		this.description = description;
		this.sourceFileName = sourceFileName;
		this.className = className;
	}

	abstract public boolean testMe();
	
	abstract public void dump(StringBuffer str, String indent);
	
	abstract public void dumpJunit(StringBuffer str, int index);
	
	abstract public boolean printTest(StringBuffer str);
	
	/**
	 * @return the name
	 */
	public String getName() {
		return name;
	}

	/**
	 * @param name the name to set
	 */
	public void setName(String name) {
		this.name = name;
	}

	/**
	 * @return the description
	 */
	public String getDescription() {
		return description;
	}

	/**
	 * @param description the description to set
	 */
	public void setDescription(String description) {
		this.description = description;
	}

	/**
	 * @return the sourceFileName
	 */
	public String getSourceFileName() {
		return sourceFileName;
	}

	/**
	 * @param sourceFileName the sourceFileName to set
	 */
	public void setSourceFileName(String sourceFileName) {
		this.sourceFileName = sourceFileName;
	}

	/**
	 * @return the className
	 */
	public String getClassName() {
		return className;
	}

	/**
	 * @param className the className to set
	 */
	public void setClassName(String className) {
		this.className = className;
	}
	
	/**
	 * \brief Remove all whitespaces.
	 * @param str
	 * @return
	 */
	public String removeWhitespace(String str) {
		String str_res = str;
    	str_res = str_res.replaceAll("\\r", "");
    	str_res = str_res.replaceAll("\\n", "");
    	str_res = str_res.replaceAll(" ", "");
		return str_res;
	}

	
	
}
