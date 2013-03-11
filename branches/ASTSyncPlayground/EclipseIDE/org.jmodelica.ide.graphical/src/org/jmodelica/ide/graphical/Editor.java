package org.jmodelica.ide.graphical;

import java.util.ArrayList;
import java.util.EventObject;
import java.util.Iterator;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Map.Entry;
import java.util.Stack;

import org.eclipse.core.runtime.Assert;
import org.eclipse.core.runtime.IProgressMonitor;
import org.eclipse.core.runtime.IStatus;
import org.eclipse.core.runtime.SafeRunner;
import org.eclipse.core.runtime.Status;
import org.eclipse.core.runtime.jobs.Job;
import org.eclipse.gef.ContextMenuProvider;
import org.eclipse.gef.DefaultEditDomain;
import org.eclipse.gef.EditPart;
import org.eclipse.gef.GraphicalViewer;
import org.eclipse.gef.SnapToGrid;
import org.eclipse.gef.editparts.ScalableFreeformRootEditPart;
import org.eclipse.gef.ui.actions.ToggleSnapToGeometryAction;
import org.eclipse.gef.ui.parts.GraphicalEditor;
import org.eclipse.gef.ui.parts.GraphicalViewerKeyHandler;
import org.eclipse.jface.action.IAction;
import org.eclipse.jface.dialogs.MessageDialog;
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
import org.eclipse.ui.IPartListener2;
import org.eclipse.ui.IWorkbenchPartReference;
import org.eclipse.ui.PlatformUI;
import org.eclipse.ui.progress.UIJob;
import org.jastadd.ed.core.model.IASTChangeEvent;
import org.jastadd.ed.core.model.IASTChangeListener;
import org.jmodelica.icons.Observable;
import org.jmodelica.icons.Observer;
import org.jmodelica.ide.graphical.actions.OpenComponentAction;
import org.jmodelica.ide.graphical.actions.RotateAction;
import org.jmodelica.ide.graphical.actions.ShowGridAction;
import org.jmodelica.ide.graphical.actions.SnapToGridAction;
import org.jmodelica.ide.graphical.edit.EditPartFactory;
import org.jmodelica.ide.graphical.proxy.AbstractDiagramProxy;
import org.jmodelica.ide.graphical.proxy.AbstractNodeProxy;
import org.jmodelica.ide.graphical.proxy.ClassDiagramProxy;
import org.jmodelica.ide.graphical.proxy.ComponentDiagramProxy;
import org.jmodelica.ide.graphical.proxy.ComponentProxy;
import org.jmodelica.ide.graphical.proxy.cache.GraphicalCacheRegistry;

