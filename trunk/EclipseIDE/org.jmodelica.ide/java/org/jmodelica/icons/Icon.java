package org.jmodelica.icons;

import java.util.ArrayList;

import org.jmodelica.icons.drawing.GraphicsInterface;
import org.jmodelica.icons.drawing.IconConstants.Context;

public class Icon {

	public static Icon NULL_ICON = new Icon();
	
	private String componentName;
	private String className;
	private Layer layer;
	private final ArrayList<Icon> superclasses;
	private final ArrayList<Component> subcomponents;
	private final Context context;
	
	/**
	 * 
	 * @param iconLayer The component's graphical representation in the icon layer.
	 * @param diagramLayer The component's graphical representation in the diagram layer.
	 */
	
	public Icon(String className, Layer layer, Context context) {
		this.componentName = "";
		this.className = className;
		this.context = context;
		this.layer = layer;
		this.superclasses = new ArrayList<Icon>();
		this.subcomponents = new ArrayList<Component>();
	}
	
	
	private Icon() {
		this("", Layer.NO_LAYER, null);
	}
	
	public boolean isEmpty() {
		if (layer != Layer.NO_LAYER)
			return false;
		for (Icon sup : superclasses) 
			if (!sup.isEmpty())
				return false;
		for (Component comp : subcomponents) 
			if (!comp.getIcon().isEmpty())
				return false;
		return true;
	}

	public void draw(GraphicsInterface gi) {
		
		drawClass(gi);	
		drawComponents(gi);
	}

	private void drawClass(GraphicsInterface gi) {
    	for (Icon superIcon : getSuperclasses()) {
    		superIcon.drawClass(gi);
    	}
		if (layer != Layer.NO_LAYER) {
			ArrayList<GraphicItem> items = layer.getGraphics();
			if (items != null) {
		        for (GraphicItem item : items) {
		        	if (item instanceof Line) {
		        		gi.drawLine((Line)item);
		        	} else if (item instanceof Bitmap) {
		        		gi.drawBitmap((Bitmap)item);
		        	} else {
		        		FilledShape filledShape = (FilledShape)item;
		        		if (item instanceof Text) {
		        			gi.drawText((Text)filledShape, this);
		        		} else {
		        			gi.drawShape(filledShape);
		        		}
		        	}
		        }
			}
		}		
	}
	
	private void drawComponents(GraphicsInterface gi) {
    	for (Icon superIcon : getSuperclasses()) {
    		superIcon.drawComponents(gi);
    	}
    	for (Component comp : getSubcomponents()) {
    		Icon compIcon = comp.getIcon();
    		if(compIcon.layer != Layer.NO_LAYER) {
	    		gi.saveTransformation();
	    		Extent extent = this.layer.getCoordinateSystem().getExtent();
	    		gi.setTransformation(comp, extent);
				compIcon.drawClass(gi);
				compIcon.drawComponents(gi);
				gi.resetTransformation();
    		}
    	}	
	}
	public String getComponentName() {
		return componentName;
	}

	public void setComponentName(String componentName) {
		this.componentName = componentName;
	}
	
	public String getClassName() {
		return className;
	}

	public void setClassName(String className) {
		this.className = className;
	}

	public Layer getLayer() {
		return layer;
	}

	public void addSuperclass(Icon superclass) {
		superclasses.add(superclass);
	}

	public void addSubcomponent(Component component) {
		if(subcomponents.isEmpty() && layer == Layer.NO_LAYER) {
			if(subcomponents.add(component)) {
				layer = new Layer(CoordinateSystem.DEFAULT_COORDINATE_SYSTEM);
			} 
		} else {
			subcomponents.add(component);
		}
	}
	
	public ArrayList<Icon> getSuperclasses() {
		return superclasses;
	}

	public ArrayList<Component> getSubcomponents() {
		return subcomponents;
	}
	
	/*
	 * Returns the extent of the icon. Returns an empty extent if the icon or the 
	 * super classes or the sub components doesnt have a layer. 
	 */
	public Extent getExtent() {
		if(layer != Layer.NO_LAYER) {
			return layer.getCoordinateSystem().getExtent();
		}		
		for(Component comp : this.subcomponents) {
	    	Icon compIcon = comp.getIcon(); 
	    	if(compIcon.layer != Layer.NO_LAYER) {
				return compIcon.layer.getCoordinateSystem().getExtent();	
			}
		}
		for (Icon icon : superclasses) {
			Extent extent = icon.getExtent();
			if(extent != Extent.NO_EXTENT) {
				return extent;
			}
		}	
		return Extent.NO_EXTENT;
	}
	
	/**
	 * Returns the smallest possible extent that contains all of the icon's 
	 * graphical primitives, including the ones of its superclasses and
	 * components. The extent returned will also contain the extent provided
	 * as an argument.
	 * @return
	 */
	//anropas från det grafiska användargränssnittet
	public Extent getBounds(Extent bounds) {
		if (layer != Layer.NO_LAYER) {
			ArrayList<GraphicItem> items = layer.getGraphics();
			for (GraphicItem item : items) {
				if (!(item instanceof Text)) {
					bounds = bounds.contain(item.getBounds());
				}
			}
		}
		for (Component component : subcomponents) {
			Extent p = component.getPlacement().getTransformation().getExtent().clone();
			Point o = component.getPlacement().getTransformation().getOrigin();
			p.getP1().setX(p.getP1().getX()+o.getX());
			p.getP1().setY(p.getP1().getY()+o.getY());
			p.getP2().setX(p.getP2().getX()+o.getX());
			p.getP2().setY(p.getP2().getY()+o.getY());
			bounds = bounds.contain(p);
		}
		for (Icon icon : superclasses) {
			bounds = icon.getBounds(bounds);
		}
		return bounds;
	}
	public String toString() {
		String s = "";
		s += "\nclassName = " + className;
		//s += "\ncomponentName = " + componentName;
//		s += "\niconLayer: " + iconLayer.toString();
//		s += "\ndiagramLayer: " + diagramLayer.toString();
		//s += "\nplacement: " + placement.toString();
		for (int i = 0; i < subcomponents.size(); i++) {
			s += "\nSubcomponent " + (i+1) + ":" + "\n" + subcomponents.get(i);
		}
		for (int i = 0; i < superclasses.size(); i++) {
			s += "\nSuperclass " + (i+1) + ":" + "\n" + superclasses.get(i);
		}
		return s;
	}
	
	public Context getContext() {
		return context;
	}
	
	public static class NullIcon extends Icon {
	}
	
}