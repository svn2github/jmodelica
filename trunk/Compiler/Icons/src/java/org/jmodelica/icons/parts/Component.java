package org.jmodelica.icons.parts;

import org.jmodelica.icons.Icon;
import org.jmodelica.icons.parts.coord.Placement;


public class Component {
	private final Icon icon;
	private final Placement placement;
	
	public Component(Icon icon, Placement placement) {
		this.icon = icon;
		this.placement = placement;
	}

	public Icon getIcon() {
		return icon;
	}

	public Placement getPlacement() {
		return placement;
	}
}
