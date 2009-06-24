package org.jmodelica.ide.editor;

import org.eclipse.jface.text.BadLocationException;
import org.eclipse.jface.text.DocumentCommand;
import org.eclipse.jface.text.IAutoEditStrategy;
import org.eclipse.jface.text.IDocument;
import static java.lang.Character.isWhitespace;

public class AnnotationParenthesisAdder implements IAutoEditStrategy {
	
	private static final String keyword = "annotation";

	public void customizeDocumentCommand(IDocument document,
			DocumentCommand command) {
		try {
			String str = command.text;
			if (str != null && str.endsWith("(")) {
				String strPart = "";
				String docPart = "";
				int len = str.length();
				if (len > 1) {
					int pos = len - 2;
					while (pos >= 0 && isWhitespace(str.charAt(pos)))
						pos--;
					int start = pos > keyword.length() ? pos - keyword.length() + 1 : 0;
					if (pos >= 0)
					strPart = str.substring(start, pos + 1);
				}
				int docPartLen = keyword.length() - strPart.length();
				if (command.offset >= docPartLen) 
					docPart = document.get(command.offset  - docPartLen , docPartLen);
				if (keyword.equals(docPart + strPart)) {
					command.text += ")";
					command.shiftsCaret = false;
					command.caretOffset = command.offset + len;
				}
			}
		} catch (BadLocationException e) {
		}
	}

}
