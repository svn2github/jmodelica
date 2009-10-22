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

import static org.eclipse.ui.texteditor.AbstractDecoratedTextEditorPreferenceConstants.EDITOR_CURRENT_LINE;
import static org.eclipse.ui.texteditor.AbstractDecoratedTextEditorPreferenceConstants.EDITOR_CURRENT_LINE_COLOR;

import java.util.Collection;
import java.util.HashMap;

import org.eclipse.core.resources.IProject;
import org.eclipse.core.runtime.CoreException;
import org.eclipse.jface.action.Action;
import org.eclipse.jface.action.IMenuManager;
import org.eclipse.jface.preference.IPreferenceStore;
import org.eclipse.jface.preference.PreferenceConverter;
import org.eclipse.jface.text.IDocument;
import org.eclipse.jface.text.IDocumentPartitioner;
import org.eclipse.jface.text.ITextSelection;
import org.eclipse.jface.text.Position;
import org.eclipse.jface.text.reconciler.IReconcilingStrategy;
import org.eclipse.jface.text.rules.FastPartitioner;
import org.eclipse.jface.text.source.Annotation;
import org.eclipse.jface.text.source.ISourceViewer;
import org.eclipse.jface.text.source.IVerticalRuler;
import org.eclipse.jface.text.source.projection.ProjectionAnnotationModel;
import org.eclipse.jface.util.PropertyChangeEvent;
import org.eclipse.swt.graphics.Color;
import org.eclipse.swt.widgets.Composite;
import org.eclipse.swt.widgets.Display;
import org.eclipse.ui.IEditorInput;
import org.eclipse.ui.texteditor.AbstractDecoratedTextEditor;
import org.eclipse.ui.texteditor.AbstractTextEditor;
import org.eclipse.ui.texteditor.SourceViewerDecorationSupport;
import org.eclipse.ui.views.contentoutline.IContentOutlinePage;
import org.jastadd.plugin.registry.IASTRegistryListener;
import org.jmodelica.folding.CharacterProjectionSupport;
import org.jmodelica.folding.CharacterProjectionViewer;
import org.jmodelica.generated.scanners.Modelica22PartitionScanner;
import org.jmodelica.ide.IDEConstants;
import org.jmodelica.ide.ModelicaCompiler;
import org.jmodelica.ide.editor.actions.CollapseAllAction;
import org.jmodelica.ide.editor.actions.ErrorCheckAction;
import org.jmodelica.ide.editor.actions.ExpandAllAction;
import org.jmodelica.ide.editor.actions.FormatRegionAction;
import org.jmodelica.ide.editor.actions.GoToDeclaration;
import org.jmodelica.ide.editor.actions.ToggleAnnotationsAction;
import org.jmodelica.ide.editor.actions.ToggleComment;
import org.jmodelica.ide.folding.AnnotationDrawer;
import org.jmodelica.ide.helpers.Util;
import org.jmodelica.ide.namecomplete.CompletionProcessor;
import org.jmodelica.ide.outline.InstanceOutlinePage;
import org.jmodelica.ide.outline.OutlinePage;
import org.jmodelica.ide.outline.SourceOutlinePage;
import org.jmodelica.modelica.compiler.ASTNode;


/**
 * Modelica source editor.
 */
