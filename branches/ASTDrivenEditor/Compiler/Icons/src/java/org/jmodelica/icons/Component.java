package org.jmodelica.icons;

import org.jmodelica.icons.coord.Placement;

public class Component {

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

}
