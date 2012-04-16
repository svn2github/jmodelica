package org.jmodelica.ide.graphical;

import java.io.ByteArrayInputStream;
import java.util.Stack;

import org.eclipse.core.runtime.Assert;
import org.eclipse.core.runtime.IProgressMonitor;
import org.eclipse.core.runtime.SafeRunner;
import org.eclipse.gef.ContextMenuProvider;
import org.eclipse.gef.DefaultEditDomain;
import org.eclipse.gef.GraphicalViewer;
import org.eclipse.gef.SnapToGrid;
import org.eclipse.gef.editparts.ScalableFreeformRootEditPart;
import org.eclipse.gef.ui.actions.ToggleGridAction;
import org.eclipse.gef.ui.actions.ToggleSnapToGeometryAction;
import org.eclipse.gef.ui.parts.GraphicalEditor;
import org.eclipse.gef.ui.parts.GraphicalViewerKeyHandler;
import org.eclipse.jface.action.IAction;
import org.eclipse.jface.util.SafeRunnable;
import org.eclipse.swt.SWT;
import org.eclipse.swt.dnd.TextTransfer;
import org.eclipse.swt.layout.FillLayout;
import org.eclipse.swt.layout.GridData;
import org.eclipse.swt.layout.GridLayout;
import org.eclipse.swt.layout.RowLayout;
import org.eclipse.swt.widgets.Canvas;
import org.eclipse.swt.widgets.Composite;
import org.eclipse.swt.widgets.Control;
import org.eclipse.swt.widgets.Event;
import org.eclipse.swt.widgets.Label;
import org.eclipse.swt.widgets.Link;
import org.eclipse.swt.widgets.Listener;
import org.eclipse.ui.IEditorInput;
import org.jastadd.plugin.Activator;
import org.jmodelica.icons.Component;
import org.jmodelica.ide.graphical.actions.OpenComponentAction;
import org.jmodelica.ide.graphical.actions.RotateAction;
import org.jmodelica.ide.graphical.editparts.EditPartFactory;
import org.jmodelica.modelica.compiler.InstClassDecl;
import org.jmodelica.modelica.compiler.InstComponentDecl;
import org.jmodelica.modelica.compiler.List;
import org.jmodelica.modelica.compiler.SourceRoot;
import org.jmodelica.modelica.compiler.StoredDefinition;

public class Editor extends GraphicalEditor {

	private GraphicalEditorInput input;
	private InstClassDecl icd;
	private Stack<InstComponentDecl> openComponentStack;
	private Composite breadcrumbsBar;

	public Editor() {
		setEditDomain(new DefaultEditDomain(this));
	}

	@Override
	public void createPartControl(Composite parent) {
		Composite c = new Composite(parent, SWT.NONE);
		GridLayout layout = new GridLayout(1, true);
		layout.horizontalSpacing = 0;
		layout.verticalSpacing = 0;
		layout.marginWidth = 0;
		layout.marginHeight = 0;
		layout.marginLeft = 0;
		layout.marginRight = 0;
		layout.marginTop = 0;
		layout.marginBottom = 0;
		c.setLayout(layout);

		createBreadcrumbsBar(c);

		Composite composite = new Composite(c, SWT.NONE);
		composite.setLayoutData(new GridData(GridData.FILL_BOTH));
		composite.setLayout(new FillLayout());
		super.createPartControl(composite);
	}

	private void createBreadcrumbsBar(Composite parent) {
		breadcrumbsBar = new Canvas(parent, SWT.NONE);
		RowLayout layout = new RowLayout();
		layout.center = true;
		breadcrumbsBar.setLayout(layout);
	}

	private void refreshBreadcrumbsBar() {
		Control[] cs = breadcrumbsBar.getChildren();
		for (Control c : cs) {
			c.dispose();
		}
		if (!openComponentStack.isEmpty()) {
			((RowLayout) breadcrumbsBar.getLayout()).marginBottom = 3;
			((RowLayout) breadcrumbsBar.getLayout()).marginTop = 3;
			breadcrumbsBar.setVisible(true);

			Link rootLabel = new Link(breadcrumbsBar, SWT.NONE);
			rootLabel.setText("<a>" + icd.name() + "</a>");
			rootLabel.addListener(SWT.Selection, new Listener() {

				@Override
				public void handleEvent(Event event) {
					openSubComponent(null);
				}
			});

			int i = openComponentStack.size();
			for (final InstComponentDecl icd : openComponentStack) {
				Label arrow = new Label(breadcrumbsBar, SWT.NONE);
				arrow.setText(".");
				if (--i == 0) {
					Label componentLabel = new Label(breadcrumbsBar, SWT.NONE);
					componentLabel.setText(icd.name());
				} else {
					Link componentLabel = new Link(breadcrumbsBar, SWT.NONE);
					componentLabel.setText("<a>" + icd.name() + "</a>");
					componentLabel.addListener(SWT.Selection, new Listener() {

						@Override
						public void handleEvent(Event event) {
							openSubComponent(icd.getComponent());
						}
					});
				}
			}
		} else {
			breadcrumbsBar.setVisible(false);
			((RowLayout) breadcrumbsBar.getLayout()).marginBottom = 0;
			((RowLayout) breadcrumbsBar.getLayout()).marginTop = 0;
		}
		breadcrumbsBar.getParent().layout(true);
	}

