package org.jmodelica.icons;

public class Placement {
	
	private boolean visible;
	private Transformation transformation;
	
	private static final boolean DEFAULT_VISIBLE = true;

	/**
	 * @param transformation Placement in the diagram layer.
	 */
	public Placement(boolean visible, Transformation transformation) {
		this.visible = visible;
		this.transformation = transformation;
	}

	/**
	 * @param transformation Placement in the diagram layer.
	 */
	public Placement(Transformation transformation) {
		this(DEFAULT_VISIBLE, transformation);
	}
	
	public boolean isVisible() {
		return visible;
	}
	
	public void setVisible(boolean visible) {
		this.visible = visible;
	}
	
	public Transformation getTransformation() {
		return transformation;
	}
	
	public void setIconTransformation(Transformation transformation) {
		this.transformation = transformation;
	}
	
	public String toString() {
		String s = "";
		s += "visible = " + visible;
		s += "\ntransformation = " + transformation;
		return s;
	}
}