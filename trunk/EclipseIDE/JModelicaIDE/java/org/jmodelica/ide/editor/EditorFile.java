package org.jmodelica.ide.editor;

import java.io.File;
import java.io.IOException;

import org.eclipse.core.resources.IFile;
import org.eclipse.jface.text.Position;
import org.eclipse.ui.IEditorInput;
import org.eclipse.ui.IFileEditorInput;
import org.eclipse.ui.IURIEditorInput;
import org.jmodelica.ide.folding.IFilePosition;
import org.jmodelica.ide.helpers.EclipseCruftinessWorkaroundClass;
import org.jmodelica.ide.helpers.Util;

/**
 * File opened in Editor. Wraps different input methods.
 * @author philip
 *
 */
public class EditorFile {

private final IFile file;
private final String path;

/**
 * Create new EditorFile from IEditorInput
 * @param input file input
 */
public EditorFile(IEditorInput input) {
    
    // blergh... java needs better typecase
    if (input instanceof IFileEditorInput) {
        
        IFileEditorInput i = (IFileEditorInput)input;
        file = i.getFile();
        path = file.getRawLocation().toOSString();
        
    } else if (input instanceof IURIEditorInput) {
        
        String tmp;
        try {
            IURIEditorInput i = (IURIEditorInput)input;
            tmp = new File(i.getURI()).getCanonicalPath();
        } catch (IOException e) {
            e.printStackTrace();
            tmp = null;
        }
        
        path = tmp;
        file = EclipseCruftinessWorkaroundClass.getFileForPath(path);
        
    } else { // NOTE!!: includes input == null
        throw new IllegalArgumentException();
    }
}

/**
 * Returns true if file is located in the workspace  
 * @return true if file is located in the workspace
 */
public boolean inWorkspace() {
    return file != null;
}

/**
 * Returns true if file is located in the library
 * @return true if file is located in the library
 */
public boolean inLibrary() {
    return path != null && (file == null || Util.isInLibrary(file));
}

/**
 * Returns path of file
 * @return path of file
 */
public String path() {
    return path;
}

/**
 * Returns file resource of file
 * @return file resource of file
 */
public IFile iFile() {
    return file;
}

/**
 * Returns true if file contains folding position in <code> pos </code>
 * @param pos folding position
 * @return true if file contains folding position in <code> pos </code>
 */
public boolean containsFoldingPosition(Position pos) {
    return inLibrary() || ((IFilePosition) pos).getFileName().equals(path);
}

/**
 * Returns a representation of this file that can be used as a key in the
 * ASTRegistry
 * @return key representation
 */
public String toRegistryKey() {
    return inLibrary()
        ? (file == null ? Util.getLibraryPath(file) : path)
        : file.getRawLocation().toOSString();
}

}