public class Editor extends GraphicalEditor implements IASTChangeListener,
		IPartListener2, Observer {

	public static final String DIAGRAM_READ_ONLY = "diagramIsReadOnly";

	private GraphicalEditorInput input;
	private ClassDiagramProxy dp;
	private Stack<ComponentDiagramProxy> openComponentStack;
	private Composite breadcrumbsBar;
	private boolean ASTDirty;
	private GraphicalCacheRegistry cacheRegistry = new GraphicalCacheRegistry();

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
		String className = dp.getClassName();
		Map<String, ComponentDiagramProxy> components = new LinkedHashMap<String, ComponentDiagramProxy>();
		for (ComponentDiagramProxy component : openComponentStack) {
			components.put(component.getComponentName(), component);
		}

		Control[] cs = breadcrumbsBar.getChildren();
		for (Control c : cs) {
			c.dispose();
		}
		if (!components.isEmpty()) {
			((RowLayout) breadcrumbsBar.getLayout()).marginBottom = 3;
			((RowLayout) breadcrumbsBar.getLayout()).marginTop = 3;
			breadcrumbsBar.setVisible(true);

			Link rootLabel = new Link(breadcrumbsBar, SWT.NONE);
			rootLabel.setText("<a>" + className + "</a>");
			rootLabel.addListener(SWT.Selection, new Listener() {

				@Override
				public void handleEvent(Event event) {
					openRootComponent();
				}
			});

			Iterator<Entry<String, ComponentDiagramProxy>> it = components
					.entrySet().iterator();
			while (it.hasNext()) {
				final Entry<String, ComponentDiagramProxy> entry = it.next();
				Label arrow = new Label(breadcrumbsBar, SWT.NONE);
				arrow.setText(".");
				if (it.hasNext()) {
					Link componentLabel = new Link(breadcrumbsBar, SWT.NONE);
					componentLabel.setText("<a>" + entry.getKey() + "</a>");
					componentLabel.addListener(SWT.Selection, new Listener() {
						@Override
						public void handleEvent(Event event) {
							openPrevComponent(entry.getValue());
						}
					});
				} else {
					Label componentLabel = new Label(breadcrumbsBar, SWT.NONE);
					componentLabel.setText(entry.getKey());
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
		viewer.addDropTargetListener(new TextTransferDropTargetListener(viewer,
				TextTransfer.getInstance()));

		viewer.setProperty(SnapToGrid.PROPERTY_GRID_VISIBLE, true);
		viewer.setProperty(SnapToGrid.PROPERTY_GRID_ENABLED, true);

		getActionRegistry().registerAction(
				new ShowGridAction(getGraphicalViewer()));
		getActionRegistry().registerAction(
				new SnapToGridAction(getGraphicalViewer()));
		getActionRegistry().registerAction(
				new ToggleSnapToGeometryAction(getGraphicalViewer()));
		ContextMenuProvider contextMenu = new EditorContexMenuProvider(viewer,
				getActionRegistry());
		viewer.setContextMenu(contextMenu);
		getSite().getWorkbenchWindow().getPartService().addPartListener(this);
	}

	@Override
	protected void initializeGraphicalViewer() {
		dp = cacheRegistry.getClassDiagramProxy();
		dp.addObserver(this);
		openComponentStack = new Stack<ComponentDiagramProxy>();
		setContent();
		getGraphicalViewer().getRootEditPart().refresh();
	}

	@Override
	public void commandStackChanged(EventObject event) {
		firePropertyChange(IEditorPart.PROP_DIRTY);
		super.commandStackChanged(event);
	}

	private void setContent() {
		//System.out.println("GRAPH->setContent()");
		if (input.editIcon()) {
			getGraphicalViewer().setContents(dp);
		} else {
			refreshBreadcrumbsBar();

			AbstractDiagramProxy adp;
			if (openComponentStack.isEmpty()) {
				adp = dp;
			} else
				adp = openComponentStack.peek();
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
		Assert.isLegal(input instanceof GraphicalEditorInput,
				"The editor only support opening Modelica classes.");
		this.input = (GraphicalEditorInput) input;
		cacheRegistry.addGraphEditorListener(this);
		cacheRegistry.setInput(this.input);
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
	 * @param componentProxy
	 *            Component that we are trying to open
	 * @return If the component was found and displayed
	 */
	public boolean openSubComponent(ComponentProxy component) {
		AbstractNodeProxy node;
		if (openComponentStack.isEmpty())
			node = dp;
		else
			node = openComponentStack.peek();

		if (component.isParent(node)) {
			openComponentStack.push(new ComponentDiagramProxy(component));
			setContent();
			return true;
		}
		System.err.println("No definition found!");
		return false;
	}

	/**
	 * Shows the diagram of a component currently on the open component stack.
	 * 
	 * @param component
	 *            Component that we are trying to open
	 * @return If the component was found and displayed
	 */
	public boolean openPrevComponent(ComponentDiagramProxy component) {
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

	@SuppressWarnings("unchecked")
	public void flushInst() {
		long start = System.currentTimeMillis();
		List<Object> selectedModels = new ArrayList<Object>();
		for (EditPart o : (List<EditPart>) getGraphicalViewer()
				.getSelectedEditParts()) {
			selectedModels.add(o.getModel());
		}
		//System.out.println("copy selection, t+"
		//		+ (System.currentTimeMillis() - start));
		dp.setInstClassDeclCached(cacheRegistry.getCache());
		//System.out.println("flush, t+" + (System.currentTimeMillis() - start));
		setContent();
		//System.out.println("set content, t+"
		//		+ (System.currentTimeMillis() - start));
		for (Object selectedModel : selectedModels) {
			EditPart part = (EditPart) getGraphicalViewer()
					.getEditPartRegistry().get(selectedModel);
			if (part != null)
				getGraphicalViewer().getSelectionManager()
						.appendSelection(part);
		}
		System.out.println("Graphical editor flush took: "
				+ (System.currentTimeMillis() - start)+"ms");
	}

	public void refreshInst() {
		new Job("Refresh Diagram") {

			@Override
			protected IStatus run(IProgressMonitor monitor) {
				// InstClassDecl icd = getProgramRoot()
				// .syncSimpleLookupInstClassDecl(input.getClassName());
				/*
				 * if (dp.equals(icd)) { // TODO wont notice changes from event
				 * via // compare??? System.out.println("NODIFF!!!!!!!!!!");
				 * return Status.OK_STATUS; } if (getCommandStack().isDirty()) {
				 * ASTDirty = true; if
				 * (getSite().getWorkbenchWindow().getActivePage()
				 * .getActiveEditor() == Editor.this) showSourceChangeDialog();
				 * return Status.OK_STATUS; } dp.setInstClassDecl(icd);
				 */
				new UIJob("Refresh Diagram") {

					@Override
					public IStatus runInUIThread(IProgressMonitor monitor) {
						System.out.println("Refresh diagram job");
						getCommandStack().markSaveLocation();
						ASTDirty = false;
						setContent();
						return Status.OK_STATUS;
					}
				}.schedule();
				return Status.OK_STATUS;
			}
		}.schedule();
	}

	private void showSourceChangeDialog() {
		new UIJob("Refresh Diagram") {

			@Override
			public IStatus runInUIThread(IProgressMonitor monitor) {
				if (!ASTDirty)
					return Status.OK_STATUS;
				boolean choise = MessageDialog
						.openQuestion(
								PlatformUI.getWorkbench().getDisplay()
										.getActiveShell(),
								"Source file has changed",
								"The source file has changed and you have unsaved changes!\nDo you want to reload and discard your changes?");
				if (!choise)
					return Status.OK_STATUS;
				getCommandStack().flush();
				refreshInst();
				return Status.OK_STATUS;
			}
		}.schedule();
	}

	@Override
	public void partActivated(IWorkbenchPartReference partRef) {
		if (partRef.getPart(false) != this)
			return;
		showSourceChangeDialog();
	}

	@Override
	public void partBroughtToTop(IWorkbenchPartReference partRef) {
	}

	@Override
	public void partClosed(IWorkbenchPartReference partRef) {
	}

	@Override
	public void partDeactivated(IWorkbenchPartReference partRef) {
	}

	@Override
	public void partOpened(IWorkbenchPartReference partRef) {
	}

	@Override
	public void partHidden(IWorkbenchPartReference partRef) {
	}

	@Override
	public void partVisible(IWorkbenchPartReference partRef) {
	}

	@Override
	public void partInputChanged(IWorkbenchPartReference partRef) {
	}

	@Override
	public void update(Observable o, Object flag, Object additionalInfo) {
		if (o == dp && flag == ClassDiagramProxy.FLUSH_CONTENTS)
			flushInst();
	}

	@Override
	public void astChanged(IASTChangeEvent e) {
		Control c = this.getGraphicalViewer().getControl();
		if (c == null) {
			System.err.print("Graphical control == null\n");
		} else if (c.isDisposed()) {
			System.err.print("Graphical control is disposed\n");
		} else {
			flushInst();
		}
	}
}