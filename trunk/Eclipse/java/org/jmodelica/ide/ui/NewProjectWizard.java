package org.jmodelica.ide.ui;

import java.lang.reflect.InvocationTargetException;
import java.net.URI;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;

import org.eclipse.core.commands.ExecutionException;
import org.eclipse.core.resources.ICommand;
import org.eclipse.core.resources.IProject;
import org.eclipse.core.resources.IProjectDescription;
import org.eclipse.core.resources.IResource;
import org.eclipse.core.resources.IWorkspace;
import org.eclipse.core.resources.ResourcesPlugin;
import org.eclipse.core.runtime.CoreException;
import org.eclipse.core.runtime.IConfigurationElement;
import org.eclipse.core.runtime.IExecutableExtension;
import org.eclipse.core.runtime.IProgressMonitor;
import org.eclipse.jface.operation.IRunnableWithProgress;
import org.eclipse.jface.viewers.ISelection;
import org.eclipse.jface.viewers.IStructuredSelection;
import org.eclipse.jface.viewers.StructuredSelection;
import org.eclipse.jface.wizard.Wizard;
import org.eclipse.ui.INewWizard;
import org.eclipse.ui.IWorkbench;
import org.eclipse.ui.IWorkbenchPage;
import org.eclipse.ui.IWorkbenchPart;
import org.eclipse.ui.IWorkbenchPartReference;
import org.eclipse.ui.IWorkbenchWindow;
import org.eclipse.ui.IWorkingSet;
import org.eclipse.ui.PlatformUI;
import org.eclipse.ui.dialogs.WizardNewProjectCreationPage;
import org.eclipse.ui.ide.undo.CreateProjectOperation;
import org.eclipse.ui.ide.undo.WorkspaceUndoUtil;
import org.eclipse.ui.part.ISetSelectionTarget;

import org.jastadd.plugin.Builder;
import org.jmodelica.ide.Nature;

public class NewProjectWizard extends Wizard implements INewWizard, IExecutableExtension {

	private static final String window_title = "New Modelica Project";
	private static final String title = "New Modelica Project";
	private static final String description = "Creates a new Modelica Project";

    protected IWorkbench workbench;
    protected IStructuredSelection selection;
	protected WizardNewProjectCreationPage mainPage;
	
	private IProject newProject;
	
	
	@Override
	public boolean performFinish() {
		
		newProject = createNewProject();
		if (newProject == null) {
			return false;
		}
		
		IWorkingSet[] workingSets = mainPage.getSelectedWorkingSets();
		getWorkbench().getWorkingSetManager().addToWorkingSets(newProject,
				workingSets);
        
		// code to update perspective in BasicNewProjectResource
		// in org.eclipse.ui.wizards.newresource
		selectAndReveal(newProject);

		return true;
	}
	
	public void init(IWorkbench workbench, IStructuredSelection selection) {
		this.workbench = workbench;
		this.selection = selection;
	}
	
	@Override
	public void addPages() {
		super.addPages();
		mainPage = new WizardNewProjectCreationPage("basicNewProjectPage");
		mainPage.setTitle(title);
		mainPage.setDescription(description);
		this.addPage(mainPage);
	}


	protected IStructuredSelection getSelection() {
		return selection;
	}
	
	protected IWorkbench getWorkbench() {
		return workbench;
	}
		
	protected IProject createNewProject() {
		if (newProject != null)
			return newProject;
		
		// get a project handle
		final IProject newProjectHandle = mainPage.getProjectHandle();
		URI location = null;
		if (!mainPage.useDefaults()) {
			location = mainPage.getLocationURI();
		}
		IWorkspace workspace = ResourcesPlugin.getWorkspace();
		final IProjectDescription description = workspace
				.newProjectDescription(newProjectHandle.getName());
		description.setLocationURI(location);
		description.setNatureIds(new String[] { Nature.NATURE_ID });
		
		// create the new project operation
		IRunnableWithProgress op = new IRunnableWithProgress() {
			public void run(IProgressMonitor monitor)
					throws InvocationTargetException {
				CreateProjectOperation op = new CreateProjectOperation(
						description, window_title);
				try {
					PlatformUI.getWorkbench().getOperationSupport()
							.getOperationHistory().execute(
									op,
									monitor,
									WorkspaceUndoUtil
											.getUIInfoAdapter(getShell()));
				} catch (ExecutionException e) {
					throw new InvocationTargetException(e);
				}
			}
		};

		// run the new project creation operation
		try {
			getContainer().run(true, true, op);
		} catch (InterruptedException e) {
			return null;
		} catch (InvocationTargetException e) {
			// Better error handling available in BasicNewProjectWizard 
			// in org.eclipse.ui.wizards.newresource
			return null;
		}
		
		addProjectBuilder(newProjectHandle);
		
		newProject = newProjectHandle;
		return newProject;
	}
	