	@Override
	protected void configureGraphicalViewer() {
		super.configureGraphicalViewer();
		GraphicalViewer viewer = getGraphicalViewer();
		viewer.setEditPartFactory(new EditPartFactory());
		viewer.setRootEditPart(new ScalableFreeformRootEditPart());
		viewer.setKeyHandler(new GraphicalViewerKeyHandler(viewer));
		viewer.addDropTargetListener(new TextTransferDropTargetListener(viewer, TextTransfer.getInstance()));

		viewer.setProperty(SnapToGrid.PROPERTY_GRID_ENABLED, false);
		viewer.setProperty(SnapToGrid.PROPERTY_GRID_VISIBLE, false);

		getActionRegistry().registerAction(new ToggleSnapToGeometryAction(getGraphicalViewer()));
		getActionRegistry().registerAction(new ToggleGridAction(getGraphicalViewer()));

		ContextMenuProvider contextMenu = new EditorContexMenuProvider(viewer, getActionRegistry());
		viewer.setContextMenu(contextMenu);
	}

	@Override
	protected void initializeGraphicalViewer() {
		SourceRoot sourceRoot = (SourceRoot) Activator.getASTRegistry().lookupAST(null, input.getProject());
		icd = sourceRoot.getProgram().getInstProgramRoot().simpleLookupInstClassDecl(input.getClassName());
		openComponentStack = new Stack<InstComponentDecl>();
		setContent();
	}

	private void setContent() {
		if (input.editIcon()) {
			getGraphicalViewer().setContents(icd.icon());
		} else {
			refreshBreadcrumbsBar();
			if (openComponentStack.isEmpty())
				getGraphicalViewer().setContents(icd.diagram());
			else
				getGraphicalViewer().setContents(openComponentStack.peek().myInstClass().diagram());
		}
	}

	@Override
	public void doSave(final IProgressMonitor monitor) {
		if (icd == null)
			return;
		
		SafeRunner.run(new SafeRunnable() {
			public void run() throws Exception {
				StoredDefinition definition = icd.getDefinition();
				definition.getFile().setContents(new ByteArrayInputStream(definition.prettyPrintFormatted().getBytes()), false, true, monitor);
				getCommandStack().markSaveLocation();
			}
		});
	}

	@Override
	protected void setInput(IEditorInput input) {
		super.setInput(input);
		Assert.isLegal(input instanceof GraphicalEditorInput, "The editor only support opening Modelica classes.");

		this.input = (GraphicalEditorInput) input;
		setPartName(input.getName());
	}

	@SuppressWarnings("unchecked")
	@Override
	protected void createActions() {
		super.createActions();

		IAction action;

		action = new RotateAction(this, -90);
		getActionRegistry().registerAction(action);
		getSelectionActions().add(action.getId());

		action = new RotateAction(this, -45);
		getActionRegistry().registerAction(action);
		getSelectionActions().add(action.getId());

		action = new RotateAction(this, 45);
		getActionRegistry().registerAction(action);
		getSelectionActions().add(action.getId());

		action = new RotateAction(this, 90);
		getActionRegistry().registerAction(action);
		getSelectionActions().add(action.getId());

		action = new RotateAction(this, 180);
		getActionRegistry().registerAction(action);
		getSelectionActions().add(action.getId());

		action = new OpenComponentAction(this);
		getActionRegistry().registerAction(action);
		getSelectionActions().add(action.getId());

	}

	/**
	 * Shows the diagram of a sub component. If <code>component</code> is null
	 * the root model diagram will be shown. If the component is in the stack of
	 * opened components it's diagram will be shown. If <code>component</code>
	 * is a sub component to the currently shown component it will be shown. In
	 * all other cases nothing will happen and false will be returned.
	 * 
	 * @param component Component that we are trying to open
	 * @return If the component was found and displayed
	 */
	public boolean openSubComponent(Component component) {
		// Check if root should be displayed.
		if (component == null) {
			openComponentStack.clear();
			setContent();
			return true;
		}

		// Check if it's a component on the stack.
		for (int i = 0; i < openComponentStack.size(); i++) {
			if (component == openComponentStack.get(i).getComponent()) {
				while (i + 1 < openComponentStack.size())
					openComponentStack.pop();

				setContent();
				return true;
			}
		}

		// Check if it's a sub component.
		List<InstComponentDecl> decls;
		if (openComponentStack.isEmpty())
			decls = icd.getInstComponentDecls();
		else
			decls = openComponentStack.peek().myInstClass().getInstComponentDecls();

		for (InstComponentDecl decl : decls) {
			if (component == decl.getComponent()) {
				openComponentStack.push(decl);
				setContent();
				return true;
			}
		}
		return false;
	}
}