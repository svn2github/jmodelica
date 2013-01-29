package org.jmodelica.ide.editor;

import static org.jmodelica.generated.scanners.Modelica32PartitionScanner.ANNOTATION_PARTITION;

import java.util.ArrayList;
import java.util.Collection;
import java.util.Collections;
import java.util.Comparator;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

import org.eclipse.core.runtime.IProgressMonitor;
import org.eclipse.core.runtime.IStatus;
import org.eclipse.core.runtime.Status;
import org.eclipse.jface.text.BadLocationException;
import org.eclipse.jface.text.DocumentEvent;
import org.eclipse.jface.text.IDocument;
import org.eclipse.jface.text.IDocumentListener;
import org.eclipse.jface.text.IDocumentPartitioningListener;
import org.eclipse.jface.text.ITextSelection;
import org.eclipse.jface.text.ITypedRegion;
import org.eclipse.jface.text.Position;
import org.eclipse.jface.text.source.Annotation;
import org.eclipse.jface.text.source.projection.ProjectionAnnotation;
import org.eclipse.jface.text.source.projection.ProjectionAnnotationModel;
import org.eclipse.swt.custom.StyledText;
import org.eclipse.ui.progress.UIJob;
import org.jmodelica.generated.scanners.Modelica32PartitionScanner;
import org.jmodelica.ide.helpers.Util;

public class AnnotationFoldUpdater implements IDocumentPartitioningListener, IDocumentListener {
	private IDocument doc;
	private Editor edit;
	private int annotationLinesBefore;
	private boolean changeInAnnotation;

	public AnnotationFoldUpdater(IDocument document, Editor e) {
		doc = document;
		doc.addDocumentPartitioningListener(this);
		doc.addDocumentListener(this);
		edit = e;
		changeInAnnotation = false;
	}
	
	public void dispose() {
		doc.removeDocumentPartitioningListener(this);
	}

	public void documentPartitioningChanged(IDocument document) {
		updateFolds();
	}

	public void documentAboutToBeChanged(DocumentEvent event) {
		try {
			if (isAnnotation(event.fOffset)) {
				annotationLinesBefore = getPartitionLines(event.fOffset);
				changeInAnnotation = true;
			}
		} catch (BadLocationException e) {
		}
	}

	public void documentChanged(DocumentEvent event) {
		if (changeInAnnotation) {
			try {
				int annotationLinesAfter = getPartitionLines(event.fOffset);
				if ((annotationLinesBefore == 0) != (annotationLinesAfter == 0))
					updateFolds();
			} catch (BadLocationException e) {
			}
		}
		changeInAnnotation = false;
	}

	public int getPartitionLines(int offset) throws BadLocationException {
		ITypedRegion part = doc.getPartition(offset);
		int start = doc.getLineOfOffset(part.getOffset());
		int end = doc.getLineOfOffset(part.getOffset() + part.getLength());
		return end - start;
	}

	public boolean isAnnotation(int offset) throws BadLocationException {
		return doc.getPartition(offset).getType().equals(ANNOTATION_PARTITION);
	}

	public void updateFolds() {
		new UpdateJob().schedule();
	}
	
	private class RedrawJob extends UIJob {
		private static final String TITLE = "Redrawing editor";

		public RedrawJob() {
			super(TITLE);
			setPriority(INTERACTIVE);
			setSystem(true);
		}

		public IStatus runInUIThread(IProgressMonitor monitor) {
			edit.redraw();
			return Status.OK_STATUS;
		}
		
	}
	
	private class UpdateJob extends UIJob {
		private static final String TITLE = "Updating annotations";

		public UpdateJob() {
			super(TITLE);
			setPriority(INTERACTIVE);
			setSystem(true);
		}

		public IStatus runInUIThread(IProgressMonitor monitor) {
		    ProjectionAnnotationModel model = edit.getAnnotationModel();
		    if (model == null)
		        return Status.OK_STATUS;
	
		    Collection<ITypedRegion> parts = getPartitions(doc, ANNOTATION_PARTITION);
		    List<Annotation> old = Util.listFromIterator(model.getAnnotationIterator());
		    Collections.sort(old, new PositionSorter(model));
			Iterator<Annotation> oldIt = old.iterator();
			
			Map<Annotation, Position> added = new HashMap<Annotation, Position>();
			ArrayList<Annotation> removed = new ArrayList<Annotation>();
			
			ITextSelection sel = edit.selection();
			boolean hideAnno = !edit.annotationsVisible();
			
			Position annoPos = new Position(0);
			annoPos.offset = -1;
			Annotation curAnno = null;
			for (ITypedRegion part : parts) {
				Position partPos = createPosition(part.getOffset(), part.getLength());
				if (partPos != null) {
					
					// Remove all old that are before partition
					while (annoPos.offset < partPos.offset) {
						if (curAnno != null)
							removed.add(curAnno);
						if (oldIt.hasNext()) {
							curAnno = oldIt.next();
							annoPos = model.getPosition(curAnno);
						} else {
							curAnno = null;
							annoPos = new Position(doc.getLength() + 1);
						}
					}
					
					// Should we add partition?
					if (!annoPos.equals(partPos)) {
						boolean collapsed = hideAnno && !partPos.overlapsWith(sel.getOffset(), sel.getLength());
						added.put(new ProjectionAnnotation(collapsed), partPos);
					} else { 
						// Don't remove this annotation
						curAnno = null;
					}
				}
			}
			
			// Remove remaining annotations
			if (curAnno != null)
				removed.add(curAnno);
			while (oldIt.hasNext())
				removed.add(oldIt.next());
			
			
			Annotation[] removedArr = removed.toArray(new Annotation[removed.size()]);
			model.modifyAnnotations(removedArr, added, null);
			
			new RedrawJob().schedule();
			
	        return Status.OK_STATUS;
		}
	
		private Position createPosition(int offset, int length) {
			try {
				int startLine = doc.getLineOfOffset(offset);
				int endLine = doc.getLineOfOffset(offset + length);
				if (startLine == endLine)
					return null;
				int lineOffset = doc.getLineOffset(startLine);
				int endOffset = (endLine < doc.getNumberOfLines()) ? 
						doc.getLineOffset(endLine + 1) : doc.getLength();
				offset = lineOffset;
				length = endOffset - lineOffset;
			} catch (BadLocationException e) {
			}
			return new Position(offset, length);
		}
	
		private Collection<ITypedRegion> getPartitions(IDocument document, String type) {
			ArrayList<ITypedRegion> res = new ArrayList<ITypedRegion>();
			try {
				int len = document.getLength();
				ITypedRegion cur = null;
				for (int p = 0; p < len; p = cur.getLength() + cur.getOffset() + 1) {
					cur = document.getPartition(p);
					if (cur.getType().equals(type))
						res.add(cur);
				}
			} catch (BadLocationException e) {
			}
			return res;
		}
	
		public class PositionSorter implements Comparator<Annotation> {
	
			private ProjectionAnnotationModel model;
	
			public PositionSorter(ProjectionAnnotationModel model) {
				this.model = model;
			}
	
			public int compare(Annotation a1, Annotation a2) {
				return model.getPosition(a1).offset - model.getPosition(a2).offset;
			}
	
		}
	}
	
}