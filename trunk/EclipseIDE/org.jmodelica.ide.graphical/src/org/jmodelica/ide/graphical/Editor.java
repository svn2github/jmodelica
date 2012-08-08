package org.jmodelica.ide.graphical;

import java.util.EventObject;
import java.util.Iterator;
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
import org.eclipse.ui.IEditorPart;
import org.jastadd.plugin.Activator;
import org.jmodelica.ide.graphical.actions.OpenComponentAction;
import org.jmodelica.ide.graphical.actions.RotateAction;
import org.jmodelica.ide.graphical.edit.EditPartFactory;
import org.jmodelica.ide.graphical.proxy.AbstractDiagramProxy;
import org.jmodelica.ide.graphical.proxy.AbstractNodeProxy;
import org.jmodelica.ide.graphical.proxy.ClassDiagramProxy;
import org.jmodelica.ide.graphical.proxy.ComponentDiagramProxy;
import org.jmodelica.ide.graphical.proxy.ComponentProxy;
import org.jmodelica.modelica.compiler.ClassDecl;
import org.jmodelica.modelica.compiler.InstProgramRoot;
import org.jmodelica.modelica.compiler.SourceRoot;

public class Editor extends GraphicalEditor {

	private GraphicalEditorInput input;
	private ClassDiagramProxy dp;
	private Stack<ComponentProxy> openComponentStack;
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
			rootLabel.setText("<a>" + dp.getClassName() + "</a>");
			rootLabel.addListener(SWT.Selection, new Listener() {

				@Override
				public void handleEvent(Event event) {
					openRootComponent();
				}
			});

			Iterator<ComponentProxy> it = openComponentStack.iterator();
			while (it.hasNext()) {
				final ComponentProxy component = it.next();
				Label arrow = new Label(breadcrumbsBar, SWT.NONE);
				arrow.setText(".");
				if (it.hasNext()) {
					Link componentLabel = new Link(breadcrumbsBar, SWT.NONE);
					componentLabel.setText("<a>" + component.getComponentName() + "</a>");
					componentLabel.addListener(SWT.Selection, new Listener() {
						@Override
						public void handleEvent(Event event) {
							openPrevComponent(component);
						}
					});
				} else {
					Label componentLabel = new Label(breadcrumbsBar, SWT.NONE);
					componentLabel.setText(component.getComponentName());
				}
			}
		} else {
			breadcrumbsBar.setVisible(false);
			((RowLayout) breadcrumbsBar.getLayout()).marginBottom = 0;
			((RowLayout) breadcrumbsBar.getLayout()).marginTop = 0;
		}
		breadcrumbsBar.getParent().layout(true, true);
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
		dp = new ClassDiagramProxy(getProgramRoot().simpleLookupInstClassDecl(input.getClassName()));
		openComponentStack = new Stack<ComponentProxy>();
		setContent();
		getGraphicalViewer().getRootEditPart().refresh();
	}

	@Override
	public void commandStackChanged(EventObject event) {
		firePropertyChange(IEditorPart.PROP_DIRTY);
		super.commandStackChanged(event);
	}

	private InstProgramRoot getProgramRoot() {
		return ((SourceRoot) Activator.getASTRegistry().lookupAST(null, input.getProject())).getProgram().getInstProgramRoot();
	}

	private void setContent() {
		if (input.editIcon()) {
			getGraphicalViewer().setContents(dp);
		} else {
			refreshBreadcrumbsBar();
			
			AbstractDiagramProxy adp;
			if (openComponentStack.isEmpty())
				adp = dp;
			else
				adp = new ComponentDiagramProxy(openComponentStack.peek());
			getGraphicalViewer().setContents(adp);
			adp.constructConnections();
		}
	}

	@Override
	public void doSave(final IProgressMonitor monitor) {
		if (dp == null)
			return;

		SafeRunner.run(new SafeRunnable() {
			@Override
			public void run() throws Exception {
				dp.saveModelicaFile(monitor);
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
	 * Shows the diagram of a sub component. If <code>component</code> is a sub
	 * component to the currently shown component it will be shown.
	 * 
	 * @param componentProxy Component that we are trying to open
	 * @return If the component was found and displayed
	 */
	public boolean openSubComponent(ComponentProxy component) {
		System.out.println(component.getComponentName());
		AbstractNodeProxy node;
		if (openComponentStack.isEmpty())
			node = dp;
		else
			node = openComponentStack.peek();

		if (component.isParent(node)) {
			openComponentStack.push(component);
			setContent();
			return true;
		}
		System.out.println("No definition found!");
		return false;
	}

	/**
	 * Shows the diagram of a component currently on the open component stack.
	 * 
	 * @param component Component that we are trying to open
	 * @return If the component was found and displayed
	 */
	public boolean openPrevComponent(ComponentProxy component) {
		for (int i = 0; i < openComponentStack.size(); i++) {
			if (component == openComponentStack.get(i)) {
				while (i + 1 < openComponentStack.size())
					openComponentStack.pop();

				setContent();
				return true;
			}
		}
		return false;
	}

	/**
	 * Shows the diagram of the model that is open. Clears the component stack.
	 * 
	 * @return True on success
	 */
	public boolean openRootComponent() {
		openComponentStack.clear();
		setContent();
		return true;
	}

	public void flushInst() {
		long start = System.currentTimeMillis();
		ClassDecl cd = getProgramRoot().simpleLookupInstClassDecl(input.getClassName()).getClassDecl();
		cd.flushCache();
		System.out.println("flush src classDecl, t+" + (System.currentTimeMillis() - start));
		getProgramRoot().flushAll();
		System.out.println("flush program root, t+" + (System.currentTimeMillis() - start));
		dp.setInstClassDecl(getProgramRoot().simpleLookupInstClassDecl(input.getClassName()));
		System.out.println("lookup input class, t+" + (System.currentTimeMillis() - start));
		setContent();
		System.out.println("set content, t+" + (System.currentTimeMillis() - start));
	}

}