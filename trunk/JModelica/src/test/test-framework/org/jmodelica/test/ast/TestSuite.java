package org.jmodelica.test.ast;
import org.jmodelica.ast.*;
import org.jmodelica.parser.*;

import java.io.IOException;
import java.io.Reader;
import java.io.FileReader;
import java.io.BufferedReader;
import java.io.File;
import java.io.FileWriter;
import java.util.ArrayList;

public class TestSuite {
	String name;
	private ArrayList<TestCase> l;

	public TestSuite() {
		l = new ArrayList<TestCase>();
	}

	public TestSuite(String fileName, String className) {
		name = className;
		l = new ArrayList<TestCase>();
		ModelicaParser parser = new ModelicaParser();
		SourceRoot sr = (SourceRoot)parser.parseFile(fileName);
		sr.collectTestCases(this,className);
	}

	public void dump(StringBuffer str,String indent) {
		str.append(indent+"TestSuite: " + name + "\n");
		for (int i=0;i<l.size();i++) {
			get(i).dump(str,indent+" ");
			str.append("\n");
		}
	}

	public boolean printTests(StringBuffer str) {
		int numFail = 0;
		str.append("TestSuite: " + name + "\n");
		for (int i=0;i<l.size();i++) {
			if (!get(i).printTest(str))
				numFail++;
		}
		str.append("Summary: ");
		if (numFail==0)
			str.append("All tests in test suite passed\n");
		else
			str.append(numFail + " of " + l.size() +" test in test suite failed\n");
		return numFail==0;
	}
	
	public void dumpJunit(String testFile, String dir) {
		StringBuffer str = new StringBuffer();
		str.append("package org.jmodelica.test.junitgenerated;\n\n");
		str.append("import org.junit.*;\n");
		str.append("import static org.junit.Assert.*;\n");
		str.append("import org.jmodelica.test.ast.*;\n");
		str.append("\n");
		str.append("public class " + name + " {\n\n");
		str.append("  TestSuite ts;\n\n");
		
		str.append("  @Before public void setUp() {\n");
		str.append("    ts = new TestSuite(\"" + testFile
				   + "\",\"" + getName() + "\");\n");
		str.append("  }\n\n");
		for (int i=0;i<l.size();i++) {
			get(i).dumpJunit(str,i);
		}
		str.append("  @After public void tearDown() {\n");
		str.append("    ts = null;\n");
		str.append("  }\n\n");
		str.append("}\n\n");
		
		File file = new File(dir+"/"+getName()+".java");
		try {
			FileWriter writer = new FileWriter(file);
			writer.append(str.toString());
			writer.close();
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}
	
	public void add(TestCase tc) {
		l.add(tc);
	}

	public TestCase get(int i) {
		return l.get(i);
	}

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

}
