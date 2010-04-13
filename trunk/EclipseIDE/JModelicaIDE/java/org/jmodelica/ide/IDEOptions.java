package org.jmodelica.ide;

import java.io.File;

import org.eclipse.core.resources.IProject;
import org.jmodelica.ide.helpers.Library;
import org.jmodelica.util.OptionRegistry;

/**
 * OptionsRegistry for use in the JModelica IDE.
 * 
 * @author philip
 *
 */
public class IDEOptions extends OptionRegistry {

public IDEOptions(IProject project) {
    
    setStringOption(
        "MODELICAPATH", 
        "");
    
    try {
        copyAllOptions(
            new OptionRegistry(
                project
                .getPersistentProperty(
                    IDEConstants.PROPTERTY_OPTIONS_PATH)
                + File.separatorChar
                + "options.xml"));
    } catch (NullPointerException e ) {
        System.out.println("Null project. Not copying options.");
    } catch (Exception e) {
        e.printStackTrace();
    }
    
    try {
        setStringOption(
            "MODELICAPATH", 
            Library.makeModelicaPath(
                project.getPersistentProperty(
                    IDEConstants.PROPERTY_LIBRARIES_ID)));
       
    } catch (NullPointerException e ) {
        System.out.println("Null project. Not setting MODELICAPATH.");
    } catch (Exception e ) {
        e.printStackTrace();
    }
   
}

}
