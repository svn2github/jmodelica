package org.jmodelica.ide.editor;

import org.eclipse.core.runtime.CoreException;
import org.eclipse.jface.text.IDocument;
import org.eclipse.ui.IEditorInput;
import org.eclipse.ui.editors.text.FileDocumentProvider;

public class ASTDocumentProvider extends FileDocumentProvider {
	@Override
	protected IDocument createEmptyDocument() {
		return new ASTDocument();
	}

	@Override
	protected IDocument createDocument(Object element) throws CoreException {
		if (element instanceof IEditorInput) {
			IDocument document = createEmptyDocument();

			if (setDocumentContent(document, (IEditorInput) element, getEncoding(element))) {
				setupDocument(element, document);

				return document;
			}
		}

		return null;
	}
}
