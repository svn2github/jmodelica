
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

/** \file XMLGenerator.java
*  \brief XMLGenerator class.
*/

package org.jmodelica.codegen;

import java.io.PrintStream;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Stack;

import org.jmodelica.ast.FBooleanVariable;
import org.jmodelica.ast.FClass;
import org.jmodelica.ast.FIntegerVariable;
import org.jmodelica.ast.FRealVariable;
import org.jmodelica.ast.FStringVariable;
import org.jmodelica.ast.FVariable;
import org.jmodelica.ast.Printer;

/**
 * A generator class for XML code generation which takes a model described by
 * <FClass> and provides an XML document for the meta-data in the model. Uses a
 * template for the static general structure of tags and an internal class
 * <TagGenerator> for the parts of the XML that are dynamic, that is, may vary
 * depending on the contents of the underlying model.
 * 
 * @see AbstractGenerator
 * 
 */
public class XMLGenerator extends GenericGenerator {
		
	class DAETag_XML_modelName extends DAETag {
		
		public DAETag_XML_modelName(
		  AbstractGenerator myGenerator, FClass fclass) {
			super("XML_modelName","Model name.",
			  myGenerator,fclass);
		}
	
		public void generate(PrintStream genPrinter) {
			genPrinter.print(fclass.name());
		}
	}
	
	class DAETag_XML_modelIdentifier extends DAETag {
		
		public DAETag_XML_modelIdentifier(
		  AbstractGenerator myGenerator, FClass fclass) {
			super("XML_modelIdentifier","Model identifier.",
			  myGenerator,fclass);
		}
	
		public void generate(PrintStream genPrinter) {
			//TODO: implement when available
			// Dummy value for now
			genPrinter.print("ModelId");
		}
	}
	
	class DAETag_XML_modelDescription extends DAETag {
		
		public DAETag_XML_modelDescription(
		  AbstractGenerator myGenerator, FClass fclass) {
			super("XML_modelDescription","Model description.",
			  myGenerator,fclass);
		}
	
		public void generate(PrintStream genPrinter) {
			//TODO: implement when available
			// Dummy value for now
			genPrinter.print("A description of the model.");
		}
	}
	
	class DAETag_XML_modelAuthor extends DAETag {
		
		public DAETag_XML_modelAuthor(
		  AbstractGenerator myGenerator, FClass fclass) {
			super("XML_modelAuthor","The author of the model.",
			  myGenerator,fclass);
		}
	
		public void generate(PrintStream genPrinter) {
			//TODO: implement when available
			// Dummy value for now
			genPrinter.print("Model author");
		}
	}

	class DAETag_XML_modelVersion extends DAETag {
		
		public DAETag_XML_modelVersion(
		  AbstractGenerator myGenerator, FClass fclass) {
			super("XML_modelVersion","Model version.",
			  myGenerator,fclass);
		}
	
		public void generate(PrintStream genPrinter) {
			//TODO: implement when available
			// Dummy value for now
			genPrinter.print("Model version nbr: 1");
		}
	}

	class DAETag_XML_schemaVersion extends DAETag {
		
		public DAETag_XML_schemaVersion(
		  AbstractGenerator myGenerator, FClass fclass) {
			super("XML_schemaVersion","Schema version.",
			  myGenerator,fclass);
		}
	
		public void generate(PrintStream genPrinter) {
			//TODO: implement when available
			// Dummy value for now
			genPrinter.print("Schema version nbr: 1");
		}
	}

	class DAETag_XML_generationTool extends DAETag {
		
		public DAETag_XML_generationTool (
		  AbstractGenerator myGenerator, FClass fclass) {
			super("XML_generationTool","Generation tool.",
			  myGenerator,fclass);
		}
	
		public void generate(PrintStream genPrinter) {
			//TODO: implement when available
			// Dummy value for now
			genPrinter.print("The generation tool");
		}
	}

	class DAETag_XML_generationDate extends DAETag {
		private static final String df = "yyyy-MM-dd'T'HH:mm:ss";
		
		public DAETag_XML_generationDate (
		  AbstractGenerator myGenerator, FClass fclass) {
			super("XML_generationDate","Generation date.",
			  myGenerator,fclass);
		}
	
		public void generate(PrintStream genPrinter) {
			//TODO: implement when available
			// Todays date for now
			SimpleDateFormat dateformat = new SimpleDateFormat(df);
			genPrinter.print(dateformat.format(new Date()));
		}
	}
	
