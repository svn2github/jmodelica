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


package org.jmodelica.test.ast;
import org.jmodelica.ast.*;
import org.jmodelica.parser.*;
import org.w3c.dom.Document;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;
import org.xml.sax.SAXException;

import java.io.IOException;
import java.io.Reader;
import java.io.FileReader;
import java.io.BufferedReader;
import java.io.File;
import java.io.FileWriter;
import java.util.ArrayList;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.ParserConfigurationException;
import javax.xml.xpath.XPath;
import javax.xml.xpath.XPathConstants;
import javax.xml.xpath.XPathExpression;
import javax.xml.xpath.XPathExpressionException;
import javax.xml.xpath.XPathFactory;

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
		loadOptions(sr);
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
		str.append("  static TestSuite ts;\n\n");
		
		str.append("  @BeforeClass public static void setUp() {\n");
		str.append("    ts = new TestSuite(\"" + testFile
				   + "\",\"" + getName() + "\");\n");
		str.append("  }\n\n");
		for (int i=0;i<l.size();i++) {
			get(i).dumpJunit(str,i);
		}
		str.append("  @AfterClass public static void tearDown() {\n");
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

	/**
	 * Loads the options set in the file options.xml. 
	 * 
	 * Assumes current location is install/lib and that options.xml is 
	 * located in install/Options.
	 * 
	 * @param sr
	 *            The source root belonging to the model for which the options
	 *            should be set.
	 */
	protected static void loadOptions(SourceRoot sr) {
		try {
			String sep = System.getProperty("file.separator");
			String filepath = System.getenv("JMODELICA_HOME")+sep+"Options"+sep+"options.xml";
			
			Document doc = parseAndGetDOM(filepath);
		
			XPathFactory factory = XPathFactory.newInstance();
			XPath xpath = factory.newXPath();
			
			//set modelica library
			XPathExpression expr = xpath.compile("/OptionRegistry/ModelicaLibrary");		
			Node modelicalib = (Node)expr.evaluate(doc, XPathConstants.NODE);
			if(modelicalib != null && modelicalib.hasChildNodes()) {
				//modelica lib set
				expr = xpath.compile("OptionRegistry/ModelicaLibrary/Name");
				String name = (String)expr.evaluate(doc,XPathConstants.STRING);
				
				expr = xpath.compile("OptionRegistry/ModelicaLibrary/Version");
				String version = (String)expr.evaluate(doc, XPathConstants.STRING);
				
				expr = xpath.compile("OptionRegistry/ModelicaLibrary/Path");
				String path = (String)expr.evaluate(doc, XPathConstants.STRING);
				
				sr.options.addModelicaLibrary(name, version, path);
			}
			
			//set other options if there are any
			expr = xpath.compile("OptionRegistry/Options");
			Node options = (Node)expr.evaluate(doc, XPathConstants.NODE);
			if(options !=null && options.hasChildNodes()) {
				//other options set
				
				//types
				expr = xpath.compile("OptionRegistry/Options/Option/Type");
				NodeList thetypes = (NodeList)expr.evaluate(doc, XPathConstants.NODESET);
				
				//keys
				expr = xpath.compile("OptionRegistry/Options/Option/*/Key");
				NodeList thekeys = (NodeList)expr.evaluate(doc, XPathConstants.NODESET);
				
				//values
				expr = xpath.compile("OptionRegistry/Options/Option/*/Value");
				NodeList thevalues = (NodeList)expr.evaluate(doc, XPathConstants.NODESET);
				
				for(int i=0; i<thetypes.getLength();i++) {
					Node n = thetypes.item(i);
					
					String type = n.getTextContent();
					String key = thekeys.item(i).getTextContent();
					String value = thevalues.item(i).getTextContent();
					
					if(type.equals("String")) {
						sr.options.setStringOption(key, value);
					} else if(type.equals("Integer")) {
						sr.options.setIntegerOption(key, Integer.parseInt(value));
					} else if(type.equals("Real")) {
						sr.options.setRealOption(key, Double.parseDouble(value));
					} else if(type.equals("Boolean")) {
						sr.options.setBooleanOption(key, Boolean.parseBoolean(value));
					}
				}				
			}
		
		} catch(SAXException e) {
			e.printStackTrace();
		} catch(IOException e) {
			e.printStackTrace();			
		} catch(ParserConfigurationException e) {
			e.printStackTrace();
		} catch(XPathExpressionException e) {
			e.printStackTrace();
		}
	}
	
	private static Document parseAndGetDOM(String xmlfile) throws ParserConfigurationException, IOException, SAXException{
		DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();
		factory.setIgnoringComments(true);
		factory.setIgnoringElementContentWhitespace(true);
		factory.setNamespaceAware(true);
		DocumentBuilder builder = factory.newDocumentBuilder();
		
		Document doc = builder.parse(new File(xmlfile));
		return doc;
	}


	
}
