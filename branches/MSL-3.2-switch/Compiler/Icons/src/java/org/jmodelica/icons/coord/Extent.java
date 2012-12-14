package org.jmodelica.icons.coord;


/**
 * A representation of an extent in a plane. It's constructed from two points
 * that span this extent. This object is immutable.
 */
public class Extent {

	private Point p1;
	private Point p2;

	/**
	 * A no extent constant. Used for representing invalid or no extent.
	 */
	public static Extent NO_EXTENT = new Extent(null, null);

	/**
	 * Constructs an extent from two points <code>p1</code> and <code>p2</code>.
	 * 
	 * @param p1 First point
	 * @param p2 Second point
	 */
	public Extent(Point p1, Point p2) {
		this.p1 = p1;
		this.p2 = p2;
	}

	/**
	 * Calculates the height of this extent.
	 * 
	 * @return the height
	 */
	public double getHeight() {
		return Math.abs(p2.getY() - p1.getY());
	}

	/**
	 * Calculates the width of this extent.
	 * 
	 * @return the width
	 */
	public double getWidth() {
		return Math.abs(p2.getX() - p1.getX());
	}

	/**
	 * Calculates the point thats in the top right corner of this extent.
	 * 
	 * @return top right corner point
	 */
	public Point getTopRight() {
		return new Point(Math.max(getP1().getX(), getP2().getX()), Math.max(getP1().getY(), getP2().getY()));
	}

	/**
	 * Calculates the point thats in the top center edge of this extent.
	 * 
	 * @return top center edge point
	 */
	public Point getTopCenter() {
		return new Point((getP1().getX() + getP2().getX()) / 2, Math.max(getP1().getY(), getP2().getY()));
	}

	/**
	 * Calculates the point thats in the top left corner of this extent.
	 * 
	 * @return top left corner point
	 */
	public Point getTopLeft() {
		return new Point(Math.min(getP1().getX(), getP2().getX()), Math.max(getP1().getY(), getP2().getY()));
	}

	/**
	 * Calculates the point thats in the middle right edge of this extent.
	 * 
	 * @return middle right edge point
	 */
	public Point getMiddleRight() {
		return new Point(Math.max(getP1().getX(), getP2().getX()), (getP1().getY() + getP2().getY()) / 2);
	}

	/**
	 * Calculates the point thats in the middle of this extent.
	 * 
	 * @return middle point
	 */
	public Point getMiddle() {
		return new Point((getP1().getX() + getP2().getX()) / 2, (getP1().getY() + getP2().getY()) / 2);
	}

	/**
	 * Calculates the point thats in the middle left edge of this extent.
	 * 
	 * @return middle left edge point
	 */
	public Point getMiddleLeft() {
		return new Point(Math.min(getP1().getX(), getP2().getX()), (getP1().getY() + getP2().getY()) / 2);
	}

	/**
	 * Calculates the point thats in the bottom right corner of this extent.
	 * 
	 * @return bottom right corner point
	 */
	public Point getBottomRight() {
		return new Point(Math.max(getP1().getX(), getP2().getX()), Math.min(getP1().getY(), getP2().getY()));
	}

	/**
	 * Calculates the point thats in the bottom center edge of this extent.
	 * 
	 * @return bottom center edge point
	 */
	public Point getBottomCenter() {
		return new Point((getP1().getX() + getP2().getX()) / 2, Math.min(getP1().getY(), getP2().getY()));
	}

	/**
	 * Calculates the point thats in the bottom left corner of this extent.
	 * 
	 * @return bottom left corner point
	 */
	public Point getBottomLeft() {
		return new Point(Math.min(getP1().getX(), getP2().getX()), Math.min(getP1().getY(), getP2().getY()));
	}

