package org.jastadd.ed.core;

import java.util.Collection;
import java.util.Map;

import org.eclipse.core.resources.IFile;
import org.eclipse.core.resources.IProject;
import org.eclipse.core.resources.IResource;
import org.eclipse.core.resources.IResourceDelta;
import org.eclipse.core.resources.IResourceDeltaVisitor;
import org.eclipse.core.resources.IResourceVisitor;
import org.eclipse.core.resources.IncrementalProjectBuilder;
import org.eclipse.core.runtime.CoreException;
import org.eclipse.core.runtime.IProgressMonitor;
import org.eclipse.core.runtime.IStatus;
import org.eclipse.core.runtime.Status;
import org.jastadd.ed.core.model.IGlobalRootRegistry;
import org.jastadd.ed.core.model.node.IGlobalRootNode;
import org.jastadd.ed.core.model.node.ILocalRootNode;
import org.jastadd.ed.core.service.errors.ErrorMarker;
import org.jastadd.ed.core.service.errors.IError;
import org.jastadd.ed.core.service.errors.IErrorFeedbackNode;

public abstract class Builder extends IncrementalProjectBuilder {

	private final IGlobalRootRegistry fRegistry;
	private final ICompiler fCompiler;

	public Builder() {
		super();
		fRegistry = createRegistry();
		fCompiler = createCompiler();
	}

	protected abstract IGlobalRootRegistry createRegistry();

	protected abstract ICompiler createCompiler();

	@Override
	protected IProject[] build(int kind, Map args, IProgressMonitor monitor)
	throws CoreException {
		switch (kind) {
		case IncrementalProjectBuilder.AUTO_BUILD :
			autoBuild(args, monitor);
			break;
		case IncrementalProjectBuilder.CLEAN_BUILD :
			cleanBuild(args, monitor);
			break;
		case IncrementalProjectBuilder.FULL_BUILD :
			fullBuild(args, monitor);
			break;
		case IncrementalProjectBuilder.INCREMENTAL_BUILD :
			incrementalBuild(args, monitor);
			break;
		}
		monitor.done();
		return null;
	}

	private void incrementalBuild(Map args, IProgressMonitor monitor) {
		IResourceDelta delta = getDelta(getProject());
		if (delta == null) {
			// No delta available, do a full build
			fullBuild(args, monitor);
		} else {
			DeltaVisitor deltaVisitor = new DeltaVisitor();
			try {
				delta.accept(deltaVisitor);
			} catch (CoreException e) {
				String message = "Incremental build failed!"; 
				IStatus status = new Status(IStatus.ERROR, 
						Activator.PLUGIN_ID,
						IStatus.ERROR, message, e);
				Activator.getDefault().getLog().log(status);
			}
		}
	}

	private void fullBuild(Map args, IProgressMonitor monitor) {
		ResourceVisitor visitor = new ResourceVisitor();
		try {
			getProject().accept(visitor);
		} catch (CoreException e) {
			String message = "Full build failed!"; 
			IStatus status = new Status(IStatus.ERROR, 
					Activator.PLUGIN_ID,
					IStatus.ERROR, message, e);
			Activator.getDefault().getLog().log(status);
		}
	}

	private void cleanBuild(Map args, IProgressMonitor monitor) {
		fRegistry.doDiscard(getProject());
	}

	private void autoBuild(Map args, IProgressMonitor monitor) {
		incrementalBuild(args, monitor);
	}


	class DeltaVisitor implements IResourceDeltaVisitor {
		public boolean visit(IResourceDelta delta) throws CoreException {
			IResource resource = delta.getResource();
			switch (delta.getKind()) {
			// handle changed resource
			case IResourceDelta.CHANGED:
				if (resource instanceof IFile) {
					IFile file = (IFile)resource;
					if (fCompiler.canCompile(file)) {
						ILocalRootNode fileNode = fCompiler.compile(file);
						fRegistry.doUpdate(file, fileNode);
					}
					return false;
				}
				break;
				// handle added resource
			case IResourceDelta.ADDED:
				if (resource instanceof IFile) {
					IFile file = (IFile)resource;
					if (fCompiler.canCompile(file)) {
						ILocalRootNode fileNode = fCompiler.compile(file);
						fRegistry.doUpdate(file, fileNode);
					}
					return false;
				}
				else if (resource instanceof IProject) {
					IProject project = (IProject) resource;
					if (fCompiler.canCompile(project)) {
						IGlobalRootNode projectNode = fCompiler.compile(project);
						fRegistry.doUpdate(project, projectNode);
					}
					return false;
				}
				break;
				// handle removed resource
			case IResourceDelta.REMOVED: 
				if (resource instanceof IProject) {
					fRegistry.doDiscard((IProject)resource);
					return false;
				} else if (resource instanceof IFile) {
					fRegistry.doDiscard((IFile)resource);
					return false;
				}
				break;
			}
			return true; 			// return true to continue visiting children.
		}
	}

	public class ResourceVisitor implements IResourceVisitor {
		public boolean visit(IResource resource) {
			if (resource instanceof IProject) {
				IProject project = (IProject)resource;
				if (fCompiler.canCompile(project)) {
					IGlobalRootNode projectNode = fCompiler.compile(project);
					fRegistry.doUpdate(project, projectNode);
					updateErrors(project, projectNode);
				}
				return false;
			}
			/*
			else if (resource instanceof IFile) {
				IFile file = (IFile)resource;
				if (fCompiler.canCompile(file)) {
					ILocalRootNode fileNode = fCompiler.compile(file);
					fRegistry.doUpdate(file, fileNode);
					updateErrors(file, fileNode);
				}
			}
			 */
			return true; 			// return true to continue visiting children.

		}
	}

	protected void updateErrors(IProject project, IGlobalRootNode root) {
		ILocalRootNode[] nodes = root.lookupAllFileNodes();
		for (ILocalRootNode node : nodes) {
			if (node instanceof IErrorFeedbackNode) {
				updateSyntaxErrors(node.getFile(), (IErrorFeedbackNode)node);
				updateSemanticErrors(node.getFile(), (IErrorFeedbackNode)node);
			}
		}
	}

	protected void updateSyntaxErrors(IFile file, IErrorFeedbackNode root) {
		Collection<IError> errors  = root.syntaxErrors();
		ErrorMarker.removeAll(file, IError.SYNTAX_MARKER_ID);
		ErrorMarker.addAll(file, errors, IError.SYNTAX_MARKER_ID);
	}

	protected void updateSemanticErrors(IFile file, IErrorFeedbackNode root) {
		Collection<IError> errors  = root.semanticErrors();
		ErrorMarker.removeAll(file, IError.MARKER_ID);
		ErrorMarker.addAll(file, errors, IError.MARKER_ID);
	}


}
