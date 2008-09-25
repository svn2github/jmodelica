package org.jmodelica.interactive;
import org.jmodelica.ast.*;

import java.io.*;

import org.jmodelica.parser.*;

public class Interactive {

	public static SourceRoot loadFile(String fileName) throws Exception{

		ModelicaParser parser = new ModelicaParser();
		Reader reader = new FileReader(fileName);
		ModelicaScanner scanner = new ModelicaScanner(new BufferedReader(reader));
		SourceRoot sr = (SourceRoot)parser.parse(scanner);
		sr.setFileName(fileName);
		return sr;
	}
	
}
