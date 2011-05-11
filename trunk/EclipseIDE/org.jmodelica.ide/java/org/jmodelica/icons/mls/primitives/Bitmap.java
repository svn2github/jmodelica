package org.jmodelica.icons.mls.primitives;

public class Bitmap extends GraphicItem {

	private Extent extent;
	private String fileName;
	private String imageSource;
	
	public Bitmap() {
		super();
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

	public void setFileName(String fileName, String path) {
		// File URI scheme:
		if (fileName.toLowerCase().startsWith("file:///")) {
			this.fileName = fileName.substring(7);
		
		// TODO: Modelica URI scheme:
		} else if (fileName.toLowerCase().startsWith("modelica://")) {  
			
		// The format used in  Modelica.Mechanics.Examples.Systems.RobotR3.fullRobot:
		} else {
			fileName = fileName.replace('/', '\\');
			while (fileName.startsWith("..\\")) {
				fileName = fileName.substring(fileName.indexOf("\\")+1);
				path = path.substring(0, path.lastIndexOf("\\"));
			}
			this.fileName = path.concat("\\".concat(fileName));
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
