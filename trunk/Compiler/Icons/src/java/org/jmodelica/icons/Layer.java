package org.jmodelica.icons;
import java.util.ArrayList;

import org.jmodelica.icons.coord.CoordinateSystem;
import org.jmodelica.icons.primitives.GraphicItem;



public class Layer extends Observable implements Observer {
	
	public static final Object COORDINATE_SYSTEM_UPDATED = new Object();
	public static final Object GRAPHICS_SWAPPED = new Object();
	
	private CoordinateSystem coordinateSystem;
	private ArrayList<GraphicItem> graphics;
	
	public static Layer NO_LAYER = new Layer();
		
	/**
	 * 
	 * @param graphics The list of graphic items that make up the components's 
	 * graphical representation in the layer.
	 */
	public Layer(CoordinateSystem coordinateSystem, ArrayList<GraphicItem> graphics) {
		this.coordinateSystem = coordinateSystem;
		setGraphics(graphics);
	}
	
	public Layer(CoordinateSystem coordinateSystem) {
		this(coordinateSystem, new ArrayList<GraphicItem>());
	}
	
	private Layer() {
		this(CoordinateSystem.DEFAULT_COORDINATE_SYSTEM);
	}
	
	public CoordinateSystem getCoordinateSystem() {
		return coordinateSystem;
	}
	
	public ArrayList<GraphicItem> getGraphics() {
		return graphics;
	}
	
	public void setGraphics(ArrayList<GraphicItem> newGraphics) {
		if (graphics == newGraphics)
			return;
		graphics = newGraphics;
		notifyObservers(GRAPHICS_SWAPPED);
	}
	
	public String toString() {
		String s = "coordinateSystem = " + coordinateSystem + "\ngraphics: " + graphics;
		return s;
	}

	@Override
	public void update(Observable o, Object flag, Object additionalInfo) {
		if (o == coordinateSystem)
			notifyObservers(COORDINATE_SYSTEM_UPDATED);
	}
}