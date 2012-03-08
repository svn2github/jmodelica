package org.jmodelica.icons.coord;

import org.jmodelica.icons.Observable;
import org.jmodelica.icons.Observer;

public class CoordinateSystem extends Observable implements Observer {
	
	public static final Object EXTENT_UPDATED = new Object();
	public static final Object EXTENT_SWAPPED = new Object();
	public static final Object PRESERVE_ASPECT_RATIO_CHANGED = new Object();
	public static final Object INITIAL_SCALE_CHANGED = new Object();
	public static final Object GRID_CHANGED = new Object();

	private Extent extent;
	private boolean preserveAspectRatio;
	private double initialScale;
	private double[] grid;

	public static final boolean DEFAULT_PRESERVE_ASPECT_RATIO = true;
	public static final double DEFAULT_INITIAL_SCALE = 0.1;
	public static final double[] DEFAULT_GRID = { 10.0, 10.0 };

	public static CoordinateSystem DEFAULT_COORDINATE_SYSTEM = new CoordinateSystem();

	public CoordinateSystem(Extent extent, boolean preserveAspectRatio, double initialScale, double[] grid) {
		setExtent(extent);
		setPreserveAspectRatio(preserveAspectRatio);
		setInitialScale(initialScale);
		setGrid(grid);
	}

	public CoordinateSystem() {
		this(new Extent(new Point(-100, -100), new Point(100, 100)), DEFAULT_PRESERVE_ASPECT_RATIO, DEFAULT_INITIAL_SCALE, DEFAULT_GRID);
	}

	public CoordinateSystem(Extent extent) {
		this(extent, DEFAULT_PRESERVE_ASPECT_RATIO, DEFAULT_INITIAL_SCALE, DEFAULT_GRID);
	}

	public CoordinateSystem(Extent extent, boolean preserveAspectRatio) {
		this(extent, preserveAspectRatio, DEFAULT_INITIAL_SCALE, DEFAULT_GRID);
	}

	public CoordinateSystem(Extent extent, double initialScale) {
		this(extent, DEFAULT_PRESERVE_ASPECT_RATIO, initialScale, DEFAULT_GRID);
	}

	public Extent getExtent() {
		return extent;
	}

	public void setExtent(Extent newExtent) {
		if (extent == newExtent)
			return;
		if (extent != null)
			extent.removeObserver(this);
		extent = newExtent;
		if (newExtent != null) {
			newExtent.addObserver(this);
		}
		notifyObservers(EXTENT_SWAPPED);
	}

	public boolean shouldPreserveAspectRatio() {
		return preserveAspectRatio;
	}

	public void setPreserveAspectRatio(boolean value) {
		if (preserveAspectRatio == value)
			return;
		preserveAspectRatio = value;
		notifyObservers(PRESERVE_ASPECT_RATIO_CHANGED);
	}

	public double getInitialScale() {
		return initialScale;
	}

	public void setInitialScale(double scale) {
		if (initialScale == scale)
			return;
		initialScale = scale;
		notifyObservers(INITIAL_SCALE_CHANGED);
	}

	public double[] getGrid() {
		return grid;
	}

	public void setGrid(double[] newGrid) {
		grid = newGrid;
		notifyObservers(GRID_CHANGED);
	}

	public String toString() {
		return "extent = " + extent + "\ngrid x = " + grid[0] + ", grid y = " + grid[1];
	}

	@Override
	public void update(Observable o, Object flag, Object additionalInfo) {
		if (o == extent)
			notifyObservers(EXTENT_UPDATED);
	}

}