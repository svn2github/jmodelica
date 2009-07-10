/*
    Copyright (C) 2009 Modelon AB

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, version 3 of the License.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/
package org.jmodelica.ide.editor;

import java.util.Iterator;

import org.eclipse.jface.text.BadLocationException;
import org.eclipse.jface.text.IDocument;
import org.eclipse.jface.text.IRegion;
import org.eclipse.jface.text.ITypedRegion;
import org.eclipse.jface.text.Position;
import org.eclipse.jface.text.source.ICharacterPairMatcher;
import org.eclipse.jface.text.source.projection.ProjectionAnnotation;
import org.eclipse.jface.text.source.projection.ProjectionAnnotationModel;
import org.jmodelica.folding.CharacterProjectionViewer;
import org.jmodelica.ide.scanners.generated.AnnotationNormalStateScanner;
import org.jmodelica.ide.scanners.generated.BackwardBraceScanner;
import org.jmodelica.ide.scanners.generated.ForwardBraceScanner;
import org.jmodelica.ide.scanners.generated.Modelica22PartitionScanner;

public class ModelicaCharacterPairMatcher implements ICharacterPairMatcher {

	private BackwardBraceScanner backward;
	private ForwardBraceScanner forward;
	private int anchor;
	private AnnotationNormalStateScanner normalStateScanner;
	private CharacterProjectionViewer projectionViewer;

	public ModelicaCharacterPairMatcher(CharacterProjectionViewer viewer) {
		this.projectionViewer = viewer;
	}

	public void clear() {
	}

	public void dispose() {
	}

	public int getAnchor() {
		return anchor;
	}

	public IRegion match(IDocument document, int offset) {
		try {
			offset--;
			char ch = document.getChar(offset);
			switch (ch) {
			case '(':
			case '[':
			case '{':
				anchor = LEFT;
				if (isPositionOk(document, offset))
					return getForwardScanner().match(document, offset);
				break;
			case ')':
			case ']':
			case '}':
				anchor = RIGHT;
				if (isPositionOk(document, offset))
					return getBackwardScanner().match(document, offset);
				break;
			}
		} catch (BadLocationException e) {
		}
		return null;
	}

	private boolean isPositionOk(IDocument document, int offset)
			throws BadLocationException {
		return isNormalState(document, offset) && !isFolded(document, offset);
	}

	private boolean isFolded(IDocument document, int offset) {
		if (projectionViewer != null) {
			ProjectionAnnotationModel model = projectionViewer.getProjectionAnnotationModel();
			if (model != null) {
				Iterator iter = model.getAnnotationIterator(offset, 1, true, true);
				while (iter.hasNext()) {
					Object ann = iter.next();
					if (ann instanceof ProjectionAnnotation) {
						ProjectionAnnotation proj = (ProjectionAnnotation) ann;
						Position pos = model.getPosition(proj);
						if (proj.isCollapsed() && pos.includes(offset))
							return true;
					}
				}
			}
		}
		return false;
	}

	private boolean isNormalState(IDocument document, int offset) {
		try {
			ITypedRegion partition = document.getPartition(offset);
			if (partition.getType() == Modelica22PartitionScanner.NORMAL_PARTITION)
				return true;
			else if (partition.getType() == Modelica22PartitionScanner.ANNOTATION_PARTITION)
				return getNormalStateScanner().isNormalState(document, partition.getOffset(), offset);
		} catch (BadLocationException e) {
		}
		return false;
	}

	private AnnotationNormalStateScanner getNormalStateScanner() {
		if (normalStateScanner == null)
			normalStateScanner = new AnnotationNormalStateScanner();
		return normalStateScanner;
	}

	private BackwardBraceScanner getBackwardScanner() {
		if (backward == null)
			backward = new BackwardBraceScanner();
		return backward;
	}

	private ForwardBraceScanner getForwardScanner() {
		if (forward == null)
			forward = new ForwardBraceScanner();
		return forward;
	}
}
