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
package org.jmodelica.ide.textual.editor;

//import static org.eclipse.ui.texteditor.AbstractDecoratedTextEditorPreferenceConstants.EDITOR_CURRENT_LINE;
//import static org.eclipse.ui.texteditor.AbstractDecoratedTextEditorPreferenceConstants.EDITOR_CURRENT_LINE_COLOR;

import java.io.File;

import org.eclipse.core.resources.IFile;
import org.eclipse.core.runtime.CoreException;
import org.eclipse.jface.action.Action;
import org.eclipse.jface.action.IMenuManager;
import org.eclipse.jface.preference.IPreferenceStore;
import org.eclipse.jface.preference.PreferenceConverter;
import org.eclipse.jface.text.IDocument;
import org.eclipse.jface.text.IDocumentPartitioner;
import org.eclipse.jface.text.ITextSelection;
import org.eclipse.jface.text.TextSelection;
import org.eclipse.jface.text.reconciler.IReconcilingStrategy;
import org.eclipse.jface.text.rules.FastPartitioner;
import org.eclipse.jface.text.source.ISourceViewer;
import org.eclipse.jface.text.source.IVerticalRuler;
import org.eclipse.jface.text.source.projection.ProjectionAnnotationModel;
import org.eclipse.jface.text.source.projection.ProjectionSupport;
import org.eclipse.jface.text.source.projection.ProjectionViewer;
import org.eclipse.jface.viewers.ISelection;
import org.eclipse.swt.custom.StyledText;
import org.eclipse.swt.widgets.Composite;
import org.eclipse.swt.widgets.Display;
import org.eclipse.ui.IEditorInput;
import org.eclipse.ui.texteditor.AbstractDecoratedTextEditor;
import org.eclipse.ui.texteditor.AbstractTextEditor;
import org.eclipse.ui.texteditor.SourceViewerDecorationSupport;
import org.eclipse.ui.views.contentoutline.IContentOutlinePage;
import org.jastadd.ed.core.model.IASTChangeEvent;
import org.jastadd.ed.core.model.IASTChangeListener;
import org.jastadd.ed.core.model.node.IASTNode;
import org.jmodelica.generated.scanners.Modelica32PartitionScanner;
import org.jmodelica.ide.IDEConstants;
import org.jmodelica.ide.helpers.CachedClassDecl;
import org.jmodelica.ide.helpers.EditorFile;
import org.jmodelica.ide.helpers.EditorWithFile;
import org.jmodelica.ide.helpers.ICurrentClassListener;
import org.jmodelica.ide.helpers.hooks.IASTEditor;
import org.jmodelica.ide.outline.InstanceOutlinePage;
import org.jmodelica.ide.outline.SourceOutlinePage;
import org.jmodelica.ide.textual.actions.CollapseAllAction;
import org.jmodelica.ide.textual.actions.CompileFMUAction;
import org.jmodelica.ide.textual.actions.ErrorCheckAction;
import org.jmodelica.ide.textual.actions.ExpandAllAction;
import org.jmodelica.ide.textual.actions.FormatRegionAction;
import org.jmodelica.ide.textual.actions.GoToDeclaration;
import org.jmodelica.ide.textual.actions.ToggleAnnotationsAction;
import org.jmodelica.ide.textual.actions.ToggleComment;
import org.jmodelica.modelica.compiler.ASTNode;
import org.jmodelica.modelica.compiler.ClassDecl;

/**
 * Modelica source editor.
 */
