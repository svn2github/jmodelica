package org.jmodelica.icons;

import java.io.ByteArrayInputStream;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;

import javax.xml.bind.DatatypeConverter;

public class Bitmap extends GraphicItem {

	private Extent extent;
	private String fileName;
	private String imageSource;
	
	public Bitmap() {
		super();
		this.extent = Extent.NO_EXTENT;
		
	}
	
	public Extent getExtent() {
		return extent;
	}
	
	public void setExtent(Extent extent) {
		this.extent = extent;
	}
	
	@Override
	public Extent getBounds() {
		return extent;
	}

	public void setImageSource(String imageSource) {
		this.imageSource = imageSource;
	}

	public String getImageSource() {
		return imageSource;
	}

	/**
	 * Sets the file name of the Bitmap primitive. 
	 * @param fileName
	 * @param path
	 */
	public void setFileName(String fileName) {
		this.fileName = fileName;
	}

	public String getFileName() {
		return fileName;
	}
	
	public boolean isFromFile() {
		return fileName != null;
	}
	
	public InputStream getInputStream() throws IOException {
		if (fileName != null) {
			return new FileInputStream(fileName);
		} else if (imageSource != null) {
			byte[] bytes = DatatypeConverter.parseBase64Binary(imageSource);
			return new ByteArrayInputStream(bytes);
		}
		return null;
	}
	
	public String toString() {
		return "extent = " + extent + ", fileName = " + fileName + 
				", imageSource = " + imageSource + super.toString(); 
	}
	
}
