package org.jmodelica.ide.editor;

import java.io.IOException;
import java.io.InputStream;

import org.eclipse.core.runtime.CoreException;
import org.eclipse.jface.text.Document;
import org.eclipse.jface.text.IDocument;
import org.eclipse.ui.IEditorInput;
import org.eclipse.ui.IURIEditorInput;
import org.eclipse.ui.editors.text.FileDocumentProvider;

public class ASTDocumentProvider extends FileDocumentProvider {
	@Override
	protected IDocument createEmptyDocument() {
		return new ASTDocument();
	}
	
	protected IDocument createTextFileDocument() {
		return new Document(); 
	}
	
//	@Override
//	public boolean isModifiable(Object element) {
//		boolean modifiable = super.isModifiable(element);
//		return (modifiable ? true : (element instanceof IURIEditorInput));
//	}

	@Override
	protected IDocument createDocument(Object element) throws CoreException {
		if (element instanceof IEditorInput) {
			IDocument document = createEmptyDocument();

			if (setDocumentContent(document, (IEditorInput) element, getEncoding(element))) {
				setupDocument(element, document);

				return document;
			} else if (element instanceof IURIEditorInput) {
				document = createTextFileDocument();
				IURIEditorInput uriEditorInput = (IURIEditorInput) element;
				InputStream inputStream = null;
				try {
					inputStream = uriEditorInput.getURI().toURL().openStream();
					setDocumentContent(document, inputStream, getEncoding(element));
					setupDocument(element, document);
					return document;
				} catch (IOException ioException) {
					System.err.println("Unable to read file.");
				} finally {
					try {
						if (inputStream != null) {
							inputStream.close();
						}
					} catch (IOException ioException) {
						System.err.println("Unable to close file.");
					}
				}
			}
		}

		return null;
	}
}