public class Editor extends AbstractDecoratedTextEditor implements
		IASTChangeListener, EditorWithFile, ICurrentClassListener, IASTEditor {

	private final SourceOutlinePage fSourceOutlinePage;
	private final InstanceOutlinePage fInstanceOutlinePage;

	private IDocumentPartitioner fPartitioner;

	// private AnnotationDrawer annotationDrawer; // For folding

	private CompilationResult compResult;
	public EditorFile file;

	private boolean editable;
	private static boolean nextEditable = true;

	private final ErrorCheckAction errorCheckAction;
	private final CompileFMUAction compileFMUAction;
	private final ICurrentClassListener[] currentClassListeners;
	private final ToggleAnnotationsAction toggleAnnotationsAction;
	private final GoToDeclaration goToDeclaration;
	// Commented out to disable name completion
	// private final CompletionProcessor completions;
	private AnnotationFoldUpdater annotationFolds;

	/**
	 * Standard constructor.
	 */
	public Editor() {
		super();
		fSourceOutlinePage = new SourceOutlinePage(this);
		fInstanceOutlinePage = new InstanceOutlinePage(this);
		// Commented out to disable name completion
		// completions =
		// new CompletionProcessor(this);
		goToDeclaration = new GoToDeclaration(this);
		errorCheckAction = new ErrorCheckAction();
		compileFMUAction = new CompileFMUAction(this);
		currentClassListeners = new ICurrentClassListener[] { errorCheckAction,
				compileFMUAction };
		toggleAnnotationsAction = new ToggleAnnotationsAction(this);
		fPartitioner = new FastPartitioner(new Modelica32PartitionScanner(),
				Modelica32PartitionScanner.LEGAL_PARTITIONS);
		editable = nextEditable;
		nextEditable = true;
	}

	public static void nextReadOnly(boolean readOnly) {
		nextEditable = !readOnly;
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

		ProjectionViewer viewer = new ProjectionViewer(parent, ruler,
				getOverviewRuler(), isOverviewRulerVisible(), styles);

		configureProjectionSupport(viewer);
		configureDecorationSupport(viewer);

		return viewer;
	}

	private void configureProjectionSupport(ProjectionViewer viewer) {
		ProjectionSupport projectionSupport = new ProjectionSupport(viewer,
				getAnnotationAccess(), getSharedColors());

		// annotationDrawer = new AnnotationDrawer(projectionSupport
		// .getAnnotationPainterDrawingStrategy());
		// annotationDrawer.setCursorLineBackground(getCursorLineBackground());

		// projectionSupport.setAnnotationPainterDrawingStrategy(annotationDrawer);
		projectionSupport
				.addSummarizableAnnotationType(IDEConstants.ERROR_MARKER_SYNTACTIC_ID);
		projectionSupport
				.addSummarizableAnnotationType(IDEConstants.ERROR_MARKER_SEMANTIC_ID);
		projectionSupport.install();
	}

	private void configureDecorationSupport(ProjectionViewer viewer) {

		// TODO: This should probably be updated to the new Preference API, not
		// sure how, though
		// Set default values for brace matching.
		IPreferenceStore preferenceStore = getPreferenceStore();
		preferenceStore.setDefault(IDEConstants.KEY_BRACE_MATCHING, true);
		PreferenceConverter.setDefault(preferenceStore,
				IDEConstants.KEY_BRACE_MATCHING_COLOR,
				IDEConstants.BRACE_MATCHING_COLOR);

		// Configure brace matching and ensure decoration support
		// has been created and configured.
		SourceViewerDecorationSupport decoration = getSourceViewerDecorationSupport(viewer);
		decoration.setCharacterPairMatcher(new ModelicaCharacterPairMatcher(
				viewer));
		decoration.setMatchingCharacterPainterPreferenceKeys(
				IDEConstants.KEY_BRACE_MATCHING,
				IDEConstants.KEY_BRACE_MATCHING_COLOR);
	}

	// @Override
	// protected void handlePreferenceStoreChanged(PropertyChangeEvent event) {
	// if (Util.is(event.getProperty()).among(EDITOR_CURRENT_LINE,
	// EDITOR_CURRENT_LINE_COLOR)) {
	// annotationDrawer.setCursorLineBackground(getCursorLineBackground());
	// }
	// super.handlePreferenceStoreChanged(event);
	// }
	//
	// private Color getCursorLineBackground() {
	//
	// // TODO: This should probably be updated to the new Preference API, not
	// sure how, though
	// if (!getPreferenceStore().getBoolean(EDITOR_CURRENT_LINE))
	// return null;
	//
	// return new Color(Display.getCurrent(), PreferenceConverter.getColor(
	// getPreferenceStore(), EDITOR_CURRENT_LINE_COLOR));
	// }

	/**
	 * Sets source viewer configuration to a {@link ViewerConfiguration} and
	 * creates control.
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
			compResult.dispose(this);

		file = new EditorFile(input);

		compResult = file.inModelicaProject() ? new GlobalCompilationResult(
				file, this) : new LocalCompilationResult(file, this);
		System.out.println("Editor uses compresult: " + file.toString());
		fSourceOutlinePage.setFile(file.iFile());
		// fnewSourceOutlinePage.setFile(file.iFile());
		fInstanceOutlinePage.setFile(file.iFile());
		// fInstanceOutlinePage2.setFile(file.iFile());
		if (getSourceViewer() != null)
			update();

		if (getPartName().equals("package.mo"))
			setPartName(file.getDirName() + "/package.mo");
	}

	public boolean isEditable() {
		return editable && super.isEditable();
	}

	public boolean isDirty() {
		return editable && super.isDirty();
	}

	public boolean isEditorInputReadOnly() {
		return !editable || super.isEditorInputReadOnly();
	}

	public boolean isEditorInputModifiable() {
		return editable && super.isEditorInputModifiable();
	}

	@Override
	protected void createActions() {
		super.createActions();
		for (Action action : new Action[] { new ExpandAllAction(this),
				new CollapseAllAction(this), new FormatRegionAction(this),
				new ToggleComment(this), errorCheckAction, compileFMUAction,
				toggleAnnotationsAction, goToDeclaration }) {
			super.setAction(action.getId(), action);
		}
		selectNode(false, "", 0, 0);
	}

	@Override
	protected void rulerContextMenuAboutToShow(IMenuManager menu) {
		super.rulerContextMenuAboutToShow(menu);
		addAction(menu, IDEConstants.ACTION_EXPAND_ALL_ID);
		addAction(menu, IDEConstants.ACTION_COLLAPSE_ALL_ID);
	}

	/**
	 * If edited file is compiled locally, this method is called by reconciler
	 * to compile AST and update editor.
	 * 
	 * @param document
	 *            currently edited document
	 */
	public void recompileLocal(IDocument document) {

		IFile iFile = file.iFile();
		compResult.recompileLocal(document(), iFile);
		System.out.println("recompiled docu");

		Display.getDefault().asyncExec(new Runnable() {
			public void run() {
				update();
			}
		});
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
		// fSourceOutlinePage.astChanged(null);
		// fnewSourceOutlinePage.astChanged(null);
		// fInstanceOutlinePage.astChanged(null);
		// fInstanceOutlinePage2.astChanged(null);
		goToDeclaration.updateAST(compResult.root());

		// updateProjectionAnnotations();
	}

	private void setupDocumentPartitioner(IDocument document) {
		try {
			if (annotationFolds != null)
				annotationFolds.dispose();
			annotationFolds = new AnnotationFoldUpdater(document, this);

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

	public void redraw() {
		StyledText widget = getSourceViewer().getTextWidget();
		widget.redraw();
		widget.update();
	}

	/**
	 * Update projection annotations
	 */
	// @SuppressWarnings("unchecked")
	// private void updateProjectionAnnotations() {
	//
	// ProjectionAnnotationModel model = getAnnotationModel();
	// if (model == null)
	// return;
	//
	// Collection<Annotation> oldAnnotations =
	// Util.listFromIterator(
	// model.getAnnotationIterator());
	//
	// HashMap<Annotation, Position> newAnnotations =
	// new EditorAnnotationMap(
	// compResult.root().foldingPositions(document()),
	// this);
	//
	// model.modifyAnnotations(
	// oldAnnotations.toArray(new Annotation[] {}),
	// newAnnotations,
	// null);
	// }

	public ProjectionAnnotationModel getAnnotationModel() {
		ProjectionViewer viewer = (ProjectionViewer) getSourceViewer();
		viewer.enableProjection();
		return viewer.getProjectionAnnotationModel();
	}

	public void setCurrentClass(CachedClassDecl selected) {
		for (ICurrentClassListener listener : currentClassListeners)
			listener.setCurrentClass(selected);
	}

	/**
	 * Selects <code>node</code> in the editor if valid.
	 * 
	 * @param node
	 *            node to select
	 * @return whether file <code>node</code> is from matches file in editor
	 */
	public boolean selectNode(boolean notNull, String containingFileName,
			int selectionNodeOffset, int selectionNodeLength) {

		boolean matchesInput = false;
		if (notNull) {
			File nodeFile = new File(containingFileName);
			File editorFile = new File(file.path());
			matchesInput = editorFile.equals(nodeFile);
			if (matchesInput) {
				if (selectionNodeOffset >= 0 && selectionNodeLength >= 0)
					selectAndReveal(selectionNodeOffset, selectionNodeLength);
			}
		}

		return matchesInput;
	}

	public IDocument document() {
		return (getSourceViewer() == null) ? null : getSourceViewer()
				.getDocument();
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

	// Commented out to disable name completion
	// public CompletionProcessor completions() {
	// return completions;
	// }

	public EditorFile editorFile() {
		return file;
	}

	public boolean annotationsVisible() {
		return toggleAnnotationsAction.isVisible();
	}

	public ClassDecl getClassContainingCursor() {
		int offset = 0;
		int length = 0;

		ISelection sel = getSelectionProvider().getSelection();
		if (sel instanceof TextSelection) {
			TextSelection tsel = (TextSelection) sel;
			offset = tsel.getOffset();
			length = tsel.getLength();
		}

		ASTNode root = compResult.root();
		IASTNode iast = root.lookupChildAST(file.path());
		ASTNode ast = (iast != null) ? (ASTNode) iast : root;
		return ast.containingClassDecl(offset, length);
	}

	@Override
	public void astChanged(IASTChangeEvent e) {
		compResult.update(e);
		update();
	}
}