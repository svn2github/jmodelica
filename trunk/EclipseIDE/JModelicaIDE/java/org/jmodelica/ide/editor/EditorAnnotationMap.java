package org.jmodelica.ide.editor;

import java.util.HashMap;

import org.eclipse.jface.text.ITextSelection;
import org.eclipse.jface.text.Position;
import org.eclipse.jface.text.source.Annotation;
import org.eclipse.jface.text.source.projection.ProjectionAnnotation;
import org.jmodelica.folding.CharacterPosition;
import org.jmodelica.folding.CharacterProjectionAnnotation;

/**
 * Map of annotations to positions in editor.
 * @author philip
 *
 */
public class EditorAnnotationMap extends HashMap<Annotation, Position> {

/**
 * Create a map of annotations, filtering out positions in other 
 * files not in <code>editor</code>. 
 * @param ps folding positions
 * @param editor editor 
 * 
 */
public EditorAnnotationMap(Iterable<Position> ps, Editor editor) {

    for (Position pos : ps) {
        
        if (!editor.editorFile().containsFoldingPosition(pos))
            continue;

        Annotation annotation;

        if (pos instanceof CharacterPosition) {
        
            ITextSelection sel = editor.selection();
            annotation = new CharacterProjectionAnnotation(
                    editor.annotationsVisible() ||
                    pos.overlapsWith(sel.getOffset(), sel.getLength()));
            
        } else {
            annotation = new ProjectionAnnotation();
        }

        this.put(annotation, pos);
    }
}

}
