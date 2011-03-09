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

//import static org.eclipse.ui.texteditor.AbstractDecoratedTextEditorPreferenceConstants.EDITOR_CURRENT_LINE;
//import static org.eclipse.ui.texteditor.AbstractDecoratedTextEditorPreferenceConstants.EDITOR_CURRENT_LINE_COLOR;

import java.io.File;
import java.util.ArrayList;
import java.util.Collection;
import java.util.Collections;
import java.util.Comparator;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

import org.eclipse.core.resources.IProject;
import org.eclipse.core.runtime.CoreException;
import org.eclipse.core.runtime.IProgressMonitor;
import org.eclipse.core.runtime.IStatus;
import org.eclipse.core.runtime.Status;
import org.eclipse.jface.action.Action;
import org.eclipse.jface.action.IMenuManager;
import org.eclipse.jface.preference.IPreferenceStore;
import org.eclipse.jface.preference.PreferenceConverter;
import org.eclipse.jface.text.BadLocationException;
import org.eclipse.jface.text.IDocument;
import org.eclipse.jface.text.IDocumentPartitioner;
import org.eclipse.jface.text.IDocumentPartitioningListener;
import org.eclipse.jface.text.IRegion;
import org.eclipse.jface.text.ITextSelection;
import org.eclipse.jface.text.ITypedRegion;
import org.eclipse.jface.text.Position;
import org.eclipse.jface.text.reconciler.IReconcilingStrategy;
import org.eclipse.jface.text.rules.FastPartitioner;
import org.eclipse.jface.text.source.Annotation;
import org.eclipse.jface.text.source.ISourceViewer;
import org.eclipse.jface.text.source.IVerticalRuler;
import org.eclipse.jface.text.source.projection.ProjectionAnnotation;
import org.eclipse.jface.text.source.projection.ProjectionAnnotationModel;
import org.eclipse.jface.text.source.projection.ProjectionSupport;
import org.eclipse.jface.text.source.projection.ProjectionViewer;
import org.eclipse.swt.custom.StyledText;
import org.eclipse.swt.widgets.Composite;
import org.eclipse.swt.widgets.Display;
import org.eclipse.ui.IEditorInput;
import org.eclipse.ui.progress.UIJob;
import org.eclipse.ui.texteditor.AbstractDecoratedTextEditor;
import org.eclipse.ui.texteditor.AbstractTextEditor;
import org.eclipse.ui.texteditor.SourceViewerDecorationSupport;
import org.eclipse.ui.views.contentoutline.IContentOutlinePage;
import org.jastadd.plugin.registry.IASTRegistryListener;
import org.jmodelica.generated.scanners.Modelica32PartitionScanner;
import org.jmodelica.ide.IDEConstants;
import org.jmodelica.ide.compiler.ModelicaEclipseCompiler;
import org.jmodelica.ide.editor.actions.CollapseAllAction;
import org.jmodelica.ide.editor.actions.CompileFMUAction;
import org.jmodelica.ide.editor.actions.CurrentClassAction;
import org.jmodelica.ide.editor.actions.ErrorCheckAction;
import org.jmodelica.ide.editor.actions.ExpandAllAction;
import org.jmodelica.ide.editor.actions.FormatRegionAction;
import org.jmodelica.ide.editor.actions.GoToDeclaration;
import org.jmodelica.ide.editor.actions.ToggleAnnotationsAction;
import org.jmodelica.ide.editor.actions.ToggleComment;
import org.jmodelica.ide.helpers.Util;
import org.jmodelica.ide.namecomplete.CompletionProcessor;
import org.jmodelica.ide.outline.InstanceOutlinePage;
import org.jmodelica.ide.outline.OutlinePage;
import org.jmodelica.ide.outline.SourceOutlinePage;
import org.jmodelica.modelica.compiler.ASTNode;
import org.jmodelica.modelica.compiler.BaseClassDecl;


/**
 * Modelica source editor.
 */
