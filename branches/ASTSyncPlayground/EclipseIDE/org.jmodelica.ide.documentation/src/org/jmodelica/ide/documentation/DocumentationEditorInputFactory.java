package org.jmodelica.ide.documentation;

import java.util.Stack;
import org.eclipse.core.resources.IProject;
import org.eclipse.core.resources.ResourcesPlugin;
import org.eclipse.core.runtime.IAdaptable;
import org.eclipse.ui.IElementFactory;
import org.eclipse.ui.IMemento;
import org.jmodelica.ide.sync.ASTPathPart;

public class DocumentationEditorInputFactory implements IElementFactory {
	public static final String ID_FACTORY = "org.jmodelica.ide.documentation.documentationEditorInputFactory";
	private static final String TAG_PROJECT = "project";
	private static final String TAG_CLASSASTPATH = "classastpath";
	private static final String TAG_CLASSASTINDEXES = "classastindexes";
	private static final String TAG_FILEPATH = "filename";

	@Override
	public IAdaptable createElement(IMemento memento) {
		String project = memento.getString(TAG_PROJECT);
		String filePath = memento.getString(TAG_FILEPATH);
		String classASTIndexesString = memento.getString(TAG_CLASSASTINDEXES);
		String classASTPathString = memento.getString(TAG_CLASSASTPATH);
		String[] indexes = classASTIndexesString.split("#");
		String[] ids = classASTPathString.split("#");
		Stack<ASTPathPart> classASTPath = new Stack<ASTPathPart>();
		for (int i = 0; i < ids.length; i++) {
			String id = ids[i];
			int index = Integer.parseInt(indexes[i]);
			if (!id.trim().equals(""))
				classASTPath.push(new ASTPathPart(id, index));
		}
		if (project == null || filePath == null) {
			return null;
		}
		IProject iProject = ResourcesPlugin.getWorkspace().getRoot()
				.getProject(project);
		if (iProject != null) {
			return new DocumentationEditorInput(filePath, classASTPath,
					iProject);
		}
		return null;
	}

	public static void save(IMemento memento, DocumentationEditorInput input) {
		memento.putString(TAG_PROJECT, input.getProject().getFullPath()
				.toString());
		memento.putString(TAG_FILEPATH, input.getFilePath());
		Stack<ASTPathPart> classASTPath = input.getClassASTPath();
		StringBuilder ids = new StringBuilder();
		StringBuilder indexes = new StringBuilder();
		for (int i = 0; i < classASTPath.size(); i++) {
			ids.append(classASTPath.get(i).id() + "#");
			indexes.append(classASTPath.get(i).index() + "#");
		}
		memento.putString(TAG_CLASSASTINDEXES, indexes.toString());
		memento.putString(TAG_CLASSASTPATH, ids.toString());
	}
}