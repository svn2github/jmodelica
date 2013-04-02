package org.jmodelica.ide.compiler;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.IOException;

import javax.xml.parsers.ParserConfigurationException;
import javax.xml.xpath.XPathExpressionException;

import org.eclipse.core.resources.IFile;
import org.eclipse.core.resources.IProject;
import org.eclipse.core.resources.IResource;
import org.jmodelica.ide.IDEConstants;
import org.jmodelica.ide.helpers.Util;
import org.jmodelica.modelica.compiler.ModelicaCompiler;
import org.jmodelica.util.OptionRegistry;
import org.xml.sax.SAXException;

/**
 * OptionsRegistry for use in the JModelica IDE.
 * 
 * @author philip
 * 
 */
public class IDEOptions extends OptionRegistry {

	public IDEOptions(IProject project) {
		addStringOption(IDEConstants.MODELICAPATH, "");
		addStringOption(IDEConstants.PACKAGES_IN_WORKSPACE_OPTION, "");

		if (project == null)
			return;

		IResource options = project.findMember(IDEConstants.COMPILER_OPTIONS_FILE);
		try {
			if (options != null)
				loadOptions(options.getRawLocation().toOSString());
		} catch (Exception e) {
			// TODO: Do something constructive. An error message or something.
			e.printStackTrace();
		}

		try {
			String modelicaPath = Preferences.get(project, IDEConstants.PREFERENCE_LIBRARIES_ID);
			setStringOption(IDEConstants.MODELICAPATH, modelicaPath);

			// Set standard options for FMU
			ModelicaCompiler mc = new ModelicaCompiler(this);
			mc.defaultOptionsFMUME();
		} catch (Exception e) {
			// TODO: Do something constructive. An error message or something.
			e.printStackTrace();
		}

	}

}
