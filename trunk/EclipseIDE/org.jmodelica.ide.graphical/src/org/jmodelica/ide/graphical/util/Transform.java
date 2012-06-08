package org.jmodelica.ide.graphical.util;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

import org.eclipse.draw2d.PositionConstants;
import org.jmodelica.icons.coord.Extent;
import org.jmodelica.icons.coord.Point;

public class Transform implements Cloneable {

	private final static int A11 = 0;
	private final static int A12 = 1;
	private final static int A21 = 2;
	private final static int A22 = 3;

	private final static int B1 = 0;
	private final static int B2 = 1;

	private final static Point XY_VECTOR = new Point(Math.cos(Math.PI / 4), Math.sin(Math.PI / 4));
	private final static Point X_VECTOR = new Point(1, 0);
	private final static Point Y_VECTOR = new Point(0, 1);

	public final static Transform yInverter = new YInverterTransform();
	double[] aMatrix = { 1, 0, 0, 1 };
	double[] bMatrix = { 0, 0 };

	/**
	 * Default constructor, creates a transform class with translation = 0,
	 * scale = 1 and rotation = 0.
	 */
	public Transform() {}

	/**
	 * Private constructor used when making a copy of an existing transform
	 * class.
	 * 
	 * @param t transform instance that this instance should copy.
	 */
	private Transform(Transform t) {
		this.aMatrix = Arrays.copyOf(t.aMatrix, t.aMatrix.length);
		this.bMatrix = Arrays.copyOf(t.bMatrix, t.bMatrix.length);
	}

	/**
	 * Returns a copy of this object.
	 * 
	 * @return a identical copy.
	 */
	@Override
	public Transform clone() {
		return new Transform(this);
	}

	/**
	 * Rotates the transformation matrix by angle <code>angle</code> in counter
	 * clockwise direction.
	 * 
	 * Cost of this method is:
	 * - One Math.cos calculation.
	 * - One Math.sin calculation.
	 * - Eight double multiplications.
	 * - Two double additions.
	 * - Two double subtractions.
	 * 
	 * @param angle an angle, in radians.
	 */
	public void rotate(double angle) {
		// TODO: Optimize, use tmp variables instead of allocating a new matrix.
		double cos = Math.cos(angle);
		double sin = Math.sin(angle);
		double[] newA = new double[aMatrix.length];
		newA[A11] = aMatrix[A11] * cos + aMatrix[A12] * sin;
		newA[A12] = aMatrix[A12] * cos - aMatrix[A11] * sin;
		newA[A21] = aMatrix[A21] * cos + aMatrix[A22] * sin;
		newA[A22] = aMatrix[A22] * cos - aMatrix[A21] * sin;
		aMatrix = newA;
	}

	/**
	 * Scales the transformation matrix in both x and y with the ratio
	 * <code>scale</code>. @see {@link Transform#scale(double, double)}.
	 * 
	 * @param scale a ratio for the scale.
	 */
	public void scale(double scale) {
		scale(scale, scale);
	}

	/**
	 * Scales the transformation matrix in x with the ratio <code>xScale</code>
	 * and in y with ratio <code>yScale</code>. A ratio less than one will make
	 * things smaller and ratio greater than one will make things bigger.
	 * 
	 * Cost of this method is:
	 * - Four double multiplications.
	 * 
	 * @param xScale a ratio for the x-axis scale.
	 * @param yScale a ratio for the y-axis scale.
	 */
	public void scale(double xScale, double yScale) {
		aMatrix[A11] *= xScale;
		aMatrix[A12] *= xScale;
		aMatrix[A21] *= yScale;
		aMatrix[A22] *= yScale;
	}

	/**
	 * Translates/moves The transformation matrix in x and y steps. Translation
	 * is done in the current coordinate system.
	 * 
	 * @param x number of points to move in x-axis.
	 * @param y number of points to move in y-axis.
	 */
	public void translate(double x, double y) {
		Point p = transform(new Point(x, y));
		bMatrix[B1] = p.getX();
		bMatrix[B2] = p.getY();
	}

	/**
	 * Translates/moves The transformation matrix in x and y defined in the
	 * point p. Translation is done in the current coordinate system.
	 * 
	 * @param p number of points to move in both x- and y-axis.
	 */
	public void translate(Point p) {
		translate(p.getX(), p.getY());
	}

