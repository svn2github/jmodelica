package org.jmodelica.ide.graphical.actions;

import org.eclipse.gef.GraphicalViewer;
import org.eclipse.gef.SnapToGrid;
import org.jmodelica.ide.graphical.Editor;

public class ShowGridAction extends GridAction {

	public static final String ID = "showGrid";
	private boolean forceDisabledSnapToGrid = false;

	public ShowGridAction(GraphicalViewer viewer) {
		super(viewer);
		setText("Show Grid");
		setId(ID);
	}

	@Override
	public void run() {
		boolean newValue = !isGridShowing();
		if (!newValue && isGridSnapping()) {
			forceDisabledSnapToGrid = true;
			getViewer().setProperty(SnapToGrid.PROPERTY_GRID_ENABLED, false);
		} else if (forceDisabledSnapToGrid) {
			getViewer().setProperty(SnapToGrid.PROPERTY_GRID_ENABLED, true);
			forceDisabledSnapToGrid = false;
		} else {
			forceDisabledSnapToGrid = false;
		}
		getViewer().setProperty(SnapToGrid.PROPERTY_GRID_VISIBLE, newValue);
	}

	@Override
	public boolean isChecked() {
		return isGridShowing();
	}

	@Override
	public boolean isEnabled() {
		Boolean value = (Boolean) getViewer().getProperty(Editor.DIAGRAM_READ_ONLY);
		if (value != null && value)
			return false;
		return true;
	}
}
