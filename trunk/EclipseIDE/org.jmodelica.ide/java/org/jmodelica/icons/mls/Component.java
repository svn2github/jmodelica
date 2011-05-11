package org.jmodelica.icons.mls;

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