public class Editor extends AbstractDecoratedTextEditor implements
        IASTRegistryListener, EditorWithFile {

private final OutlinePage fSourceOutlinePage;
private final InstanceOutlinePage fInstanceOutlinePage;

private IDocumentPartitioner fPartitioner;

//private AnnotationDrawer annotationDrawer; // For folding

private CompilationResult compResult;
public  EditorFile file;

private final ErrorCheckAction errorCheckAction;
private final CompileFMUAction compileFMUAction;
private final CurrentClassAction[] currentClassListeners;
private final ToggleAnnotationsAction toggleAnnotationsAction;
private final GoToDeclaration goToDeclaration;
//Commented out to disable name completion
//private final CompletionProcessor completions;
private AnnotationFoldUpdater annotationFolds;

/**
 * Standard constructor.
 */
public Editor() {
    super();
    fSourceOutlinePage = 
        new SourceOutlinePage(this);
    fInstanceOutlinePage = 
        new InstanceOutlinePage(this);
 // Commented out to disable name completion
//    completions = 
//        new CompletionProcessor(this);
    goToDeclaration = 
        new GoToDeclaration(this);
    errorCheckAction = 
        new ErrorCheckAction();
    compileFMUAction = 
        new CompileFMUAction(this);
    currentClassListeners = new CurrentClassAction[] { errorCheckAction, compileFMUAction };
    toggleAnnotationsAction = 
        new ToggleAnnotationsAction(this);
    fPartitioner = 
        new FastPartitioner(
            new Modelica32PartitionScanner(),
            Modelica32PartitionScanner.LEGAL_PARTITIONS);
}

/**
 * Create and configure a source viewer. Creates a
 * {@link CharacterProjectionViewer} and configures it for folding and brace
 * matching.
 */
@Override
protected ISourceViewer createSourceViewer(Composite parent,
        IVerticalRuler ruler, int styles) {

    fAnnotationAccess = getAnnotationAccess();
    fOverviewRuler = createOverviewRuler(getSharedColors());

    ProjectionViewer viewer = new ProjectionViewer(parent,
            ruler, getOverviewRuler(), isOverviewRulerVisible(), styles);

    configureProjectionSupport(viewer);
    configureDecorationSupport(viewer);

    return viewer;
}

private void configureProjectionSupport(ProjectionViewer viewer) {
    ProjectionSupport projectionSupport = new ProjectionSupport(
            viewer, getAnnotationAccess(), getSharedColors());

//    annotationDrawer = new AnnotationDrawer(projectionSupport
//            .getAnnotationPainterDrawingStrategy());
//    annotationDrawer.setCursorLineBackground(getCursorLineBackground());

//    projectionSupport.setAnnotationPainterDrawingStrategy(annotationDrawer);
    projectionSupport.addSummarizableAnnotationType(ModelicaEclipseCompiler.ERROR_MARKER_ID);
    projectionSupport.install();
}

private void configureDecorationSupport(ProjectionViewer viewer) {

	// TODO: This should probably be updated to the new Preference API, not sure how, though
    // Set default values for brace matching.
    IPreferenceStore preferenceStore = getPreferenceStore();
    preferenceStore.setDefault(IDEConstants.KEY_BRACE_MATCHING, true);
    PreferenceConverter.setDefault(preferenceStore,
            IDEConstants.KEY_BRACE_MATCHING_COLOR,
            IDEConstants.BRACE_MATCHING_COLOR);

    // Configure brace matching and ensure decoration support
    // has been created and configured.
    SourceViewerDecorationSupport decoration = getSourceViewerDecorationSupport(viewer);
    decoration.setCharacterPairMatcher(new ModelicaCharacterPairMatcher(viewer));
    decoration.setMatchingCharacterPainterPreferenceKeys(
            IDEConstants.KEY_BRACE_MATCHING,
            IDEConstants.KEY_BRACE_MATCHING_COLOR);
}

//@Override
//protected void handlePreferenceStoreChanged(PropertyChangeEvent event) {
//    if (Util.is(event.getProperty()).among(EDITOR_CURRENT_LINE,
//            EDITOR_CURRENT_LINE_COLOR)) {
//        annotationDrawer.setCursorLineBackground(getCursorLineBackground());
//    }
//    super.handlePreferenceStoreChanged(event);
//}
//
//private Color getCursorLineBackground() {
//
//	// TODO: This should probably be updated to the new Preference API, not sure how, though
//    if (!getPreferenceStore().getBoolean(EDITOR_CURRENT_LINE))
//        return null;
//
//    return new Color(Display.getCurrent(), PreferenceConverter.getColor(
//            getPreferenceStore(), EDITOR_CURRENT_LINE_COLOR));
//}

/**
 * Sets source viewer configuration to a {@link ViewerConfiguration} and creates
 * control.
 */
@Override
public void createPartControl(Composite parent) {
    super.setSourceViewerConfiguration(new ViewerConfiguration(this));
    super.createPartControl(parent);
    update();
}

/**
 * Can return an {@link IContentOutlinePage}.
 * 
 * @see org.eclipse.core.runtime.IAdaptable#getAdapter(java.lang.Class)
 */
@SuppressWarnings("unchecked")
@Override
public Object getAdapter(Class required) {

    if (IContentOutlinePage.class.equals(required))
        return fSourceOutlinePage;

    return super.getAdapter(required);
}

/**
 * Gets the source outline page associated with this editor.
 * 
 * @return the source outline page
 * @see IContentOutlinePage
 */
public IContentOutlinePage getSourceOutlinePage() {
    return fSourceOutlinePage;
}

/**
 * Gets the instance outline page associated with this editor.
 * 
 * @return the instance outline page
 * @see IContentOutlinePage
 */
public IContentOutlinePage getInstanceOutlinePage() {
    return fInstanceOutlinePage;
}

/**
 * Updates editor to match input change.
 * 
 * @see AbstractTextEditor#doSetInput(IEditorInput)
 */
@Override
protected void doSetInput(IEditorInput input) throws CoreException {
  
    assert input != null : "Null unexpected";

    super.doSetInput(input);

    if (compResult != null)
        compResult.destruct(this);

    file = new EditorFile(input);

    compResult = 
        file.inModelicaProject()
            ? new GlobalCompilationResult(file, this)
            : new LocalCompilationResult(file, this);

    if (getSourceViewer() != null)
        update();
}

@Override
protected void createActions() {
    super.createActions();
    for (Action action : new Action[] { new ExpandAllAction(this),
            new CollapseAllAction(this), new FormatRegionAction(this),
            new ToggleComment(this), errorCheckAction, compileFMUAction, 
            toggleAnnotationsAction,
            goToDeclaration }) {
        super.setAction(action.getId(), action);
    }

    updateCurrentClassListeners();
}

@Override
protected void rulerContextMenuAboutToShow(IMenuManager menu) {
    super.rulerContextMenuAboutToShow(menu);
    addAction(menu, IDEConstants.ACTION_EXPAND_ALL_ID);
    addAction(menu, IDEConstants.ACTION_COLLAPSE_ALL_ID);
}

/**
 * If edited file is compiled locally, this method is called by reconciler to
 * compile AST and update editor.
 * 
 * @param document currently edited document
 */
public void recompileLocal(IDocument document) {

    compResult.recompileLocal(document(), file.iFile());

    Display.getDefault().asyncExec(new Runnable() {
        public void run() {
            update();
        }
    });
}

// ASTRegistry listener method
public void childASTChanged(IProject project, String key) {
    compResult.update(project, key);
    update();
}

// ASTRegistry listener method
public void projectASTChanged(IProject project) {
    compResult.update(project);
    update();
}

/**
 * Updates the outline and the view
 */
protected void update() {
    if (document() == null) 
        return; 
    
    setupDocumentPartitioner(document());

    if (compResult.failed()) 
        return;

    // Update outline
    fSourceOutlinePage.updateAST(compResult.root());
    fInstanceOutlinePage.updateAST(compResult.root());
    goToDeclaration.updateAST(compResult.root());

//    updateProjectionAnnotations();
    updateCurrentClassListeners();
}

private void setupDocumentPartitioner(IDocument document) {
    try {
    	if (annotationFolds != null)
    		annotationFolds.dispose();
        annotationFolds = new AnnotationFoldUpdater(document);
        
        IDocumentPartitioner wanted = fPartitioner;
        IDocumentPartitioner current = document.getDocumentPartitioner();
        if (wanted != current) {
            if (current != null)
                current.disconnect();
            wanted.connect(document);
            document.setDocumentPartitioner(wanted);
        }
    } catch (Error e) { // The scanner can throw an Error if it fails
    }
}

public void dispose() {
	annotationFolds.dispose();
	super.dispose();
}

/**
 * Update projection annotations
 */
//@SuppressWarnings("unchecked")
//private void updateProjectionAnnotations() {
//
//    ProjectionAnnotationModel model = getAnnotationModel();
//    if (model == null)
//        return;
//
//    Collection<Annotation> oldAnnotations = 
//        Util.listFromIterator(
//            model.getAnnotationIterator());
//
//    HashMap<Annotation, Position> newAnnotations =
//        new EditorAnnotationMap(
//            compResult.root().foldingPositions(document()),
//            this);
//
//    model.modifyAnnotations(
//        oldAnnotations.toArray(new Annotation[] {}),
//        newAnnotations,
//        null);
//}

private ProjectionAnnotationModel getAnnotationModel() {
    ProjectionViewer viewer = (ProjectionViewer) getSourceViewer();
    viewer.enableProjection();
    return viewer.getProjectionAnnotationModel();
}

@Override
protected void handleCursorPositionChanged() {
    super.handleCursorPositionChanged();
    updateCurrentClassListeners();
}

private void updateCurrentClassListeners() {
    BaseClassDecl containingClass = compResult.classContaining(selection());
    for (CurrentClassAction listener : currentClassListeners)
    	listener.setCurrentClass(containingClass);
}

/**
 * Selects the <code> node </code> in the editor contains file <code>
     *  node </code> is
 * from.
 * 
 * @param node node to select
 * @return whether file <code> node </code> is from matches file in editor
 */
public boolean selectNode(ASTNode<?> node) {

    File nodeFile = new File(node.containingFileName());
	File editorFile = new File(file.path());
	boolean matchesInput = editorFile.equals(nodeFile);

    if (matchesInput) {

        ASTNode<?> sel = node.getSelectionNode();
        if (sel.offset() >= 0 && sel.length() >= 0)
            selectAndReveal(sel.offset(), sel.length());
    }

    return matchesInput;
}

public IDocument document() {
	return (getSourceViewer() == null) ? null : getSourceViewer().getDocument();
}

public ISourceViewer sourceViewer() {
    return getSourceViewer();
}

public ITextSelection selection() {
    return (ITextSelection) getSelectionProvider().getSelection();
}

public IReconcilingStrategy strategy() {
    return compResult.compilationStrategy();
}

//Commented out to disable name completion
//public CompletionProcessor completions() {
//    return completions;
//}

public EditorFile editorFile() {
    return file;
}

public boolean annotationsVisible() {
    return toggleAnnotationsAction.isVisible();
}

private class AnnotationFoldUpdater implements IDocumentPartitioningListener {
	// TODO: Perhaps move this to a separate file?
	
	private IDocument doc;

	public AnnotationFoldUpdater(IDocument document) {
		doc = document;
		doc.addDocumentPartitioningListener(this);
	}
	
	public void dispose() {
		doc.removeDocumentPartitioningListener(this);
	}

	public void documentPartitioningChanged(IDocument document) {
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
			StyledText widget = getSourceViewer().getTextWidget();
			widget.redraw();
			widget.update();
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
		    ProjectionAnnotationModel model = getAnnotationModel();
		    if (model == null)
		        return Status.OK_STATUS;
	
		    Collection<ITypedRegion> parts = getPartitions(doc, Modelica32PartitionScanner.ANNOTATION_PARTITION);
		    List<Annotation> old = Util.listFromIterator(model.getAnnotationIterator());
		    Collections.sort(old, new PositionSorter(model));
			Iterator<Annotation> oldIt = old.iterator();
			
			Map<Annotation, Position> added = new HashMap<Annotation, Position>();
			ArrayList<Annotation> removed = new ArrayList<Annotation>();
			
			ITextSelection sel = selection();
			boolean hideAnno = !annotationsVisible();
			
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

}