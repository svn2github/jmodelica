package org.jmodelica.ide.editor;

import java.io.File;
import java.io.IOException;

import org.eclipse.core.resources.IFile;
import org.eclipse.ui.IEditorInput;
import org.eclipse.ui.IFileEditorInput;
import org.eclipse.ui.IURIEditorInput;
import org.jmodelica.ide.helpers.EclipseCruftinessWorkaroundClass;
import org.jmodelica.ide.helpers.Util;

public class EditorPath {

protected IFile file;
protected String path;
protected boolean inLibrary;

public EditorPath(IEditorInput input) {
    
    if (input == null) {
        file = null;
        path = null;
        inLibrary = false;
    } else if (input instanceof IFileEditorInput) {
        file = ((IFileEditorInput)input)
            .getFile();
        path = file.getRawLocation()
                   .toOSString();
        inLibrary = Util.isInLibrary(file);
    } else if (input instanceof IURIEditorInput) {
        try {
            path = new File(
                    ((IURIEditorInput)input).getURI())
                .getCanonicalPath();
            file = EclipseCruftinessWorkaroundClass.getFileForPath(path);
        } catch (IOException e) {
            e.printStackTrace();
        }
        inLibrary = false;
    }
    else 
        throw new IllegalArgumentException();
    
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

}
