package org.jmodelica.icons;

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
		// File URI scheme:
		if (fileName.toLowerCase().startsWith("file:///")) {
			this.fileName = fileName.substring(7);
		
		// TODO: Modelica URI scheme:
		} else if (fileName.toLowerCase().startsWith("modelica://")) {  
			
		}
	}

	public String getFileName() {
		return fileName;
	}
	
	public String toString() {
		return "extent = " + extent + ", fileName = " + fileName + 
				", imageSource = " + imageSource + super.toString(); 
	}
	
}
