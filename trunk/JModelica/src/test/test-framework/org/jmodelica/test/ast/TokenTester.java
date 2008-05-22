/**
 * 
 */
package org.jmodelica.test.ast;

import org.jmodelica.ast.*;
import org.jmodelica.parser.FlatModelicaParser.Terminals;
import org.jmodelica.parser.FlatModelicaScanner;
import org.jmodelica.parser.FlatModelicaParser;
import org.jmodelica.parser.ModelicaScanner;
import org.jmodelica.parser.ModelicaParser;
import java.io.StringReader;
import java.io.FileReader;
import java.io.Reader;
import java.io.BufferedReader;
import beaver.Symbol;

/**
 * @author jakesson
 *
 */
public class TokenTester {

	public boolean test(String s1, String s2) {
		boolean testSuccess = true;
		boolean done = false;

		FlatModelicaScanner fms1 = new FlatModelicaScanner(new StringReader(s1));
		FlatModelicaScanner fms2 = new FlatModelicaScanner(new StringReader(s2));

		try {
			while (!done && testSuccess) {
				Symbol t1 = fms1.nextToken();
				Symbol t2 = fms2.nextToken();

				//System.out.println("t1: " + t1.getId() + ":"+ (String)t1.value +
				//		           " "+t2.getId()+ ":"+ (String)t2.value);
				if (!(t1.getId()==t2.getId())||
				    !(((String)t1.value).equals((String)t2.value)))
					testSuccess = false;

				if (t1.getId()==Terminals.EOF ||
						t1.getId()==Terminals.EOF)
					done = true;

			}
		} catch (Exception e) {e.printStackTrace();}

		return testSuccess;
	}

	public static void main(String args[]) {
	
		if(args.length != 3) {
			System.out.println("TokenTester expects a .mo file name, a class name and a .mof file name as command line arguments");
			System.exit(1);
		}

		String moFile = args[0];
		String cName = args[1];
		String mofFile = args[2];

		
		ModelicaParser parser = new ModelicaParser();
		FlatModelicaParser fparser = new FlatModelicaParser();
		SourceRoot sr = null;
		FlatRoot fr = null;
		
		try {
			String cl = args[1];
			Reader reader = new FileReader(moFile);
			ModelicaScanner scanner = new ModelicaScanner(new BufferedReader(reader));
			//System.out.println("Parsing "+moFile+"...");
			sr = (SourceRoot)parser.parse(scanner);
		} catch (Error e) {
			System.out.println("In file: '"+moFile + "':");
			System.err.println(e.getMessage());
			System.exit(1);
		} catch (Exception e) {e.printStackTrace();}
		
		FClass fc1 = new FClass();
		InstNode ir = sr.findFlatten(cName,fc1);
		sr.setFileName(moFile);
		
		StringBuffer fm1_str = new StringBuffer();
		//fc1.prettyPrint(fm1_str, "");

		try {
			Reader reader = new FileReader(mofFile);
			FlatModelicaScanner scanner = new FlatModelicaScanner(new BufferedReader(reader));
			//System.out.println("Parsing "+mofFile+"...");
			fr = (FlatRoot)fparser.parse(scanner);
		} catch (Error e) {
			System.out.println("In file: '"+mofFile + "':");
			System.err.println(e.getMessage());
			System.exit(1);
		} catch (Exception e) {e.printStackTrace();}
		
		StringBuffer fm2_str = new StringBuffer();
		fr.setFileName(mofFile);
		//fr.prettyPrint(fm2_str, "");
		
		TokenTester tt = new TokenTester();
		boolean testSuccess = tt.test(fm1_str.toString(),fm2_str.toString());
/*
		if (testSuccess)
			System.out.println("Test succeeded!");
		else
			System.out.println("Test failed!");
*/
	}
}
