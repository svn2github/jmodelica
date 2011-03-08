package org.jmodelica.ide.folding;

import org.eclipse.jface.text.BadLocationException;
import org.eclipse.jface.text.IDocument;
import org.eclipse.jface.text.IRegion;
import org.eclipse.jface.text.Position;
import org.eclipse.jface.text.Region;
import org.eclipse.jface.text.source.projection.IProjectionPosition;

// Separate class for folds that are not limited to whole lines, 
// to be different from FilePosition once there is support for such
public class FileCharacterPosition extends Position implements IFilePosition {
	
	private String fileName;

	public FileCharacterPosition(int offset, int length, String fileName) {
		super(offset, length);
		this.fileName = fileName;
	}

	public String getFileName() {
		return fileName;
	}

}
