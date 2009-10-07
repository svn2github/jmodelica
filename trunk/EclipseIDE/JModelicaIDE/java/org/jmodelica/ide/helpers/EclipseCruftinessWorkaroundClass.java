package org.jmodelica.ide.helpers;

import java.io.File;

import org.eclipse.core.resources.IFile;
import org.eclipse.core.resources.IWorkspaceRoot;
import org.eclipse.core.resources.ResourcesPlugin;
import org.eclipse.ui.IEditorDescriptor;
import org.eclipse.ui.IWorkbenchPage;
import org.eclipse.ui.PartInitException;
import org.eclipse.ui.PlatformUI;
import org.eclipse.ui.part.FileEditorInput;
import org.jmodelica.ide.editor.Editor;


/**
 * Workaround class for things in Eclipse that are ridiculously verbose.
 * @author philip
 *
 */
public class EclipseCruftinessWorkaroundClass {

public static Maybe<Editor> getModelicaEditorForFile(IFile file) {

    // warning: cuteness overload

    IWorkbenchPage page = PlatformUI.getWorkbench().
        getActiveWorkbenchWindow().getActivePage(); 
    
    IEditorDescriptor desc = PlatformUI.getWorkbench().
    getEditorRegistry().getDefaultEditor(file.getName());
    
    Editor part;
    try {
        part = (Editor)page.openEditor(new FileEditorInput(file), desc.getId());
    } catch (PartInitException e) {
        e.printStackTrace();
        part = null;
    } catch (ClassCastException e) {
        e.printStackTrace();
        part = null;
    }
    
    return Maybe.Just(part);
}
    
public static IFile getFileForPath(String path) {
    
    if (path == null)
        return null;
    
    IWorkspaceRoot workspace = ResourcesPlugin.getWorkspace().getRoot();
    
    // file inside workspace?
    // TODO: If file is outside workspace, add linked resource?
    if (!path.startsWith(workspace.getRawLocation().toOSString())) 
        return null;

    // find files matching URI
    IFile candidates[] = workspace.findFilesForLocationURI(
            new File(path).toURI());
    
    //just take first candidate if several possible
    return candidates.length > 0 ? candidates[0] : null;
}


}
