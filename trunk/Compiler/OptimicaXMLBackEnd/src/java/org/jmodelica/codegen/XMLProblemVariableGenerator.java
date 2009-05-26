package org.jmodelica.codegen;

import java.io.PrintStream;

import org.jmodelica.ast.FClass;
import org.jmodelica.ast.FOptClass;
import org.jmodelica.ast.Printer;


public class XMLProblemVariableGenerator extends GenericGenerator{

	class DAETag_XML_startTime extends DAETag {
		public DAETag_XML_startTime(AbstractGenerator myGenerator, FClass fclass) {
			super("XML_startTime","Interval start time (optional)", myGenerator, fclass);
		}
		
		public void generate(PrintStream genPrinter) {
			FOptClass optclass = (FOptClass) fclass;
			TagGenerator tg = new TagGenerator(2);
			genPrinter.print(tg.generateTag("Value")+ optclass.startTimeAttribute()+tg.generateTag("Value"));
			genPrinter.print(tg.generateTag("Free")+optclass.startTimeFreeAttribute()+tg.generateTag("Free"));
			genPrinter.print(tg.generateTag("InitialGuess")+optclass.startTimeInitialGuessAttribute()+tg.generateTag("InitialGuess"));
		}
	}
	
	class DAETag_XML_finalTime extends DAETag {
		public DAETag_XML_finalTime(AbstractGenerator myGenerator, FClass fclass) {
			super("XML_finalTime", "Interval final time (optional)", myGenerator, fclass);
		}
		
		public void generate(PrintStream genPrinter) {
			FOptClass optclass = (FOptClass) fclass;
			TagGenerator tg = new TagGenerator(2);
			genPrinter.print(tg.generateTag("Value") + optclass.finalTimeAttribute() + tg.generateTag("Value"));
			genPrinter.print(tg.generateTag("Free") + optclass.finalTimeFreeAttribute() + tg.generateTag("Free"));
			genPrinter.print(tg.generateTag("InitialGuess") + optclass.finalTimeInitialGuessAttribute() + tg.generateTag("InitialGuess"));
		}
	}
	
	class DAETag_XML_timePoints extends DAETag {
		public DAETag_XML_timePoints(AbstractGenerator myGenerator, FClass fclass) {
			super("XML_timePoints", "Time points (optional)", myGenerator, fclass);
		}
		
		public void generate(PrintStream genPrinter) {
			FOptClass optclass = (FOptClass) fclass;
			TagGenerator tg = new TagGenerator(2);
			double[] points = optclass.timePoints();
			
			for(int i=0;i<points.length;i++) {
				genPrinter.print(tg.generateTag("Index")+optclass.timePointIndex(points[i])+tg.generateTag("Index"));
				genPrinter.print(tg.generateTag("Value")+points[i]+tg.generateTag("Value"));
			}
		}
	}
	
	public XMLProblemVariableGenerator(Printer expPrinter,
			char escapeCharacter, FClass fclass) {
		super(expPrinter, escapeCharacter, fclass);
		
		// Create tags			
		AbstractTag tag = null;

		tag = new DAETag_XML_startTime(this,fclass);
		tagMap.put(tag.getName(), tag);
		tag = new DAETag_XML_finalTime(this,fclass);
		tagMap.put(tag.getName(), tag);
		tag = new DAETag_XML_timePoints(this,fclass);
		tagMap.put(tag.getName(), tag);


	}

}
