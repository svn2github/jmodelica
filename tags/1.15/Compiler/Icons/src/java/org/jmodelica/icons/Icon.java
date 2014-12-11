package org.jmodelica.icons;

import java.util.ArrayList;

import org.jmodelica.icons.coord.CoordinateSystem;
import org.jmodelica.icons.coord.Extent;
import org.jmodelica.icons.coord.Point;
import org.jmodelica.icons.drawing.GraphicsInterface;
import org.jmodelica.icons.drawing.IconConstants.Context;
import org.jmodelica.icons.primitives.Bitmap;
import org.jmodelica.icons.primitives.FilledShape;
import org.jmodelica.icons.primitives.GraphicItem;
import org.jmodelica.icons.primitives.Line;
import org.jmodelica.icons.primitives.Text;

public class Icon extends Observable implements Cloneable {

	public static final Object CLASS_NAME_CHANGED = new Object();
	public static final Object COMPONENT_NAME_CHANGED = new Object();
	public static final Object SUPERCLASS_ADDED = new Object();
	public static final Object SUPERCLASS_REMOVED = new Object();
	public static final Object SUBCOMPONENT_ADDED = new Object();
	public static final Object SUBCOMPONENT_REMOVED = new Object();
	public static final Object IM_REMOVED = new Object();
	public static final Object IM_ADDED = new Object();

	public static Icon NULL_ICON = new Icon();

	private String componentName;
	private String className;
	private Layer layer;
	private ArrayList<Icon> superClasses;
	private ArrayList<Component> subComponents;
	private Context context;
	private boolean isAdded = false;

	/**
	 * 
	 * @param iconLayer The component's graphical representation in the icon
	 *            layer.
	 * @param diagramLayer The component's graphical representation in the
	 *            diagram layer.
	 */
	public Icon(String className, Layer layer, Context context) {
		this.componentName = "";
		this.className = className;
		this.context = context;
		this.layer = layer;
		this.superClasses = new ArrayList<Icon>();
		this.subComponents = new ArrayList<Component>();
	}

	private Icon() {
		this("", Layer.NO_LAYER, null);
	}

	/**
	 * Makes a copy of this object, It will not be a "deep copy" nor a
	 * "shallow copy" some of the attributes might get cloned but not all.
	 */
	@Override
	public Icon clone() throws CloneNotSupportedException {
		if (this == NULL_ICON)
			return this;
		Icon copy = (Icon) super.clone();
		copy.className = new String(className);
		copy.subComponents = new ArrayList<Component>();
		for (Component component : subComponents) {
			copy.subComponents.add(component.clone());
		}
		copy.superClasses = new ArrayList<Icon>();
		for (Icon superClass : superClasses)
			copy.superClasses.add(superClass.clone());

		return copy;
	}

	public boolean isEmpty() {
		if (layer != Layer.NO_LAYER)
			return false;
		for (Icon sup : superClasses)
			if (!sup.isEmpty())
				return false;
		for (Component comp : subComponents)
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
						gi.drawLine((Line) item);
					} else if (item instanceof Bitmap) {
						gi.drawBitmap((Bitmap) item);
					} else {
						FilledShape filledShape = (FilledShape) item;
						if (item instanceof Text) {
							gi.drawText((Text) filledShape, this);
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
			if (compIcon.layer != Layer.NO_LAYER) {
				gi.saveTransformation();
				Extent extent = this.layer.getCoordinateSystem().getExtent();
				gi.setTransformation(comp, extent);
				compIcon.draw(gi);
				gi.resetTransformation();
			}
		}
	}

	public String getComponentName() {
		return componentName;
	}

	public void setComponentName(String newComponentName) {
		if (componentName != null && componentName.equals(newComponentName))
			return;
		componentName = newComponentName;
		notifyObservers(COMPONENT_NAME_CHANGED);
	}

	public String getClassName() {
		return className;
	}

	public void setClassName(String newClassName) {
		if (className != null && className.equals(newClassName))
			return;
		this.className = newClassName;
		notifyObservers(CLASS_NAME_CHANGED);
	}

