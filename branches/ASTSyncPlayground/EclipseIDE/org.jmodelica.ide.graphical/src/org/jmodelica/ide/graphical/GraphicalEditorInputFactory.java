package org.jmodelica.ide.graphical;

import org.eclipse.core.resources.IProject;
import org.eclipse.core.resources.ResourcesPlugin;
import org.eclipse.core.runtime.IAdaptable;
import org.eclipse.ui.IElementFactory;
import org.eclipse.ui.IMemento;

public class GraphicalEditorInputFactory implements IElementFactory {

	/**
	 * Factory id. The workbench plug-in registers a factory by this name
	 * with the "org.eclipse.ui.elementFactories" extension point.
	 */
	public static final String ID_FACTORY = "org.jmodelica.ide.graphical.GraphicalEditorInputFactory";

	private static final String TAG_PROJECT = "project";
	private static final String TAG_NAME = "name";
	private static final String TAG_EDIT_ICON = "editIcon";

	@Override
	public IAdaptable createElement(IMemento memento) {
		String project = memento.getString(TAG_PROJECT);
		String name = memento.getString(TAG_NAME);
		Boolean editIcon = memento.getBoolean(TAG_EDIT_ICON);
		if (project == null || name == null || editIcon == null) {
			return null;
		}
		IProject iProject = ResourcesPlugin.getWorkspace().getRoot().getProject(project);
		if (iProject != null) {
			return new GraphicalEditorInput(name, iProject, editIcon);
		}
		return null;
	}

	public static void save(IMemento memento, GraphicalEditorInput input) {
		memento.putString(TAG_PROJECT, input.getProject().getFullPath().toString());
		memento.putString(TAG_NAME, input.getClassName());
		memento.putBoolean(TAG_EDIT_ICON, input.editIcon());
	}

}
