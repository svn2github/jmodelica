package org.jmodelica.ide;

import java.io.File;

import org.eclipse.core.resources.IProject;
import org.jmodelica.util.OptionRegistry;

/**
 * OptionsRegistry for use in the JModelica IDE.
 * 
 * @author philip
 *
 */
public class IDEOptions extends OptionRegistry {

public IDEOptions(IProject project) {
    setStringOption("MODELICAPATH", "");
    setStringOption(IDEConstants.PACKAGES_IN_WORKSPACE_OPTION, "");
    
	if (project == null)
		return;
    
    try {
        String dir = project.getPersistentProperty(IDEConstants.PROPTERTY_OPTIONS_PATH);
		String path = dir + File.separator + "options.xml";
		copyAllOptions(new OptionRegistry(path));
		
	    String modelicaPath = project.getPersistentProperty(IDEConstants.PROPERTY_LIBRARIES_ID);
		setStringOption("MODELICAPATH", modelicaPath);
    } catch (Exception e) {
    	// TODO: Do something constructive. An error message or something.
        e.printStackTrace();
    }
    

}

}
