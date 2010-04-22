package org.jmodelica.ide.folding;

import org.eclipse.jface.text.Position;

public class FilePosition extends Position implements IFilePosition {
	
	private String fileName;

	public FilePosition(int offset, int length, String fileName) {
		super(offset, length);
		this.fileName = fileName;
	}

	public String getFileName() {
		return fileName;
	}

}
