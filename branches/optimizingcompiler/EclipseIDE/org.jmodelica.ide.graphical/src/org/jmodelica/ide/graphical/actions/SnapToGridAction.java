package org.jmodelica.ide.graphical.actions;

import java.beans.PropertyChangeEvent;
import java.beans.PropertyChangeListener;

import org.eclipse.gef.GraphicalViewer;
import org.eclipse.gef.SnapToGrid;

public class SnapToGridAction extends GridAction implements PropertyChangeListener {

	public static final String ID = "snapToGrid";

	public SnapToGridAction(GraphicalViewer viewer) {
		super(viewer);
		setText("Snap to Grid");
		setId(ID);
		viewer.addPropertyChangeListener(this);
	}

	@Override
	public void run() {
		getViewer().setProperty(SnapToGrid.PROPERTY_GRID_ENABLED, !isGridSnapping());
	}

	@Override
	public boolean isChecked() {
		return isGridSnapping();
	}

	@Override
	public boolean isEnabled() {
		return isGridShowing();
	}

	@Override
	public void propertyChange(PropertyChangeEvent e) {
		if (e.getPropertyName() == SnapToGrid.PROPERTY_GRID_VISIBLE) {
			firePropertyChange(ENABLED, e.getOldValue(), e.getNewValue());
		}
	}

}
