package org.jmodelica.ide.editor;

import java.util.HashMap;

import org.eclipse.jface.text.ITextSelection;
import org.eclipse.jface.text.Position;
import org.eclipse.jface.text.source.Annotation;
import org.eclipse.jface.text.source.projection.ProjectionAnnotation;

/**
 * Map of annotations to positions in editor.
 */
public class EditorAnnotationMap extends HashMap<Annotation, Position> {

	/**
	 * Create a map of annotations, filtering out positions in other files not
	 * in <code>editor</code>.
	 * 
	 * @param ps      folding positions
	 * @param editor  editor
	 * 
	 */
	public EditorAnnotationMap(Iterable<Position> ps, Editor editor) {
		ITextSelection sel = editor.selection();
		boolean hideAnno = !editor.annotationsVisible();
		
		for (Position pos : ps) {
			if (editor.editorFile().containsFoldingPosition(pos)) {
				boolean collapsed = hideAnno && !pos.overlapsWith(sel.getOffset(), sel.getLength());
				Annotation annotation = new ProjectionAnnotation(collapsed);

				this.put(annotation, pos);
			}
		}
	}

}
