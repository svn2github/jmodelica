package org.jmodelica.icons;

import org.jmodelica.icons.coord.Placement;

public class Component extends Observable implements Observer {
	
	public static final Object ICON_UPDATED = new Object();
	public static final Object PLACEMENT_UPDATED = new Object();

	private final Icon icon;
	private final Placement placement;
	private String componentName = null;
	
	public Component(Icon icon, Placement placement) {
		this(icon, placement, null);
	}

	public Component(Icon icon, Placement placement,String componentName) {
		this.icon = icon;
		this.placement = placement;
		this.componentName = componentName;
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

	@Override
	public void update(Observable o, Object flag) {
		if (o == icon)
			notifyObservers(ICON_UPDATED);
		else if (o == placement)
			notifyObservers(PLACEMENT_UPDATED);
		else
			o.removeObserver(this);
	}

}