	public Layer getLayer() {
		return layer;
	}

	public void addSuperclass(Icon superclass) {
		superClasses.add(superclass);
		notifyObservers(SUPERCLASS_ADDED, superclass);
	}

	public void addSubcomponent(Component component) {
		if (subComponents.contains(component))
			return;
		
		if (subComponents.isEmpty() && layer == Layer.NO_LAYER) {
				layer = new Layer(CoordinateSystem.DEFAULT_COORDINATE_SYSTEM);
		}
		subComponents.add(component);
		component.added();
		notifyObservers(SUBCOMPONENT_ADDED, component);
	}

	public void removeSubComponent(Component component) {
		if (subComponents.remove(component)) {
			component.removed();
			notifyObservers(SUBCOMPONENT_REMOVED, component);
		}
	}

	public ArrayList<Icon> getSuperclasses() {
		return superClasses;
	}

	public ArrayList<Component> getSubcomponents() {
		return subComponents;
	}

	/*
	 * Returns the extent of the icon. Returns an empty extent if the icon or
	 * the
	 * super classes or the sub components doesnt have a layer.
	 */
	public Extent getExtent() {
		if (layer != Layer.NO_LAYER) {
			return layer.getCoordinateSystem().getExtent();
		}
		for (Component comp : this.subComponents) {
			Icon compIcon = comp.getIcon();
			if (compIcon.layer != Layer.NO_LAYER) {
				return compIcon.layer.getCoordinateSystem().getExtent();
			}
		}
		for (Icon icon : superClasses) {
			Extent extent = icon.getExtent();
			if (extent != Extent.NO_EXTENT) {
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
	 * 
	 * @return
	 */
	public Extent getBounds(Extent constrain) {
		Extent union = constrain;
		if (layer != Layer.NO_LAYER) {
			ArrayList<GraphicItem> items = layer.getGraphics();
			for (GraphicItem item : items) {
				if (!(item instanceof Text)) {
					Extent itemBounds = item.getBounds();
					if (itemBounds != null) {
						union = Extent.union(union, itemBounds);
					}
				}
			}
		}
		for (Component component : subComponents) {
			Extent p = component.getPlacement().getTransformation().getExtent();
			Point o = component.getPlacement().getTransformation().getOrigin();
			Point p1 = new Point(p.getP1().getX() + o.getX(), p.getP1().getY() + o.getY());
			Point p2 = new Point(p.getP2().getX() + o.getX(), p.getP2().getY() + o.getY());
			p = new Extent(p1, p2);
			union = Extent.union(union, p);
		}
		for (Icon icon : superClasses) {
			union = icon.getBounds(constrain);
		}
		return constrain.constrain(union);
	}

	public String toString() {
		String s = "";
		s += "\nclassName = " + className;
		//s += "\ncomponentName = " + componentName;
//		s += "\niconLayer: " + iconLayer.toString();
//		s += "\ndiagramLayer: " + diagramLayer.toString();
		//s += "\nplacement: " + placement.toString();
		for (int i = 0; i < subComponents.size(); i++) {
			s += "\nSubcomponent " + (i + 1) + ":" + "\n" + subComponents.get(i);
		}
		for (int i = 0; i < superClasses.size(); i++) {
			s += "\nSuperclass " + (i + 1) + ":" + "\n" + superClasses.get(i);
		}
		return s;
	}

	public Context getContext() {
		return context;
	}

	public void added() {
		if (isAdded)
			return;
		isAdded = true;
		for (Component subComponent : subComponents)
			subComponent.added();
		for (Icon superClass : superClasses)
			superClass.added();
		notifyObservers(IM_ADDED);
	}

	public void removed() {
		if (!isAdded)
			return;
		isAdded = false;
		for (Component subComponent : subComponents)
			subComponent.removed();
		for (Icon superClass : superClasses)
			superClass.removed();
		notifyObservers(IM_REMOVED);
	}

	public boolean isAdded() {
		return isAdded;
	}
}