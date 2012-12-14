package org.jmodelica.ide.graphical.actions;

import org.eclipse.gef.GraphicalViewer;
import org.eclipse.gef.SnapToGrid;
import org.eclipse.jface.action.Action;

public abstract class GridAction extends Action {

	private GraphicalViewer viewer;

	protected GridAction(GraphicalViewer viewer) {
		this.viewer = viewer;
	}

	public GraphicalViewer getViewer() {
		return viewer;
	}

	protected boolean isGridShowing() {
		Boolean value = (Boolean) viewer.getProperty(SnapToGrid.PROPERTY_GRID_VISIBLE);
		if (value != null)
			return value;
		return false;
	}

	protected boolean isGridSnapping() {
		Boolean value = (Boolean) viewer.getProperty(SnapToGrid.PROPERTY_GRID_ENABLED);
		if (value != null)
			return value;
		return false;
	}

}
