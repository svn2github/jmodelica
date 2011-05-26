package org.jmodelica.icons.mls;


public class CoordinateSystem {
	
	private Extent extent;
	private boolean preserveAspectRatio;
	private double initialScale;
	private double[] grid;
	
	private static final boolean DEFAULT_PRESERVE_ASPECT_RATIO = true;
	private static final double DEFAULT_INITIAL_SCALE = 0.1;
	private static final double[] DEFAULT_GRID = {2.0, 2.0};
	
	public static CoordinateSystem DEFAULT_COORDINATE_SYSTEM = 
		new CoordinateSystem(); 
	
	public CoordinateSystem(Extent extent, boolean preserveAspectRatio, 
									double initialScale, double[] grid) {
		this.extent = extent;
		this.preserveAspectRatio = preserveAspectRatio;
		this.initialScale = initialScale;
		this.grid = grid;
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
	public void setExtent(Extent extent)
	{
		this.extent = extent;
	}
	public boolean shouldPreserveAspectRatio() {
		return preserveAspectRatio;
	}
	public void setPreserveAspectRatio(boolean value)
	{
		this.preserveAspectRatio = value;
	}
	public double getInitialScale() {
		return initialScale;
	}
	public void setInitialScale(double scale)
	{
		this.initialScale = scale;
	}
	public double[] getGrid() {
		return grid;
	}
	public void setGrid(double[] grid)
	{
		this.grid = grid;
	}
	public String toString() {
		return "extent = " + extent + "\ngrid x = " + grid[0] + ", grid y = " + grid[1];
	}
}