	/**
	 * Calculates the inverse transform of this transform such that p =
	 * t.transform(t.getInverseTransform().transform(p)).
	 * 
	 * @return inverse transform
	 */
	public Transform getInverseTransfrom() {
		double det = 1 / (aMatrix[A11] * aMatrix[A22] - aMatrix[A12] * aMatrix[A21]);
		Transform t = new Transform();
		t.aMatrix[A11] = det * aMatrix[A22];
		t.aMatrix[A12] = -det * aMatrix[A12];
		t.aMatrix[A21] = -det * aMatrix[A21];
		t.aMatrix[A22] = det * aMatrix[A11];
		t.bMatrix[B1] = det * (aMatrix[A12] * bMatrix[B2] - aMatrix[A22] * bMatrix[B1]);
		t.bMatrix[B2] = det * (aMatrix[A21] * bMatrix[B1] - aMatrix[A11] * bMatrix[B2]);
		return t;
	}

	/**
	 * Translates, scales and rotates the point <code>p</code> using this
	 * current transformation matrix.
	 * 
	 * @param p Point to transform
	 * @return The transformed point
	 */
	public Point transform(Point p) {
		double x = p.getX();
		double y = p.getY();
		return new Point(x * aMatrix[A11] + y * aMatrix[A12] + bMatrix[B1], x * aMatrix[A21] + y * aMatrix[A22] + bMatrix[B2]);
	}

	/**
	 * Scales and rotates the vector that is represented with the point
	 * <code>p</code> using this current transformation matrix.
	 * 
	 * @param p Vector to transform
	 * @return transformed vector
	 */
	public Point transformVector(Point p) {
		double x = p.getX();
		double y = p.getY();
		return new Point(x * aMatrix[A11] + y * aMatrix[A12], x * aMatrix[A21] + y * aMatrix[A22]);
	}

	/**
	 * Transforms a list of points <code>pl</code> using this current
	 * transformation matrix.
	 * 
	 * @param pl Point list to transform
	 * @return transformed point list
	 */
	public List<Point> transform(List<Point> pl) {
		ArrayList<Point> transformed = new ArrayList<Point>(pl.size());
		for (Point p : pl) {
			transformed.add(transform(p));
		}
		return transformed;
	}

	/**
	 * Transforms the extent <code>e</code> using this current transformation
	 * matrix.
	 * 
	 * @param e Extent to transform
	 * @return transformed extent
	 */
	public Extent transform(Extent e) {
		//FIXME: If rotated by i.e. 45 degrees how should the extent be calculated? P1(min(PA.x,PB.x), min(PA.y, PB.y)), P2(max(PA.x, PB.x), max(PA.y, PB.y))? Preserve reflection?
		Point pTL = transform(e.getTopLeft());
		Point pTR = transform(e.getTopRight());
		Point pBR = transform(e.getBottomRight());
		Point pBL = transform(e.getBottomLeft());
		return new Extent(new Point(Math.min(Math.min(pTL.getX(), pTR.getX()), Math.min(pBL.getX(), pBR.getX())), Math.min(Math.min(pTL.getY(), pTR.getY()), Math.min(pBL.getY(), pBR.getY()))), new Point(Math.max(Math.max(pTL.getX(), pTR.getX()), Math.max(pBL.getX(), pBR.getX())), Math.max(Math.max(pTL.getY(), pTR.getY()), Math.max(pBL.getY(), pBR.getY()))));
	}

	/**
	 * Transforms a direction constant <code>direction</code> using this current
	 * transformation matrix
	 * 
	 * @param direction Direction constant to transform
	 * @return transformed direction constant
	 */
	public int transformDirection(int direction) {
		Point dir;
		switch (direction) {
		case PositionConstants.NORTH:
			dir = new Point(0, 1);
			break;
		case PositionConstants.EAST:
			dir = new Point(1, 0);
			break;
		case PositionConstants.SOUTH:
			dir = new Point(0, -1);
			break;
		case PositionConstants.WEST:
			dir = new Point(-1, 0);
			break;
		case PositionConstants.NORTH_EAST:
			dir = new Point(1, 1);
			break;
		case PositionConstants.NORTH_WEST:
			dir = new Point(-1, 1);
			break;
		case PositionConstants.SOUTH_EAST:
			dir = new Point(1, -1);
			break;
		case PositionConstants.SOUTH_WEST:
			dir = new Point(-1, -1);
			break;
		default:
			return PositionConstants.NONE;
		}

		dir = transformVector(dir);
		double v = Math.atan2(dir.getY(), dir.getX());

		if (v < -7 * Math.PI / 8)
			return PositionConstants.WEST;
		else if (v < -5 * Math.PI / 8)
			return PositionConstants.SOUTH_WEST;
		else if (v < -3 * Math.PI / 8)
			return PositionConstants.SOUTH;
		else if (v < -Math.PI / 8)
			return PositionConstants.SOUTH_EAST;
		else if (v < Math.PI / 8)
			return PositionConstants.EAST;
		else if (v < 3 * Math.PI / 8)
			return PositionConstants.NORTH_EAST;
		else if (v < 5 * Math.PI / 8)
			return PositionConstants.NORTH;
		else if (v < 7 * Math.PI / 8)
			return PositionConstants.NORTH_WEST;
		else
			return PositionConstants.WEST;
	}