public class Editor extends AbstractDecoratedTextEditor implements
        IASTRegistryListener {

private final OutlinePage fSourceOutlinePage;
private final InstanceOutlinePage fInstanceOutlinePage;

private IDocumentPartitioner fPartitioner;

private AnnotationDrawer annotationDrawer; // For folding

private CompilationResult compResult;
private EditorFile file;

private final ErrorCheckAction errorCheckAction;
private final ToggleAnnotationsAction toggleAnnotationsAction;
private final GoToDeclaration goToDeclaration;
private final CompletionProcessor completions;

/**
 * Standard constructor.
 */
public Editor() {
    super();
    fSourceOutlinePage = 
        new SourceOutlinePage(this);
    fInstanceOutlinePage = 
        new InstanceOutlinePage(this);
    completions = 
        new CompletionProcessor(this);
    goToDeclaration = 
        new GoToDeclaration(this);
    errorCheckAction = 
        new ErrorCheckAction();
    toggleAnnotationsAction = 
        new ToggleAnnotationsAction(this);
    fPartitioner = 
        new FastPartitioner(
            new Modelica22PartitionScanner(),
            Modelica22PartitionScanner.LEGAL_PARTITIONS);
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

    CharacterProjectionViewer viewer = new CharacterProjectionViewer(parent,
            ruler, getOverviewRuler(), isOverviewRulerVisible(), styles);

    configureProjectionSupport(viewer);
    configureDecorationSupport(viewer);

    return viewer;
}

private void configureProjectionSupport(CharacterProjectionViewer viewer) {
    CharacterProjectionSupport projectionSupport = new CharacterProjectionSupport(
            viewer, getAnnotationAccess(), getSharedColors());

    annotationDrawer = new AnnotationDrawer(projectionSupport
            .getAnnotationPainterDrawingStrategy());
    annotationDrawer.setCursorLineBackground(getCursorLineBackground());

    projectionSupport.setAnnotationPainterDrawingStrategy(annotationDrawer);
    projectionSupport
            .addSummarizableAnnotationType(ModelicaCompiler.ERROR_MARKER_ID);
    projectionSupport.install();
}

private void configureDecorationSupport(CharacterProjectionViewer viewer) {

    // Set default values for brace matching.
    IPreferenceStore preferenceStore = getPreferenceStore();
    preferenceStore.setDefault(IDEConstants.KEY_BRACE_MATCHING, true);
    PreferenceConverter.setDefault(preferenceStore,
            IDEConstants.KEY_BRACE_MATCHING_COLOR,
            IDEConstants.BRACE_MATCHING_COLOR);

    // Configure brace matching and ensure decoration support
    // has been created and configured.
    SourceViewerDecorationSupport decoration = getSourceViewerDecorationSupport(viewer);
    decoration
            .setCharacterPairMatcher(new ModelicaCharacterPairMatcher(viewer));
    decoration.setMatchingCharacterPainterPreferenceKeys(
            IDEConstants.KEY_BRACE_MATCHING,
            IDEConstants.KEY_BRACE_MATCHING_COLOR);
}

@Override
protected void handlePreferenceStoreChanged(PropertyChangeEvent event) {
    if (Util.is(event.getProperty()).among(EDITOR_CURRENT_LINE,
            EDITOR_CURRENT_LINE_COLOR)) {
        annotationDrawer.setCursorLineBackground(getCursorLineBackground());
    }
    super.handlePreferenceStoreChanged(event);
}

private Color getCursorLineBackground() {

    if (!getPreferenceStore().getBoolean(EDITOR_CURRENT_LINE))
        return null;

    return new Color(Display.getCurrent(), PreferenceConverter.getColor(
            getPreferenceStore(), EDITOR_CURRENT_LINE_COLOR));
}

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
        file.inWorkspace() 
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
            new ToggleComment(this), errorCheckAction,
            toggleAnnotationsAction,
            goToDeclaration }) {
        super.setAction(action.getId(), action);
    }

    updateErrorCheckAction();
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

    if (compResult.failed())
        return;

    if (document() == null) 
        return; 
    
    setupDocumentPartitioner(document());

    // Update outline
    fSourceOutlinePage.updateAST(compResult.root());
    System.out.println("-------------------------");
    System.out.println("Came here!");
    fInstanceOutlinePage.updateAST(compResult.root());
    goToDeclaration.updateAST(compResult.root());

    updateProjectionAnnotations();
    updateErrorCheckAction();
}

private void setupDocumentPartitioner(IDocument document) {

    try {
        IDocumentPartitioner wanted = fPartitioner;
        IDocumentPartitioner current = document.getDocumentPartitioner();
        if (wanted != current) {
            if (current != null)
                current.disconnect();
            wanted.connect(document);
            document.setDocumentPartitioner(wanted);
        }
    } catch (Error e) {
        e.printStackTrace();
    }
}

/**
 * Update projection annotations
 */
@SuppressWarnings("unchecked")
private void updateProjectionAnnotations() {

    ProjectionAnnotationModel model = 
        getAnnotationModel();
    
    if (model == null)
        return;

    Collection<Annotation> oldAnnotations = 
        Util.fromIterator(
            model.getAnnotationIterator());

    HashMap<Annotation, Position> newAnnotations =
        new EditorAnnotationMap(
            compResult.root().foldingPositions(document()),
            this);

    model.modifyAnnotations(
        oldAnnotations.toArray(new Annotation[] {}),
        newAnnotations,
        null);
}

private ProjectionAnnotationModel getAnnotationModel() {
    CharacterProjectionViewer viewer = (CharacterProjectionViewer) getSourceViewer();
    viewer.enableProjection();
    return viewer.getProjectionAnnotationModel();
}

@Override
protected void handleCursorPositionChanged() {
    super.handleCursorPositionChanged();
    updateErrorCheckAction();
}

private void updateErrorCheckAction() {
    errorCheckAction.setCurrentClass(compResult.classContaining(selection()));
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

    boolean matchesInput = file.path().equals(node.containingFileName());

    if (matchesInput) {

        ASTNode<?> sel = node.getSelectionNode();
        if (sel.getOffset() >= 0 && sel.getLength() >= 0)
            selectAndReveal(sel.getOffset(), sel.getLength());
    }

    return matchesInput;
}

public IDocument document() {
    return
        getSourceViewer() == null
        ? null
        : getSourceViewer().getDocument();
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

public CompletionProcessor completions() {
    return completions;
}

public EditorFile editorFile() {
    return file;
}

public boolean annotationsVisible() {
    return toggleAnnotationsAction.isVisible();
}

}