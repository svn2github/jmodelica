/*
    Copyright (C) 2010 Modelon AB

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

package org.jmodelica.util;

import java.io.BufferedReader;
import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileReader;
import java.io.InputStreamReader;
import java.io.PrintStream;
import java.io.StringReader;
import java.lang.reflect.Constructor;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.lang.reflect.Modifier;
import java.util.ArrayList;
import java.util.Collection;

import org.jmodelica.modelica.compiler.*;

/**
 * \brief Generates a test case annotation for a test model.
 * 
 * Most of the logic of this class is delegated to TestAnnotationizerHelper, a 
 * class that is generated from TestAnnotationizer.jrag. This class handles 
 * parsing the arguments and choosing between Modelica and Optimica versions 
 * of TestAnnotationizerHelper.
 * 
 * Usage: java TestAnnotationizer java TestAnnotationizer <.mo file path> [options...] [description]
 *   Options:
 *     -w           write result to file instead of stdout
 *     -m/-o        create annotation for Modelica/Optimica (default is infer from file path)
 *     -r           regenerate an already present annotation
 *     -t=<type>    set type of test, e.g. ErrorTestCase
 *     -c=<class>   set name of class to generate annotation for, if name 
 *                  does not contain a dot, base name of .mo file is prepended
 *     -d=<data>    set extra data to send to the specific generator, \n is interpreted
 *     -p=<opts>    comma-separated list of compiler options to override defaults for,
 *                  example: -p=eliminate_alias_variables=false,default_msl_version="2.2"
 *     -h           print this help
 *   User will be prompted for type and/or class if not set with options. 
 *   Options can *not* share a single "-", e.g. "-mw" will not work.
 *   Description is the text that will be entered in the "description" field of 
 *   the test annotation.
 */
public class TestAnnotationizer {
	
	private enum Lang { none, modelica, optimica };

	public static void main(String[] args) throws Exception {
		if (args.length == 0)
			usageError(1);
		
		String filePath = null;
		String testType = null;
		String modelName = null;
		String description = "";
		String data = null;
		boolean write = false;
		boolean regenerate = false;
		boolean repeat = false;
		Lang lang = Lang.none;
		String opts = null;
        String checkType = null;
		
		for (String arg : args) {
			String value = (arg.length() > 3) ? arg.substring(3) : "";
			if (arg.startsWith("-t=")) 
				testType = value;
			else if (arg.startsWith("-c=")) 
				modelName = value;
			else if (arg.startsWith("-d=")) 
				data = value;
			else if (arg.startsWith("-p=")) 
				opts = value;
            else if (arg.startsWith("-k=")) 
                checkType = value;
			else if (arg.equals("-w")) 
				write = true;
			else if (arg.equals("-r")) 
				regenerate = true;
			else if (arg.equals("-e")) 
				repeat = true;
			else if (arg.equals("-h")) 
				usageError(0);
			else if (arg.equals("-o")) 
				lang = Lang.optimica;
			else if (arg.equals("-m")) 
				lang = Lang.modelica;
			else if (arg.startsWith("-")) 
				System.err.println("Unrecognized option: " + arg + "\nUse -h for help.");
			else if (filePath == null)
				filePath = arg;
			else
				description += " " + arg;
		}
		
		if (repeat && modelName != null) {
			System.err.println("Cannot use -e when giving classname on command line.");
			System.exit(1);
		}
		
		description = description.trim();
		String packageName = getPackageName(filePath);
		modelName = composeModelName(packageName, modelName);
		if (lang == Lang.none)
			lang = filePath.contains("Optimica") ? Lang.optimica : Lang.modelica;
		boolean optimica = lang == Lang.optimica;
		
		boolean cont = true;
		while (cont) {
			BufferedReader in = new BufferedReader(new InputStreamReader(System.in));
			if (!modelName.contains(".")) {
				System.out.print("Enter class name: ");
				System.out.flush();
				String given = in.readLine().trim();
				if (given.isEmpty()) {
					System.out.println("Empty modelname given, exiting.");
					System.exit(0);
				}
				modelName = composeModelName(modelName, given);
			}
			
			if (regenerate) {
				doRegenerate(optimica, filePath, modelName, write);
			} else {
				if (testType == null) {
					System.out.print("Enter type of test: ");
					System.out.flush();
					testType = in.readLine().trim();			
				}
				
				doAnnotation(optimica, filePath, testType, modelName, description, opts, data, checkType, write);
			}
			
			if (repeat) 
				modelName = packageName;
			else
				cont = false;
		}
	}

	private static void doRegenerate(boolean optimica, String filePath, String modelName, boolean write) throws Exception {
		Method m = getHelperClass(optimica ? OPTIMICA : MODELICA).getMethod("doRegenerate", 
				String.class, String.class, boolean.class);
		m.invoke(null, filePath, modelName, write);
	}

	private static void doAnnotation(boolean optimica, String filePath,
			String testType, String modelName, String description, String optStr, 
			String data, String checkType, boolean write) throws Exception {
		String[] opts = (optStr == null) ? new String[0] : optStr.split(",");
		Method m = getHelperClass(optimica ? OPTIMICA : MODELICA).getMethod("doAnnotation", 
				String.class, String.class, String.class, String.class, String[].class, String.class, String.class, boolean.class);
		m.invoke(null, filePath, testType, modelName, description, opts, data, checkType, write);
	}

	private static void usageError(int level) throws Exception {
		getHelperClass(ANY).getMethod("usageError", int.class).invoke(null, Integer.valueOf(level));
	}
	
	private static final String[] MODELICA = { "org.jmodelica.modelica.compiler.TestAnnotationizerHelper" };
	private static final String[] OPTIMICA = { "org.jmodelica.optimica.compiler.TestAnnotationizerHelper" };
	private static final String[] ANY      = { MODELICA[0], OPTIMICA[0] };
	
	private static Class getHelperClass(String[] names) {
		for (String name : names) {
			try {
				return Class.forName(name);
			} catch (Exception e) {}
		}
		System.err.println("Could not load helper class. Compiler classes must be on path.");
		System.exit(1);
		return null;
	}

	private static String composeModelName(String extracted, String entered) {
		if (entered == null)
			return extracted;
		else if (entered.contains("."))
			return entered;
		else
			return extracted + "." + entered;
	}

	private static String getPackageName(String filePath) {
		String[] parts = filePath.split("\\\\|/");
		return parts[parts.length - 1].split("\\.")[0];
	}
}
