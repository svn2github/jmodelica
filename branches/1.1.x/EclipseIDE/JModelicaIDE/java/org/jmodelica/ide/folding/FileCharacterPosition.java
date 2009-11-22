package org.jmodelica.ide.folding;

import org.jmodelica.folding.CharacterPosition;

public class FileCharacterPosition extends CharacterPosition implements
		IFilePosition {
	
	private String fileName;

	public FileCharacterPosition(int offset, int length, String fileName) {
		super(offset, length);
		this.fileName = fileName;
	}

	public String getFileName() {
		return fileName;
	}

}
