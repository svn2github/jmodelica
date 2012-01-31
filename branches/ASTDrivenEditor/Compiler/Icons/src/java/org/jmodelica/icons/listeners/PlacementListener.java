package org.jmodelica.icons.listeners;

import org.jmodelica.icons.coord.Placement;

public interface PlacementListener {
	public void placementTransformationChange(Placement p);
	public void placementVisibleChange(Placement p);
}