	protected void addProjectBuilder(IProject project) {
		try {
			IProjectDescription desc = project.getDescription();
			ICommand[] commands = desc.getBuildSpec();
			boolean found  = false;
			for(int i = 0; i < commands.length; i++) {
				if(commands[i].getBuilderName().equals(Builder.BUILDER_ID)) {
					found = true;
					break;
				}
			}
			if(!found) {
				ICommand command = desc.newCommand();
				command.setBuilderName(Builder.BUILDER_ID);
				ICommand[] newCommands = new ICommand[commands.length + 1];
				System.arraycopy(commands, 0, newCommands, 1, commands.length);
				newCommands[0] = command;
				desc.setBuildSpec(newCommands);
				project.setDescription(desc, null);
			}
		} catch(CoreException c) {
			c.printStackTrace();
		} 
	}
	
	
	
	/* 
	 * The rest of the code in this file is from BasicNewResourceWizard in 
	 * org.eclipse.ui.wizards.newresource which reveals a newly created 
	 * resource as much as possible
	 * 
	 */
	
	
	/**
     * Selects and reveals the newly added resource in all parts
     * of the active workbench window's active page.
     *
     * @see ISetSelectionTarget
     */
    protected void selectAndReveal(IResource newResource) {
        selectAndReveal(newResource, getWorkbench().getActiveWorkbenchWindow());
    }

    /**
     * Attempts to select and reveal the specified resource in all
     * parts within the supplied workbench window's active page.
     * <p>
     * Checks all parts in the active page to see if they implement <code>ISetSelectionTarget</code>,
     * either directly or as an adapter. If so, tells the part to select and reveal the
     * specified resource.
     * </p>
     *
     * @param resource the resource to be selected and revealed
     * @param window the workbench window to select and reveal the resource
     * 
     * @see ISetSelectionTarget
     */
    @SuppressWarnings("unchecked")
	public static void selectAndReveal(IResource resource,
            IWorkbenchWindow window) {
        // validate the input
        if (window == null || resource == null) {
			return;
		}
        IWorkbenchPage page = window.getActivePage();
        if (page == null) {
			return;
		}

        // get all the view and editor parts
        List parts = new ArrayList();
        IWorkbenchPartReference refs[] = page.getViewReferences();
        for (int i = 0; i < refs.length; i++) {
            IWorkbenchPart part = refs[i].getPart(false);
            if (part != null) {
				parts.add(part);
			}
        }
        refs = page.getEditorReferences();
        for (int i = 0; i < refs.length; i++) {
            if (refs[i].getPart(false) != null) {
				parts.add(refs[i].getPart(false));
			}
        }

        final ISelection selection = new StructuredSelection(resource);
        Iterator itr = parts.iterator();
        while (itr.hasNext()) {
            IWorkbenchPart part = (IWorkbenchPart) itr.next();

            // get the part's ISetSelectionTarget implementation
            ISetSelectionTarget target = null;
            if (part instanceof ISetSelectionTarget) {
				target = (ISetSelectionTarget) part;
			} else {
				target = (ISetSelectionTarget) part
                        .getAdapter(ISetSelectionTarget.class);
			}

            if (target != null) {
                // select and reveal resource
                final ISetSelectionTarget finalTarget = target;
                window.getShell().getDisplay().asyncExec(new Runnable() {
                    public void run() {
                        finalTarget.selectReveal(selection);
                    }
                });
            }
        }
    }

    protected IConfigurationElement configElement;
    
	public void setInitializationData(IConfigurationElement config,
			String propertyName, Object data) throws CoreException {
		configElement = config;
	}

}
