package org.jmodelica.ide.textual.helpers.hooks;

import org.jmodelica.ide.helpers.hooks.IErrorCheckHook;
import org.jmodelica.ide.textual.actions.ErrorCheckAction;

public class GlobalHooksHelper {
	public static void addErrorCheckHook(IErrorCheckHook hook) {
		ErrorCheckAction.addErrorCheckHook(hook);
	}
	
	public static void removeErrorCheckHook(IErrorCheckHook hook) {
		ErrorCheckAction.removeErrorCheckHook(hook);
	}}