	class DAETag_XML_guid extends DAETag {
		
		public DAETag_XML_guid (
		  AbstractGenerator myGenerator, FClass fclass) {
			super("XML_guid","The Globally Unique Identifier.",
			  myGenerator,fclass);
		}
	
		public void generate(PrintStream genPrinter) {
			//TODO: implement when available
			// Dummy value for now
			genPrinter.print("Global id");
		}
	}


	class DAETag_XML_modelVariables extends DAETag {
		
		public DAETag_XML_modelVariables(
		  AbstractGenerator myGenerator, FClass fclass) {
			super("XML_variables","Model variables. (Optional)",
			  myGenerator,fclass);
		}
	
		
		public void generate(PrintStream genPrinter) {
			TagGenerator tg = new TagGenerator(2);
			
			for(FVariable variable:fclass.getFVariables()) {				
				genPrinter.print(tg.generateTag("ScalarVariable"));
				
				//ScalarVariableName
				genPrinter.print(tg.generateTag("ScalarVariableName")+variable.name()+tg.generateTag("ScalarVariableName"));
				
				//ValueReference
				genPrinter.print(tg.generateTag("ValueReference")+variable.valueReference()+tg.generateTag("ValueReference"));
				
				//Description (optional)
				if(variable.hasFStringComment()) {
					genPrinter.print(tg.generateTag("Description")+variable.getFStringComment()+tg.generateTag("Description"));
				}
				
				//Private/Protected (Optional)
				genPrinter.print(tg.generateTag("Protected")+variable.isProtected()+tg.generateTag("Protected"));
				
				//DataType
				genPrinter.print(tg.generateTag("DataType"));
				if(variable.isReal()) {
					genPrinter.print("Real");
				} else if(variable.isInteger()) {
					genPrinter.print("Integer");
				} else if(variable.isBoolean()) {
					genPrinter.print("Boolean");
				} else if(variable.isString()) {
					genPrinter.print("String");
				} else if(false) {
//					TODO: Enumeration variable
				}
				 else {
					//TODO: errorhandling
					System.err.println("Invalid or missing DataType");
				}
				genPrinter.print(tg.generateTag("DataType"));
				
				//Attributes
				genPrinter.print(tg.generateTag("Attributes"));

				if(variable.isReal()) {
					FRealVariable realvariable=(FRealVariable)variable;
						
					genPrinter.print(tg.generateTag("RealAttributes"));
					
					//quantity
					if(variable.quantityAttributeSet()) {
						genPrinter.print(tg.generateTag("Quantity")+variable.quantityAttribute()+tg.generateTag("Quantity"));
					}
					//unit
					if(realvariable.unitAttributeSet()) {
						genPrinter.print(tg.generateTag("Unit")+realvariable.unitAttribute()+tg.generateTag("Unit"));
					}
					//default display unit
					if(realvariable.displayUnitAttributeSet()) {
						genPrinter.print(tg.generateTag("DefaultDisplayUnit"));
						genPrinter.print(tg.generateTag("DisplayUnit")+realvariable.displayUnitAttribute()+tg.generateTag("DisplayUnit"));
						//TODO:this is default value
						genPrinter.print(tg.generateTag("Gain")+1.0+tg.generateTag("Gain"));
						//TODO:offset(optional)
						genPrinter.print(tg.generateTag("DefaultDisplayUnit"));
					}
					//min
					if(realvariable.minAttributeSet()) {
						genPrinter.print(tg.generateTag("Min")+realvariable.minAttribute()+tg.generateTag("Min"));
					}
					//max
					if(realvariable.maxAttributeSet()) {
						genPrinter.print(tg.generateTag("Max")+realvariable.maxAttribute()+tg.generateTag("Max"));
					}
					//start attribute should always be set
					if(realvariable.isParameter() && realvariable.hasBindingExp()) {
						genPrinter.print(tg.generateTag("Start")+realvariable.getBindingExp().ceval().realValue()+tg.generateTag("Start"));
					}
					else {
						genPrinter.print(tg.generateTag("Start") +realvariable.startAttribute()+tg.generateTag("Start"));
					}						
					//nominal
					if(realvariable.nominalAttributeSet()) {
						genPrinter.print(tg.generateTag("Nominal")+realvariable.nominalAttribute()+tg.generateTag("Nominal"));
					}
					//category
					genPrinter.print(tg.generateTag("Category"));
					if(realvariable.isDifferentiatedVariable()) {
						genPrinter.print("derivative");
					} else if(false) {
						//TODO: state variable
					} else {
						//default is algebraic
						genPrinter.print("algebraic");
					}
					genPrinter.print(tg.generateTag("Category"));
					
					genPrinter.print(tg.generateTag("RealAttributes"));
					
				} else if(variable.isInteger()) {
					FIntegerVariable integervariable = (FIntegerVariable)variable;
					
					genPrinter.print(tg.generateTag("IntegerAttributes"));
					
					//quantity
					if(integervariable.quantityAttributeSet()) {
						genPrinter.print(tg.generateTag("Quantity")+integervariable.quantityAttribute()+tg.generateTag("Quantity"));
					}					
					//min
					if(integervariable.minAttributeSet()) {
						genPrinter.print(tg.generateTag("Min")+integervariable.minAttribute()+tg.generateTag("Min"));
					}
					//max
					if(integervariable.maxAttributeSet()) {
						genPrinter.print(tg.generateTag("Max")+integervariable.maxAttribute()+tg.generateTag("Max"));
					}
					//start
					if(integervariable.startAttributeSet()) {
						genPrinter.print(tg.generateTag("Start")+integervariable.startAttribute()+tg.generateTag("Start"));
					}						
					genPrinter.print(tg.generateTag("IntegerAttributes"));
						
				} else if(variable.isBoolean()) {
					genPrinter.print(tg.generateTag("BooleanAttributes"));
					//start attribute
					if(variable.startAttributeSet()) {
						genPrinter.print(tg.generateTag("Start")+((FBooleanVariable)variable).startAttribute()+tg.generateTag("Start"));
					}
					genPrinter.print(tg.generateTag("BooleanAttributes"));
					
				} else if(variable.isString()) {
					genPrinter.print(tg.generateTag("StringAttributes"));
					//start attribute
					if(variable.startAttributeSet()) {
						genPrinter.print(tg.generateTag("Start")+((FStringVariable)variable).startAttribute()+tg.generateTag("Start"));
					}
					genPrinter.print(tg.generateTag("StringAttributes"));
					
				} else if(false){
					//TODO: Enumeration
					genPrinter.print(tg.generateTag("EnumerationAttributes"));
					//startattribute
					if(variable.startAttributeSet()) {
						//TODO:evaluate attribute
						// Dummy value for now
						genPrinter.print(tg.generateTag("Start")+1+tg.generateTag("Start"));
					}						
					genPrinter.print(tg.generateTag("EnumerationAttributes"));
				} 
				else {
					//TODO: errorhandling
					System.err.println("Invalid or missing variable type");
				}
				
				genPrinter.print(tg.generateTag("Attributes"));
				
				//Variability (optional with default)
				genPrinter.print(tg.generateTag("Variability"));
				if(variable.isConstant()) {
					genPrinter.print("constant");
				} else if(variable.isParameter()) {
					genPrinter.print("parameter");
				} else if(variable.isContinuous()) {
					genPrinter.print("continuous");
				} else {
					//default
					genPrinter.print("discrete");
				}
				genPrinter.print(tg.generateTag("Variability"));
				
				//Causality (optional with default)
				genPrinter.print(tg.generateTag("Causality"));
				if(variable.isInput()) {
					genPrinter.print("input");
				} else if(variable.isOutput()) {
					genPrinter.print("output");
				} else {
					//default
					genPrinter.print("internal");
				}				
				genPrinter.print(tg.generateTag("Causality"));
				
				genPrinter.print(tg.generateTag("ScalarVariable"));
			}
			
		}

	}
	
