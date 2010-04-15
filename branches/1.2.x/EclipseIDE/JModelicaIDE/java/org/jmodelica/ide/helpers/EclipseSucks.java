package org.jmodelica.ide.helpers;

import java.io.File;

import org.eclipse.core.resources.IFile;
import org.eclipse.core.resources.IWorkspaceRoot;
import org.eclipse.core.resources.ResourcesPlugin;
import org.eclipse.ui.IEditorDescriptor;
import org.eclipse.ui.IWorkbenchPage;
import org.eclipse.ui.PlatformUI;
import org.eclipse.ui.part.FileEditorInput;
import org.jmodelica.ide.editor.Editor;

/**
 * Some things in Eclipse that are ridiculously verbose.
 * 
 * @author philip
 *
 */
public class EclipseSucks {

public static Maybe<Editor> getModelicaEditorForFile(IFile file) {

    // cuteness overload

    IWorkbenchPage page = 
        PlatformUI
        .getWorkbench()
        .getActiveWorkbenchWindow()
        .getActivePage(); 
    
    IEditorDescriptor desc = 
        PlatformUI.getWorkbench()
        .getEditorRegistry()
        .getDefaultEditor(
            file.getName());

    try {
        
        return 
            Maybe.Just(
                (Editor)
                page.openEditor(
                    new FileEditorInput(file),
                    desc.getId()));
        
    } catch (Exception e) {
        e.printStackTrace();
        return Maybe.<Editor>Nothing();
    } 
}
    
public static Maybe<IFile> getFileForPath(String path) {
    
    if (path == null)
        return Maybe.<IFile>Nothing();
    
    IWorkspaceRoot workspace =
        ResourcesPlugin.getWorkspace().getRoot();
    
    // file inside workspace?
    // TODO: If file is outside workspace, add linked resource?
    if (!path.startsWith(workspace.getRawLocation().toOSString())) 
        return Maybe.<IFile>Nothing();

    // find files matching URI
    IFile candidates[] = 
        workspace
        .findFilesForLocationURI(
            new File(path).toURI());
    
    // just take first candidate if several possible for some reason. i have no
    // idea why we do this
    return candidates.length > 0 
        ? Maybe.Just(candidates[0]) 
        : Maybe.<IFile>Nothing();
}


}
