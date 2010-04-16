package mock;

import org.eclipse.ui.part.FileEditorInput;
import org.jmodelica.ide.editor.EditorFile;
import org.jmodelica.ide.editor.EditorWithFile;

public class MockEditor implements EditorWithFile {

    String path;

    public MockEditor(String path) {
        this.path = path;
    }
    
    @Override
    public EditorFile editorFile() {
        return new EditorFile(new FileEditorInput(new MockFile(new MockProject(), path)));
    }
}
