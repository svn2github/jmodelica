package org.jmodelica.util;

import java.io.File;
import java.io.IOException;
import java.util.HashMap;
import java.util.Map;
import java.util.Set;
import java.util.Iterator;

import javax.xml.parsers.ParserConfigurationException;
import javax.xml.xpath.XPathExpressionException;
import org.xml.sax.SAXException;


/**
 * OptionRegistry contains all options for the compiler. Options
 * can be created and retreived based on type: String, Integer etc.
 * OptionRegistry also provides methods for handling paths
 * to Modelica libraries.
 */
public class OptionRegistry {

		private HashMap<String,Option> optionsMap;
		
		public OptionRegistry() {
			optionsMap = new HashMap<String,Option>();
		}

		public OptionRegistry(OptionRegistry registry) {
			optionsMap = new HashMap<String,Option>();
			copyAllOptions(registry);
		}
		
		public OptionRegistry(String filepath) throws XPathExpressionException, ParserConfigurationException, IOException, SAXException {
			this();
			loadOptions(filepath);
		}
		
	 	private void loadOptions(String filepath) throws ParserConfigurationException, IOException, SAXException, XPathExpressionException {
			//logger.info("Loading options...");
			org.w3c.dom.Document doc = parseAndGetDOM(filepath);
			
			javax.xml.xpath.XPathFactory factory = javax.xml.xpath.XPathFactory.newInstance();
			javax.xml.xpath.XPath xpath = factory.newXPath();
				
			javax.xml.xpath.XPathExpression expr;
				
			//set other options if there are any
			expr = xpath.compile("OptionRegistry/Options");
			org.w3c.dom.Node options = (org.w3c.dom.Node)expr.evaluate(doc, javax.xml.xpath.XPathConstants.NODE);
			if(options !=null && options.hasChildNodes()) {
				//other options set
					
				//types
				expr = xpath.compile("OptionRegistry/Options/Option/Type");
				org.w3c.dom.NodeList thetypes = (org.w3c.dom.NodeList)expr.evaluate(doc, javax.xml.xpath.XPathConstants.NODESET);
					
				//keys
				expr = xpath.compile("OptionRegistry/Options/Option/*/Key");
				org.w3c.dom.NodeList thekeys = (org.w3c.dom.NodeList)expr.evaluate(doc, javax.xml.xpath.XPathConstants.NODESET);
					
				//values
				expr = xpath.compile("OptionRegistry/Options/Option/*/Value");
				org.w3c.dom.NodeList thevalues = (org.w3c.dom.NodeList)expr.evaluate(doc, javax.xml.xpath.XPathConstants.NODESET);
					
				for(int i=0; i<thetypes.getLength();i++) {
					org.w3c.dom.Node n = thetypes.item(i);
					
					String type = n.getTextContent();
					String key = thekeys.item(i).getTextContent();
					String value = thevalues.item(i).getTextContent();
					if(type.equals("String")) {
						setStringOption(key, value);
					} else if(type.equals("Integer")) {
						setIntegerOption(key, Integer.parseInt(value));
					} else if(type.equals("Real")) {
						setRealOption(key, Double.parseDouble(value));
					} else if(type.equals("Boolean")) {
						setBooleanOption(key, Boolean.parseBoolean(value));
					}
				}				
			}	
	 	}
	 	
		/**
		 * Parses an XML file and returns the DOM document instance.
		 * 
		 * @param xmlfile
		 *            The XML file to be parsed.
		 * 
		 * @return The DOM document object.
		 * 
		 * @throws ParserConfigurationException
		 *             If a parser configuration error has occured.
		 * @throws IOException
		 *             If an IO error occurs.
		 * @throws SAXException
		 *             If an error with the parsing occurs.
		 */
		private org.w3c.dom.Document parseAndGetDOM(String xmlfile) 
			throws javax.xml.parsers.ParserConfigurationException, IOException, org.xml.sax.SAXException{
			javax.xml.parsers.DocumentBuilderFactory factory = javax.xml.parsers.DocumentBuilderFactory.newInstance();
			factory.setIgnoringComments(true);
			factory.setIgnoringElementContentWhitespace(true);
			factory.setNamespaceAware(true);
			javax.xml.parsers.DocumentBuilder builder = factory.newDocumentBuilder();		
			org.w3c.dom.Document doc = builder.parse(new File(xmlfile));
			return doc;
		}

		
		protected void createIntegerOption(String key, String description,
				int defaultValue) {
			optionsMap.put(key,new IntegerOption(key, description,
					defaultValue));			
		}
		
		public void setIntegerOption(String key, int value) {
			Option o = optionsMap.get(key);
			if (o == null) {
				createIntegerOption(key, "IntegerOption", value);
			} else if (o instanceof IntegerOption) {
				((IntegerOption)o).setValue(value);
			} else {
				throw new UnknownOptionException("Option: "+key +" is not of " +
						"integer type");
			}			
		}

		public int getIntegerOption(String key) {
			Option o = optionsMap.get(key);
			if (o == null) {
				throw new UnknownOptionException("Unknown option: "+key);
			} else if (o instanceof IntegerOption) {
				return ((IntegerOption)o).getValue();
			} else {
				throw new UnknownOptionException("Option: "+key +" is not of " +
						"integer type");
			}
		}

		protected void createStringOption(String key, String description,
				String defaultValue) {
			optionsMap.put(key,new StringOption(key, description,
					defaultValue));			
		}
		
