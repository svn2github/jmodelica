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
 * Represents a file contained in an Editor. Wraps different input methods.
 * @author philip
 *
 */
public class EditorFile {

protected IFile file;
protected String path;
protected boolean inLibrary;

public EditorFile(IEditorInput input) {
    
    // blergh... java needs better typecase
    if (input == null) {
        return;
    } else if (input instanceof IFileEditorInput) {
        instantiate((IFileEditorInput)input);
    } else if (input instanceof IURIEditorInput) {
        instantiate((IURIEditorInput)input);
    } else {
        throw new IllegalArgumentException();
    }
}

private void instantiate(IFileEditorInput input) {
    file = input.getFile();
    path = file.getRawLocation()
               .toOSString();
    inLibrary = Util.isInLibrary(file);
}

private void instantiate(IURIEditorInput input) {
    
    try {
        path = new File(input.getURI())
                   .getCanonicalPath();
        file = EclipseCruftinessWorkaroundClass.getFileForPath(path);
    
    } catch (IOException e) {
        e.printStackTrace();
    }
    
    inLibrary = false;
}

public String path() {
    return path;
}

public boolean inLibrary() {
    return inLibrary;
}

public IFile file() {
    return file;
}

public boolean containsFoldingPosition(Position pos) {
    return !inLibrary() || ((IFilePosition) pos).getFileName().equals(path);
}

}
