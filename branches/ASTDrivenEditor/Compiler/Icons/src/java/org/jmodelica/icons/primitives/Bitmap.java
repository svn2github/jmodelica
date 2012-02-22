package org.jmodelica.icons.primitives;

import java.io.ByteArrayInputStream;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;

import javax.xml.bind.DatatypeConverter;

import org.jmodelica.icons.Observable;
import org.jmodelica.icons.Observer;
import org.jmodelica.icons.coord.Extent;

public class Bitmap extends GraphicItem implements Observer {
	
	public static final Object EXTENT_UPDATED = new Object();
	public static final Object EXTENT_SWAPPED = new Object();
	public static final Object FILE_NAME_CHANGED = new Object();
	public static final Object IMAGE_SOURCE_CHANGED = new Object();

	private Extent extent;
	private String fileName;
	private String imageSource;
	
	public Bitmap() {
		super();
		setExtent(Extent.NO_EXTENT);
	}
	
	public Extent getExtent() {
		return extent;
	}
	
	public void setExtent(Extent newExtent) {
		if (extent == newExtent)
			return;
		if (extent != null)
			extent.removeObserver(this);
		extent = newExtent;
		if (newExtent != null)
			newExtent.addObserver(this);
		notifyObservers(EXTENT_SWAPPED);
	}
	
	@Override
	public Extent getBounds() {
		return extent;
	}

	public void setImageSource(String newImageSource) {
		if (imageSource != null && imageSource.equals(newImageSource))
			return;
		imageSource = newImageSource;
		notifyObservers(IMAGE_SOURCE_CHANGED);
	}

	public String getImageSource() {
		return imageSource;
	}

	/**
	 * Sets the file name of the Bitmap primitive. 
	 * @param newFileName
	 * @param path
	 */
	public void setFileName(String newFileName) {
		if (fileName != null && fileName.equals(newFileName))
			return;
		fileName = newFileName;
		notifyObservers(FILE_NAME_CHANGED);
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
	
	@Override
	public void update(Observable o, Object flag, Object additionalInfo) {
		if (o == extent && (flag == Extent.P1_SWAPPED || flag == Extent.P1_UPDATED || flag == Extent.P2_SWAPPED || flag == Extent.P2_UPDATED))
			notifyObservers(EXTENT_UPDATED);
		else
			super.update(o, flag, additionalInfo);
	}

}
