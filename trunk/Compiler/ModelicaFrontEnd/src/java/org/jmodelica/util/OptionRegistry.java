package org.jmodelica.util;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.PrintStream;
import java.util.HashMap;
import java.util.Map;
import java.util.Set;
import java.util.Iterator;

import javax.xml.parsers.ParserConfigurationException;
import javax.xml.xpath.XPathExpressionException;
import org.xml.sax.SAXException;


/**
 * OptionRegistry contains all options for the compiler. Options
 * can be created and retrieved based on type: String, Integer etc.
 * OptionRegistry also provides methods for handling paths
 * to Modelica libraries.
 */
public class OptionRegistry {
	
		private enum DefOpt {
			MSL_VER    ("default_msl_version", ""),
			START_FIX  ("state_start_values_fixed", 
					"This option enables the user to specify if initial equations should be " + 
					"generated automatically for differentiated variables even though the fixed " +
					"attribute is equal to fixed. Setting this option to true is, however, often " +
					"practical in optimization problems."),
			ELIM_ALIAS ("eliminate_alias_variables", 
					"If this option is set to true (default), then alias variables are " +
                    "eliminated from the model."),
			HALT_WARN  ("halt_on_warning", 
					"If this option is set to false (default) one or more compiler " +
                    "warnings will not stop compilation of the model."),
			XML_EQU    ("generate_xml_equations", 
					"If this option is true, then model equations are generated in XML format. " + 
					"Default is false."),
			INDEX_RED  ("index_reduction", 
					"If this option is true (default is false), index reduction is performed."),
			EQU_SORT   ("equation_sorting", 
					"If this option is true (default is false), equations are sorted using the BLT algorithm."),
			XML_FMI    ("generate_fmi_xml", 
					"If this option is true the model description part of the XML variables file " + 
					"will be FMI compliant. Default is false. To generate an XML which will " + 
					"validate with FMI schema the option generate_xml_equations must also be false."),
			VAR_SCALE  ("enable_variable_scaling", 
					"If this option is true (default is false), then the \"nominal\" attribute will " + 
					"be used to scale variables in the model.");
			
			public String key;
			public String desc;
			
			private DefOpt(String k, String d) {
				key = k;
				desc = d;
			}
		}

		private HashMap<String,Option> optionsMap;
		
		public OptionRegistry() {
			optionsMap = new HashMap<String,Option>();
			
			// Fill registry with default options
			defaultStringOption(DefOpt.MSL_VER,     "3.0.1");
			defaultBooleanOption(DefOpt.START_FIX,  false);
			defaultBooleanOption(DefOpt.ELIM_ALIAS, true);
			defaultBooleanOption(DefOpt.HALT_WARN,  false);
			defaultBooleanOption(DefOpt.XML_EQU,    false);
			defaultBooleanOption(DefOpt.INDEX_RED,  false);
			defaultBooleanOption(DefOpt.EQU_SORT,   false);
			defaultBooleanOption(DefOpt.XML_FMI,    false);
			defaultBooleanOption(DefOpt.VAR_SCALE,  false);
		}

