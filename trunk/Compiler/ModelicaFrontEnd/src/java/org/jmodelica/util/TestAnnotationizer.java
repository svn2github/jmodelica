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
 *     -t=<type>    set type of test, e.g. ErrorTestCase
 *     -c=<class>   set name of class to generate annotation for, if name 
 *                  does not contain a dot, base name of .mo file is prepended
 *     -d=<data>    set extra data to send to the specific generator
 *     -h           print this help
 *   User will be prompted for type and/or class if not set with options. 
 *   Options can *not* share a single "-", e.g. "-mw" will not work.
 *   Description is the text that will be entered in the "description" field of 
 *   the test annotation.
 */
public class TestAnnotationizer {

	public static void main(String[] args) throws Exception {
		if (args.length == 0)
			usageError(1);
		
		String filePath = args[0];
		String testType = null;
		String modelName = getPackageName(filePath);
		String description = "";
		String data = null;
		boolean write = false;
		boolean optimica = filePath.contains("Optimica");
		String opts = null;
		
		for (int i = 1; i < args.length; i++) {
			String arg = (args[i].length() > 3) ? args[i].substring(3) : "";
			if (args[i].startsWith("-t=")) 
				testType = arg;
			else if (args[i].startsWith("-c=")) 
				modelName = composeModelName(modelName, arg);
			else if (args[i].startsWith("-d=")) 
				data = arg;
			else if (args[i].startsWith("-p=")) 
				opts = arg;
			else if (args[i].equals("-w")) 
				write = true;
			else if (args[i].equals("-h")) 
				usageError(0);
			else if (args[i].equals("-o")) 
				optimica = true;
			else if (args[i].equals("-m")) 
				optimica = false;
			else if (args[i].startsWith("-")) 
				System.err.println("Unrecognized option: " + args[i] + "\nUse -h for help.");
			else
				description += " " + args[i];
		}
		description = description.trim();
		
		BufferedReader in = new BufferedReader(new InputStreamReader(System.in));
		if (!modelName.contains(".")) {
			System.out.print("Enter class name: ");
			System.out.flush();
			modelName = composeModelName(modelName, in.readLine().trim());
		}
		if (testType == null) {
			System.out.print("Enter type of test: ");
			System.out.flush();
			testType = in.readLine().trim();			
		}
		
		doAnnotation(optimica, filePath, testType, modelName, description, opts, data, write);
	}

	private static void doAnnotation(boolean optimica, String filePath,
			String testType, String modelName, String description, String opts, 
			String data, boolean write) throws Exception {
		Method m = getHelperClass(optimica ? OPTIMICA : MODELICA).getMethod("doAnnotation", 
				String.class, String.class, String.class, String.class, String.class, String.class, boolean.class);
		m.invoke(null, filePath, testType, modelName, description, opts, data, write);
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
		if (entered.contains("."))
			return entered;
		else
			return extracted + "." + entered;
	}

	private static String getPackageName(String filePath) {
		String[] parts = filePath.split("\\\\|/");
		return parts[parts.length - 1].split("\\.")[0];
	}
}
