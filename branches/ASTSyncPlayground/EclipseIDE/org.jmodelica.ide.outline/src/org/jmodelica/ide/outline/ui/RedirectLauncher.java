package org.jmodelica.ide.outline.ui;

import java.awt.Desktop;
import java.io.IOException;

import org.eclipse.core.runtime.IPath;
import org.eclipse.ui.IEditorLauncher;
import org.eclipse.ui.IEditorRegistry;
import org.eclipse.ui.PlatformUI;

public class RedirectLauncher implements IEditorLauncher {

	public void open(IPath file) {
		try {
			IEditorRegistry er = PlatformUI.getWorkbench().getEditorRegistry();
			if (er.isSystemExternalEditorAvailable(file.toOSString()))
				Desktop.getDesktop().open(file.toFile());
		} catch (IOException e) {
		}
	}
}