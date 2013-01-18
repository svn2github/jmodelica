package org.jastadd.ed.core.service.errors;

import java.util.Collection;

import org.eclipse.core.resources.IMarker;
import org.eclipse.core.resources.IResource;
import org.eclipse.core.runtime.CoreException;
import org.eclipse.core.runtime.IStatus;
import org.eclipse.core.runtime.Status;
import org.jastadd.ed.core.Activator;

public class ErrorMarker {

	public static void addAll(IResource resource, Collection<IError> errors, String markerID) {
		for (IError e : errors) {
			add(resource, e, markerID);
		}
	}
	
	public static void add(IResource resource, IError error, String markerID) {
		if (!resource.exists())
			return;
		try {
			String message 	= error.getMessage();
			
			int startOffset		= error.getStartOffset();
			int endOffset		= error.getEndOffset();
			int startLine		= error.getStartLine();
			if (startLine < 0) 
				startLine = 1;
			
			IMarker marker = resource.createMarker(markerID);
			marker.setAttribute(IMarker.MESSAGE, message);	
			
			marker.setAttribute(IMarker.LINE_NUMBER, startLine);			
			if (startOffset >= 0 && endOffset > 0 && endOffset > startOffset) {
				marker.setAttribute(IMarker.CHAR_START, startOffset);
				marker.setAttribute(IMarker.CHAR_END, endOffset);
			}
			
			IError.Severity severity = error.getSeverity();
			if (severity == IError.Severity.ERROR)
				marker.setAttribute(IMarker.SEVERITY, IError.Severity.ERROR.value);
			else if (severity == IError.Severity.WARNING)
				marker.setAttribute(IMarker.SEVERITY, IError.Severity.WARNING.value);
			else if (severity == IError.Severity.INFO)
				marker.setAttribute(IMarker.SEVERITY, IError.Severity.INFO.value);
			
		} catch (CoreException e) {
			String message = "Problem putting marker on resource: " + resource.getFullPath().toOSString() + " : " + e.getMessage(); 
			IStatus status = new Status(IStatus.ERROR, 
					Activator.PLUGIN_ID, IStatus.ERROR, message, e);
			Activator.getDefault().getLog().log(status);
		}
	}
	
	public static void removeAll(IResource resource, String markerID) {
		if (!resource.exists())
			return;
		try {
			resource.deleteMarkers(markerID, false, IResource.DEPTH_ZERO);
		} catch (CoreException e) {
			String message = "Problem removing marker from resource: " + resource.getFullPath().toOSString() + " : " + e.getMessage();
			IStatus status = new Status(IStatus.ERROR, 
					Activator.PLUGIN_ID, IStatus.ERROR, message, e);
			Activator.getDefault().getLog().log(status);
		}	
	}
		
}
