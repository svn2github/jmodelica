package org.jmodelica.icons;

import org.jmodelica.icons.coord.Placement;

public class Component extends Observable implements Observer, Cloneable {
	
	public static final Object ICON_UPDATED = new Object();
	public static final Object PLACEMENT_UPDATED = new Object();
	public static final Object COMPONENT_NAME_CHANGED = new Object();
	public static final Object IM_REMOVED = new Object();
	public static final Object IM_ADDED = new Object();

	private Icon icon;
	private Placement placement;
	private String componentName = null;
	private boolean isAdded = false;
	
	public Component(Icon icon, Placement placement) {
		this(icon, placement, null);
	}
	
	public Component(Icon icon, Placement placement, String componentName) {
		this.icon = icon;
		icon.addObserver(this);
		this.placement = placement;
		placement.addObserver(this);
		this.componentName = componentName;
	}
	
	/**
	 * Makes a copy of this object, It will not be a "deep copy" nor a "shallow copy"
	 * some of the attributes might get cloned but not all. 
	 */
	@Override
	public Component clone() throws CloneNotSupportedException {
		Component copy = (Component) super.clone();
		if (componentName == null)
			copy.componentName = null;
		else
			copy.componentName = new String(componentName);
		return copy;
	}
	
	public Icon getIcon() {
		return icon;
	}

	public Placement getPlacement() {
		return placement;
	}
	
	public String getComponentName() {
		return componentName;
	}
	
	public void setComponentName(String componentName) {
		this.componentName = componentName;
		notifyObservers(COMPONENT_NAME_CHANGED);
	}

	@Override
	public void update(Observable o, Object flag, Object additionalInfo) {
		if (o == icon)
			notifyObservers(ICON_UPDATED);
		else if (o == placement)
			notifyObservers(PLACEMENT_UPDATED);
	}

	public void added() {
		if (isAdded)
			return;
		isAdded = true;
		icon.added();
		notifyObservers(IM_ADDED);
	}

	public void removed() {
		if (!isAdded)
			return;
		isAdded = false;
		icon.removed();
		notifyObservers(IM_REMOVED);
	}
	
	public boolean isAdded() {
		return isAdded;
	}

}
