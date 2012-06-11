package org.jmodelica.ide.documentation.commands;

import org.eclipse.core.commands.AbstractHandler;
import org.eclipse.core.commands.ExecutionEvent;
import org.eclipse.core.commands.ExecutionException;
import org.eclipse.core.commands.IHandler;
import org.eclipse.ui.IEditorPart;
import org.eclipse.ui.handlers.HandlerUtil;
import org.eclipse.ui.services.ISourceProviderService;
import org.jmodelica.ide.documentation.MyEditor;

public class ForwardHandler extends AbstractHandler implements IHandler  {
	
	@Override
	public Object execute(ExecutionEvent event) throws ExecutionException {
		IEditorPart e = HandlerUtil.getActiveEditor(event);
		boolean isEnabled = false;
		if (e instanceof MyEditor){
			isEnabled = ((MyEditor)e).forward();
		}
		
		// Get the source provider service
		ISourceProviderService sourceProviderService = (ISourceProviderService) HandlerUtil.getActiveWorkbenchWindow(event).getService(ISourceProviderService.class);
		// Now get my service
		NavigationProvider navProv = (NavigationProvider) sourceProviderService.getSourceProvider(NavigationProvider.NAVIGATION_FORWARD);
		navProv.setForwardEnabled(isEnabled);
		//forwardEnabled.toogleEnabled();
		return null;
	}
	
//	@Override
//	public boolean isEnabled(){
//		return isEnabled;
//	}
}
