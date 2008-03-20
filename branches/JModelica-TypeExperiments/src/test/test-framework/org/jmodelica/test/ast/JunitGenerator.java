package org.jmodelica.test.ast;

public class JunitGenerator {
	protected TestSuite ts;
	
	public JunitGenerator(TestSuite ts) {
		this.ts = ts;
	}
	
	public JunitGenerator(String fileName, String className) {
		this.ts = new TestSuite(fileName,className);
	}
	
	public void dump(StringBuffer str) {
		ts.dump(str," ");
	}
	
	public static void main(String args[]) {
		/* The first argument is the name of the .mo file to
		 * generate a Junit test class from, the second argument is
		 * the name of the class in this file, and the final
		 * argument is the name of the directory in which
		 * the generated test class is stored.
		 */
		JunitGenerator jg = new JunitGenerator(args[0],args[1]);
		StringBuffer str = new StringBuffer();
		jg.ts.printTests(str);
		jg.ts.dumpJunit(args[0],args[2]);
		System.out.println(str.toString());
	}
}
