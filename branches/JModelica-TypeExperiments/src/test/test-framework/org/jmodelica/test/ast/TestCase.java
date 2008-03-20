package org.jmodelica.test.ast;

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
	

}