	/**
	 * Calculates the current scale factor. The returned scale factor is the
	 * length of the vector (sqrt(2); sqrt(2)).
	 * 
	 * @return current scale factor
	 */
	public double getScale() {
		Point p = transformVector(XY_VECTOR);
		return Math.hypot(p.getX(), p.getY());
	}

	/**
	 * Calculates the current scale factor in x-axis. The returned scale factor
	 * is the length of the vector (1; 0).
	 * 
	 * @return current scale factor in x-axis
	 */
	public double getXScale() {
		Point p = transformVector(X_VECTOR);
		return Math.hypot(p.getX(), p.getY());
	}

	/**
	 * Calculates the current scale factor in y-axis. The returned scale factor
	 * is the length of the vector (0; 1).
	 * 
	 * @return current scale factor in y-axis
	 */
	public double getYScale() {
		Point p = transformVector(Y_VECTOR);
		return Math.hypot(p.getX(), p.getY());
	}

	/**
	 * Calculates the current transform rotation. Transforms a (1,0) vector
	 * without translation and then checks it's rotation using Math.atan2().
	 * 
	 * @return Value between -pi and pi
	 */
	public double getRotation() {
		Point p = transformVector(X_VECTOR);
		return Math.atan2(p.getY(), p.getX());
	}

	/**
	 * Calculates if the current transformation is mirrored.
	 * 
	 * @return true if mirrored
	 */
	public boolean isMirrored() {
		double v1 = Math.atan2(aMatrix[A11], aMatrix[A21]);
		double v1i = v1 + Math.PI;
		if (v1i > Math.PI)
			v1i -= 2 * Math.PI;

		double v2 = Math.atan2(aMatrix[A12], aMatrix[A22]);
		if (v1 > v1i)
			return v1 < v2 || v2 < v1i;
		else
			return v1 < v2 && v2 < v1i;
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see java.lang.Object#toString()
	 */
	@Override
	public String toString() {
		return "Transform(" + aMatrix[A11] + ", " + aMatrix[A12] + ", " + aMatrix[A21] + ", " + aMatrix[A22] + ")(" + bMatrix[B1] + ", " + bMatrix[B2] + ")";
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see java.lang.Object#equals(java.lang.Object)
	 */
	@Override
	public boolean equals(Object obj) {
		if (!(obj instanceof Transform)) {
			return false;
		}
		Transform t = (Transform) obj;
		if (aMatrix[A11] == t.aMatrix[A11] && aMatrix[A12] == t.aMatrix[A12] && aMatrix[A21] == t.aMatrix[A21] && aMatrix[A22] == t.aMatrix[A22] && bMatrix[B1] == t.bMatrix[B1] && bMatrix[B2] == t.bMatrix[B2]) {
			return true;
		}
		return false;
	}

	/**
	 * Returns the current transformation in x-axis.
	 * 
	 * @return current offset in x-axis
	 */
	public double getXOffset() {
		return bMatrix[B1];
	}

	/**
	 * Returns the current transformation in y-axis.
	 * 
	 * @return current offset in y-axis
	 */
	public double getYOffset() {
		return bMatrix[B2];
	}

	private static class YInverterTransform extends Transform {
		public YInverterTransform() {
			super.scale(1, -1);
		}

		@Override
		public void scale(double xScale, double yScale) {
			throw new IllegalArgumentException("You are not allowed to modify this instance!");
		}

		@Override
		public void rotate(double angle) {
			throw new IllegalArgumentException("You are not allowed to modify this instance!");
		}

		@Override
		public void translate(double x, double y) {
			throw new IllegalArgumentException("You are not allowed to modify this instance!");
		}
	}

}