		public void setStringOption(String key, String value) {
			Option o = optionsMap.get(key);
			if (o == null) {
				createStringOption(key, "StringOption", value);
			} else if (o instanceof StringOption) {
				((StringOption)o).setValue(value);
			} else {
				throw new UnknownOptionException("Option: "+key +" is not of " +
						"string type");
			}			
		}

		public String getStringOption(String key) {
			Option o = optionsMap.get(key);
			if (o == null) {
				throw new UnknownOptionException("Unknown option: "+key);
			} else if (o instanceof StringOption) {
				return ((StringOption)o).getValue();
			} else {
				throw new UnknownOptionException("Option: "+key +" is not of " +
						"string type");
			}
		}
		
		protected void createRealOption(String key, String description,
				double defaultValue) {
			optionsMap.put(key,new RealOption(key, description,
					defaultValue));			
		}
		
		public void setRealOption(String key, double value) {
			Option o = optionsMap.get(key);
			if (o == null) {
				createRealOption(key, "RealOption", value);
			} else if (o instanceof RealOption) {
				((RealOption)o).setValue(value);
			} else {
				throw new UnknownOptionException("Option: "+key +" is not of " +
						"real type");
			}			
		}

		public double getRealOption(String key) {
			Option o = optionsMap.get(key);
			if (o == null) {
				throw new UnknownOptionException("Unknown option: "+key);
			} else if (o instanceof RealOption) {
				return ((RealOption)o).getValue();
			} else {
				throw new UnknownOptionException("Option: "+key +" is not of " +
						"real type");
			}
		}
		
		protected void createBooleanOption(String key, String description,
				boolean defaultValue) {
			optionsMap.put(key,new BooleanOption(key, description,
					defaultValue));			
		}
		
		public void setBooleanOption(String key, boolean value) {
			Option o = optionsMap.get(key);
			if (o == null) {
				createBooleanOption(key, "BooleanOption", value);
			} else if (o instanceof BooleanOption) {
				((BooleanOption)o).setValue(value);
			} else {
				throw new UnknownOptionException("Option: "+key +" is not of " +
						"boolean type");
			}			
		}

		public boolean getBooleanOption(String key) {
			Option o = optionsMap.get(key);
			if (o == null) {
				throw new UnknownOptionException("Unknown option: "+key);
			} else if (o instanceof BooleanOption) {
				return ((BooleanOption)o).getValue();
			} else {
				throw new UnknownOptionException("Option: "+key +" is not of " +
						"boolean type");
			}
		}
		
		public Set<Map.Entry<String, Option>> getAllOptions() {
			return this.optionsMap.entrySet();
		}
		
		public void copyAllOptions(OptionRegistry registry) throws UnknownOptionException{
			// copy all options in parameter registry to this 
			// optionregistry and overwrite if exists before.
			Set<Map.Entry<String, Option>> set = registry.getAllOptions();
			Iterator<Map.Entry<String, Option>> itr = set.iterator();
			//iterate over all Map.entry
			while(itr.hasNext()) {
				Map.Entry<String, Option> entry = itr.next();
				String key = entry.getKey();
				Option o = entry.getValue();
				if(o instanceof StringOption) {
					setStringOption(key, ((StringOption) o).getValue());
				} else if(o instanceof IntegerOption) {
					setIntegerOption(key, ((IntegerOption) o).getValue());
				} else if(o instanceof RealOption) {
					setRealOption(key, ((RealOption) o).getValue());
				} else if(o instanceof BooleanOption) {
					setBooleanOption(key, ((BooleanOption) o).getValue());
				} else {
					throw new UnknownOptionException(
							"Trying to copy unknown option with key: "+key+
							" and description "+o.getDescription());
				}
			}			
		}
	
	class Option {
		protected String key;
		protected String description;
			
		public Option(String key, String description) {
			this.key = key;
			this.description = description;
		}
	
		public String getKey() {
			return key;
		}

		public String getDescription() {
			return description;
		}
	
		public String toString() {
			return "\'"+key+"\': " + description; 
		}
		
	}
	
	class IntegerOption extends Option {
		protected int value;
		
		public IntegerOption(String key, String description, int value) {
			super(key, description);
			this.value = value;
		}
		
		public void setValue(int value) {
			this.value = value;
		}
		
		public int getValue() {
			return value;
		}
	}

	class StringOption extends Option {
		protected String value;
		
		public StringOption(String key, String description, String value) {
			super(key,description);
			this.value = value;
		}
		
		public void setValue(String value) {
			this.value = value;
		}
		
		public String getValue() {
			return value;
		}
	}

	class RealOption extends Option {
		protected double value;
		
		public RealOption(String key, String description, double value) {
			super(key, description);
			this.value = value;
		}
		
		public void setValue(double value) {
			this.value = value;
		}
		
		public double getValue() {
			return value;
		}
	}

	class BooleanOption extends Option {
		protected boolean value;
		
		public BooleanOption(String key, String description, boolean value) {
			super(key, description);
			this.value = value;
		}
		
		public void setValue(boolean value) {
			this.value = value;
		}
		
		public boolean getValue() {
			return value;
		}
	}
	
	public class UnknownOptionException extends RuntimeException { 
		
		/**
		 * 
		 */
		private static final long serialVersionUID = 3884972549318063140L;

		public UnknownOptionException(String message) {
			super(message);
		}		
	}
}