	/**
	 * Returns an extent representing the same area as this extent but with
	 * points p1 and p2 such that p1 <= p2.
	 * 
	 * @return a fixed extent
	 */
	public Extent fix() {
		if (p1 == null || p2 == null) {
			return this;
		}
		double minX = p1.getX();
		double maxX = p2.getX();
		if (minX > maxX) {
			double temp = minX;
			minX = maxX;
			maxX = temp;
		}
		double minY = p1.getY();
		double maxY = p2.getY();
		if (minY > maxY) {
			double temp = minY;
			minY = maxY;
			maxY = temp;
		}

		return new Extent(new Point(minX, minY), new Point(maxX, maxY));
	}

	/**
	 * Constrains the extent <code>e</code> to this extent object.
	 * This method makes sure that the middle of e is the same as this and the
	 * aspect ratio is the same. Any resizing is done symmetric.
	 * 
	 * @param e Extent to constrain
	 * @return Constrained extent
	 */
	public Extent constrain(Extent e) {
		Point thisMiddle = getMiddle();
		Point eMiddle = e.getMiddle();

		Extent eFix = e.fix();

		double minX = eFix.getP1().getX();
		double minY = eFix.getP1().getY();
		double maxX = eFix.getP2().getX();
		double maxY = eFix.getP2().getY();

		// Move the middle of e to the middle of this.
		double xDiff = thisMiddle.getX() - eMiddle.getX();
		if (xDiff > 0)
			// e lies to the left of this so maxX needs to be increased.
			maxX += 2 * xDiff;
		else
			// e lies to the right of this so minX needs to be decreased (xDiff is negative).
			minX += 2 * xDiff;

		double yDiff = thisMiddle.getY() - eMiddle.getY();
		if (yDiff > 0)
			// e lies above this so maxY needs to be increased.
			maxY += 2 * yDiff;
		else
			// e lies bellow this so minY needs to be decreased (yDiff is negative).
			minY += 2 * yDiff;

		e = new Extent(new Point(minX, minY), new Point(maxX, maxY));

		// Resize e to make it the same aspect ratio as this.
		double thisScale = getWidth() / getHeight();
		double eScale = e.getWidth() / e.getHeight();

		if (thisScale > eScale) {
			// The width of e needs to be increased.
			minX -= (1 / eScale - 1 / thisScale) * getWidth() / 2;
			maxX += (1 / eScale - 1 / thisScale) * getWidth() / 2;
		} else {
			// the height of e needs to be increased.
			minY -= (eScale - thisScale) * getHeight() / 2;
			maxY += (eScale - thisScale) * getHeight() / 2;
		}

		return new Extent(new Point(minX, minY), new Point(maxX, maxY));
	}

	/**
	 * Constructs the extent that contains both <code>e1</code> and
	 * <code>e2</code>.
	 * 
	 * @param e1 First extent
	 * @param e2 Second extent
	 * @return union of the two extents
	 */
	public static Extent union(Extent e1, Extent e2) {
		e1 = e1.fix();
		e2 = e2.fix();
		double p1X = Math.min(e1.getP1().getX(), e2.getP1().getX());
		double p1Y = Math.min(e1.getP1().getY(), e2.getP1().getY());
		double p2X = Math.max(e1.getP2().getX(), e2.getP2().getX());
		double p2Y = Math.max(e1.getP2().getY(), e2.getP2().getY());
		return new Extent(new Point(p1X, p1Y), new Point(p2X, p2Y));
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see java.lang.Object#clone()
	 */
	public Extent clone() {
		return new Extent(p1, p2);
	}

	/**
	 * Returns the first point of this extent.
	 * 
	 * @return first point.
	 */
	public Point getP1() {
		return p1;
	}

	/**
	 * Returns the second point of this extent.
	 * 
	 * @return second point
	 */
	public Point getP2() {
		return p2;
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see java.lang.Object#toString()
	 */
	public String toString() {
		return "P1 = " + getP1() + ", P2 = " + getP2() + ", width = " + getWidth() + ", height = " + getHeight();
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see java.lang.Object#equals(java.lang.Object)
	 */
	@Override
	public boolean equals(Object obj) {
		if (!(obj instanceof Extent))
			return false;
		Extent e = (Extent) obj;
		return p1.equals(e.p1) && p2.equals(e.p2);
	}
}