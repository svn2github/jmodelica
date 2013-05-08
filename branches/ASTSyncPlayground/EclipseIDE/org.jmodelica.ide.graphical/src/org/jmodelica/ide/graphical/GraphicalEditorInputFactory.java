package org.jmodelica.ide.graphical;

import org.eclipse.core.runtime.IAdaptable;
import org.eclipse.ui.IElementFactory;
import org.eclipse.ui.IMemento;

public class GraphicalEditorInputFactory implements IElementFactory {

	/**
	 * Factory id. The workbench plug-in registers a factory by this name with
	 * the "org.eclipse.ui.elementFactories" extension point.
	 */
	public static final String ID_FACTORY = "org.jmodelica.ide.graphical.GraphicalEditorInputFactory";

	private static final String TAG_FILEPATH = "filePath";
	private static final String TAG_CLASSNAME = "className";
	private static final String TAG_EDIT_ICON = "editIcon";

	@Override
	public IAdaptable createElement(IMemento memento) {
		String filePath = memento.getString(TAG_FILEPATH);
		String className = memento.getString(TAG_CLASSNAME);
		Boolean editIcon = memento.getBoolean(TAG_EDIT_ICON);
		if (filePath == null || className == null || editIcon == null) {
			return null;
		}
		return new GraphicalEditorInput(className, filePath, editIcon);
	}

	public static void save(IMemento memento, GraphicalEditorInput input) {
		memento.putString(TAG_FILEPATH, input.getFilePath());
		memento.putString(TAG_CLASSNAME, input.getClassName());
		memento.putBoolean(TAG_EDIT_ICON, input.editIcon());
	}
}