	class DAETag_XML_defaultExperiment extends DAETag {
		
		public DAETag_XML_defaultExperiment(
		  AbstractGenerator myGenerator, FClass fclass) {
			super("XML_defaultExperiment","Default experiment (optional).",
			  myGenerator,fclass);
		}
	
		public void generate(PrintStream genPrinter) {
			//TODO: default experiment (optional)
//				genPrinter.print("<DefaultExperiment>");
//				genPrinter.print("\n\t\t TODO (optional element)");
//				genPrinter.print("\n\t </DefaultExperiment>");
		}
	}

	class DAETag_XML_vendorAnnotations extends DAETag {
		
		public DAETag_XML_vendorAnnotations(
		  AbstractGenerator myGenerator, FClass fclass) {
			super("XML_vendorAnnotations","Vendor annotations (optional).",
			  myGenerator,fclass);
		}
	
		public void generate(PrintStream genPrinter) {
			//TODO: vendor annotations (optional)
//				genPrinter.print("<VendorAnnotations>");
//				genPrinter.print("\n\t\t TODO (optional element)");
//				genPrinter.print("\n\t </VendorAnnotations>");
		}
	}
	
	/**
	 * A helper class to XMLGenerator for providing start and end tags with the
	 * correct amount of tabs. This class will be used in the XML code
	 * generation for the model meta-data parts which are optional and therefore
	 * can not use a template.
	 * 
	 */
	private class TagGenerator {
		private String tabs="";
		private Stack<String> stack;
		private String previous;
		