		public OptionRegistry(OptionRegistry registry) {
			this();
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
				expr = xpath.compile("OptionRegistry/Options/Option");
				org.w3c.dom.NodeList theOptions = (org.w3c.dom.NodeList)expr.evaluate(doc, javax.xml.xpath.XPathConstants.NODESET);
				expr = xpath.compile("OptionRegistry/Options/Option/*");
				org.w3c.dom.NodeList theAttributes = (org.w3c.dom.NodeList)expr.evaluate(doc, javax.xml.xpath.XPathConstants.NODESET);
				
				for(int i=0; i<theOptions.getLength();i++) {
					org.w3c.dom.Node n = theOptions.item(i);
					org.w3c.dom.NamedNodeMap attributes = n.getAttributes();					
					String type = attributes.getNamedItem("type").getTextContent();
					
					org.w3c.dom.Node a = theAttributes.item(i);
					attributes = a.getAttributes();
					String key = attributes.getNamedItem("key").getTextContent();
					String value = attributes.getNamedItem("value").getTextContent();
					
					String description;
					// description
					expr = xpath.compile("/OptionRegistry/Options/Option/*/Description[parent::*/parent::Option[attribute::type=\""+type+"\"]][parent::*[attribute::key=\""+key+"\"]]");
					org.w3c.dom.Node descr = (org.w3c.dom.Node)expr.evaluate(doc, javax.xml.xpath.XPathConstants.NODE);
					description = descr != null ? descr.getTextContent().trim():"";
					
					if(type.equals("string")) {
						setStringOption(key, value, description);
					} else if(type.equals("integer")) {
						setIntegerOption(key, Integer.parseInt(value), description);
					} else if(type.equals("real")) {
						setRealOption(key, Double.parseDouble(value), description);
					} else if(type.equals("boolean")) {
						setBooleanOption(key, Boolean.parseBoolean(value), description);
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
		
		/**
		 * \brief Export all options as XML.
		 * 
		 * @param out  the stream to write to
		 */
		public void exportXML(PrintStream out) {
			out.print("<OptionsRegistry>\n\t<Options>\n");
			for (Option o : optionsMap.values())
				o.exportXML(out);
			out.print("\t</Options>\n</OptionsRegistry>\n");
		}
		
		/**
		 * \brief Export all options as an XML file.
		 * 
		 * @param name  the name of the file to write to
		 * @throws FileNotFoundException  if the file cannot be opened
		 */
		public void exportXML(String name) throws FileNotFoundException {
			FileOutputStream out = new FileOutputStream(name);
			exportXML(new PrintStream(out));
			try {
				out.close();
			} catch (IOException e) {
			}
		}
		
		protected void createIntegerOption(String key, String description,
				int defaultValue) {
			optionsMap.put(key,new IntegerOption(key, description,
					defaultValue));			
		}
		
		protected void defaultIntegerOption(DefOpt o, int defaultValue) {
			createIntegerOption(o.key, o.desc, defaultValue);		
		}
		
		public void setIntegerOption(String key, int value, String description) {
			Option o = optionsMap.get(key);
			if (o == null) {
				createIntegerOption(key, description, value);
			} else if (o instanceof IntegerOption) {
				((IntegerOption)o).setValue(value);
			} else {
				throw new UnknownOptionException("Option: "+key +" is not of " +
						"integer type");
			}			
		}
		
		public void setIntegerOption(String key, int value) {
			setIntegerOption(key, value, "");
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
		
		protected void defaultStringOption(DefOpt o, String defaultValue) {
			createStringOption(o.key, o.desc, defaultValue);		
		}
		
		public void setStringOption(String key, String value, String description) {
			Option o = optionsMap.get(key);
			if (o == null) {
				createStringOption(key, description, value);
			} else if (o instanceof StringOption) {
				((StringOption)o).setValue(value);
			} else {
				throw new UnknownOptionException("Option: "+key +" is not of " +
						"string type");
			}			
		}
		
		public void setStringOption(String key, String value) {
			setStringOption(key, value, "");
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
		
		protected void defaultRealOption(DefOpt o, double defaultValue) {
			createRealOption(o.key, o.desc, defaultValue);		
		}
		
		public void setRealOption(String key, double value, String description) {
			Option o = optionsMap.get(key);
			if (o == null) {
				createRealOption(key, description, value);
			} else if (o instanceof RealOption) {
				((RealOption)o).setValue(value);
			} else {
				throw new UnknownOptionException("Option: "+key +" is not of " +
						"real type");
			}			
		}

		public void setRealOption(String key, double value) {
			setRealOption(key, value, "");
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
		
		protected void defaultBooleanOption(DefOpt o, boolean defaultValue) {
			createBooleanOption(o.key, o.desc, defaultValue);		
		}
		
		public void setBooleanOption(String key, boolean value, String description) {
			Option o = optionsMap.get(key);
			if (o == null) {
				createBooleanOption(key, description, value);
			} else if (o instanceof BooleanOption) {
				((BooleanOption)o).setValue(value);
			} else {
				throw new UnknownOptionException("Option: "+key +" is not of " +
						"boolean type");
			}			
		}

		public void setBooleanOption(String key, boolean value) {
			setBooleanOption(key, value, "");
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
		
		public String getDescription(String key){
			Option o = optionsMap.get(key);
			if(o == null) {
				throw new UnknownOptionException("Unknown option: "+key);
			}
			return o.getDescription();
		}
		
		public Set<Map.Entry<String, Option>> getAllOptions() {
			return optionsMap.entrySet();
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

		/**
		 * \brief Make the first letter in a string capital.
		 */
		public static Object capitalize(String str) {
			return str.substring(0, 1).toUpperCase() + str.substring(1);
		}

		public static String wrap(String str, String prefix, int width) {
			StringBuilder buf = new StringBuilder();
			int start = 0;
			int end = start + width;
			int len = str.length();
			while (end < len) {
				while (end > start && !Character.isWhitespace(str.charAt(end)))
					end--;
				if (end <= start)
					end = start + width;
				buf.append(prefix);
				buf.append(str.substring(start, end));
				buf.append('\n');
				start = end + 1;
				end = start + width;
			}
			buf.append(prefix);
			buf.append(str.substring(start));
			buf.append('\n');
			return buf.toString();
		}
	
	abstract static class Option {
		protected String key;
		protected String description;
			
		public Option(String key, String description) {
			this.key = key;
			this.description = description;
		}
	
		public void exportXML(PrintStream out) {
			String type = getType();
			String tag = capitalize(type) + "Attributes";
			String attrs = String.format("\t\t\t<%s key=\"%s\" value=\"%s\"", tag, key, getValueString());
			out.print(String.format("\t\t<Option type=\"%s\">\n", type));
			out.print(attrs);
//			if (description == null || description.isEmpty()) {
			if (description == null || description.equals("")) {
				out.print("/>\n");
			} else {
				out.print(">\n\t\t\t\t<Description>\n");
				out.print(wrap(description, "\t\t\t\t\t", 80));
				out.print("\t\t\t\t</Description>\n\t\t\t</");
				out.print(tag);
				out.print(">\n");
			}
			out.print("\t\t</Option>\n");
		}
		
		public abstract String getType();
		public abstract String getValueString();

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
	
	static class IntegerOption extends Option {
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

		@Override
		public String getType() {
			return "integer";
		}

		@Override
		public String getValueString() {
			return Integer.toString(value);
		}
	}

	static class StringOption extends Option {
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

		@Override
		public String getType() {
			return "string";
		}

		@Override
		public String getValueString() {
			return value;
		}
	}

	static class RealOption extends Option {
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

		@Override
		public String getType() {
			return "real";
		}

		@Override
		public String getValueString() {
			return Double.toString(value);
		}
	}

	static class BooleanOption extends Option {
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

		@Override
		public String getType() {
			return "boolean";
		}
		
		@Override
		public String getValueString() {
			return Boolean.toString(value);
		}
	}
	
	public static class UnknownOptionException extends RuntimeException { 
		
		/**
		 * 
		 */
		private static final long serialVersionUID = 3884972549318063140L;

		public UnknownOptionException(String message) {
			super(message);
		}		
	}
}
