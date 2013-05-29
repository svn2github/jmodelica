package org.jmodelica.ide.sync;

import org.eclipse.core.resources.IFile;
import org.eclipse.core.resources.IResource;
import org.eclipse.core.resources.IResourceChangeEvent;
import org.eclipse.core.resources.IResourceChangeListener;
import org.eclipse.core.resources.IResourceDelta;
import org.eclipse.core.resources.IResourceDeltaVisitor;
import org.eclipse.core.resources.IWorkspace;
import org.eclipse.core.resources.ResourcesPlugin;
import org.eclipse.core.runtime.CoreException;
import org.eclipse.core.runtime.IStatus;
import org.eclipse.core.runtime.Status;
import org.jastadd.ed.core.Activator;
import org.jastadd.ed.core.ICompiler;

public class WorkspaceListener {
	IResourceChangeListener listener;
	ICompiler fCompiler;

	public WorkspaceListener() {
		fCompiler = ModelicaASTRegistry.getInstance().createCompiler();
		IWorkspace workspace = ResourcesPlugin.getWorkspace();
		listener = new IResourceChangeListener() {
			public void resourceChanged(IResourceChangeEvent event) {
				DeltaVisitor deltaVisitor = new DeltaVisitor();
				try {
					event.getDelta().accept(deltaVisitor);
				} catch (CoreException e) {
					String message = "WorkspaceListener failed!";
					IStatus status = new Status(IStatus.ERROR,
							Activator.PLUGIN_ID, IStatus.ERROR, message, e);
					Activator.getDefault().getLog().log(status);
				}
			}
		};
		workspace.addResourceChangeListener(listener);
	}

	class DeltaVisitor implements IResourceDeltaVisitor {
		public boolean visit(IResourceDelta delta) throws CoreException {
			IResource resource = delta.getResource();
			switch (delta.getKind()) {
			case IResourceDelta.CHANGED:
				if (resource instanceof IFile) {
					if (UniqueIDGenerator.getInstance().needWeRecompile())
						ModelicaASTRegistry.getInstance().compileFile(
								(IFile) resource);
					else
						return false;
				}
				break;
			}
			return true;
		}

	}

	public void dispose() {
		ResourcesPlugin.getWorkspace().removeResourceChangeListener(listener);
	}
}