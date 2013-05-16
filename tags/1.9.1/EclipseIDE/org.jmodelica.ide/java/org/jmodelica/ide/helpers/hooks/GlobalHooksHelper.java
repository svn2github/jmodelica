package org.jmodelica.ide.helpers.hooks;

import org.jmodelica.ide.actions.ErrorCheckAction;

public class GlobalHooksHelper {
	
	public static void addErrorCheckHook(IErrorCheckHook hook) {
		ErrorCheckAction.addErrorCheckHook(hook);
	}
	
	public static void removeErrorCheckHook(IErrorCheckHook hook) {
		ErrorCheckAction.removeErrorCheckHook(hook);
	}
	
}