		/**
		 * Constructor.
		 * 
		 * @param tabstart Number of tabs indent at start.
		 */
		public TagGenerator(int tabstart) {
			stack = new Stack<String>();
			for(int i =0; i<tabstart; i++) {
				tabs=tabs+"\t";
			}
		}
		
		/**
		 * Generates a tag with a certain tagname.
		 * 
		 * The first time the tagname is encountered a start tag is created. The
		 * second time the same tagname is used a matching end tag is created.
		 * For each unique tagname a new start tag is created with one more tab
		 * indent. If start and end tags are encountered immediately after each
		 * other they will be on the same line.
		 * 
		 * @param tagname The name of the tag to create.
		 * @return Start or end tag with name set to <tagname>.
		 */
		public String generateTag(String tagname) {
			if(stack.isEmpty() || !stack.peek().equals(tagname.trim())) {
				stack.push(tagname.trim());
				return generateStartTag(tagname);
			}else {
				return generateEndTag(stack.pop());
			} 
		}
		
		/**
		 * Generates a start tag with the specified tagname.
		 * 
		 * @param tagname
		 *            The name of the tag for which a start tag should be
		 *            created.
		 * @return The start tag with name set to <tagname>.
		 */
		private String generateStartTag(String tagname) {				
			String tag = "\n"+tabs+"<"+tagname+">";			
			tabs=tabs+"\t";
			previous = tagname;
			
			return tag;
		}
		
		/**
		 * Generates an end tag with the specified tagname.
		 * 
		 * @param tagname
		 *            The name of the tag for which an end tag should be
		 *            created.
		 * @return The end tag with name set to <tagname>.
		 */
		private String generateEndTag(String tagname) {
			String tag;
			tabs=tabs.substring(1);
			if(!previous.equals(tagname)) {
				tag=("\n"+tabs);
			} else {
				tag=("");
			}
			tag=tag+("</"+tagname+">");

			return tag;
		}
	}

	/**
	 * Constructor.
	 * 
	 * @param expPrinter Printer object used to generate code for expressions.
	 * @param escapeCharacter Escape characters used to decode tags.
	 * @param fclass An FClass object used as a basis for the code generation.
	 */
	public XMLGenerator(Printer expPrinter, char escapeCharacter,
			FClass fclass) {
		super(expPrinter,escapeCharacter, fclass);
		
		// Create tags			
		AbstractTag tag = null;

		tag = new DAETag_XML_modelName(this,fclass);
		tagMap.put(tag.getName(), tag);
		tag = new DAETag_XML_modelIdentifier(this,fclass);
		tagMap.put(tag.getName(), tag);
		tag = new DAETag_XML_modelDescription(this,fclass);
		tagMap.put(tag.getName(), tag);
		tag = new DAETag_XML_modelAuthor(this,fclass);
		tagMap.put(tag.getName(), tag);
		tag = new DAETag_XML_modelVersion(this,fclass);
		tagMap.put(tag.getName(), tag);
		tag = new DAETag_XML_schemaVersion(this,fclass);
		tagMap.put(tag.getName(), tag);
		tag = new DAETag_XML_generationTool(this,fclass);
		tagMap.put(tag.getName(), tag);
		tag = new DAETag_XML_generationDate(this,fclass);
		tagMap.put(tag.getName(), tag);
		tag = new DAETag_XML_guid(this,fclass);
		tagMap.put(tag.getName(), tag);
		tag = new DAETag_XML_modelVariables(this,fclass);
		tagMap.put(tag.getName(), tag);
		tag = new DAETag_XML_defaultExperiment(this,fclass);
		tagMap.put(tag.getName(), tag);
		tag = new DAETag_XML_vendorAnnotations(this,fclass);
		tagMap.put(tag.getName(), tag);

	}

}

