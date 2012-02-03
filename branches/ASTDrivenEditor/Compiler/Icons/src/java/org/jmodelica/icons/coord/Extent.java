package org.jmodelica.icons.coord;

import org.jmodelica.icons.Observable;
import org.jmodelica.icons.Observer;

public class Extent extends Observable implements Observer {
	
	
	/**
	 * Sent to observers when the first point in the extent is moved.
	 */
	public static final Object P1_UPDATED = new Object();
	
	/**
	 * Sent to observers when the first point in the extent is swapped for a new.
	 */
	public static final Object P1_SWAPPED = new Object();
	
	/**
	 * Sent to observers when the second point in the extent is moved.
	 */
	public static final Object P2_UPDATED = new Object();
	
	/**
	 * Sent to observers when the second point in the extent is swapped for a new.
	 */
	public static final Object P2_SWAPPED = new Object();
	
	private Point p1;
	private Point p2;

	public static Extent NO_EXTENT = new Extent();

	private Extent() {
		this(null, null);
	}

	public Extent(Point p1, Point p2) {
		setP1(p1);
		setP2(p2);
	}

	public double getHeight() {
		return Math.abs(p2.getY() - p1.getY());

	}

	public double getWidth() {
		return Math.abs(p2.getX() - p1.getX());
	}

	public Point getMiddle() {
		Extent ext = fix();
		return new Point(ext.getP1().getX() + getWidth() / 2, ext.getP1().getY() + getHeight() / 2);
	}

	/**
	 * Returns an extent representing the same area as this extent but with
	 * points
	 * p1 and p2 such that p1 <= p2.
	 * 
	 * @param extent
	 * @return
	 */
	public Extent fix() {
		if (p1 == null || p2 == null) {
			return this;
		}
		int minx = (int) (p1.getX());
		int maxx = (int) (p2.getX());
		if (minx > maxx) {
			int temp = minx;
			minx = maxx;
			maxx = temp;
		}
		int miny = (int) (p1.getY());
		int maxy = (int) (p2.getY());
		if (miny > maxy) {
			int temp = miny;
			miny = maxy;
			maxy = temp;
		}

		return new Extent(new Point(minx, miny), new Point(maxx, maxy));
	}

	/**
	 * Returns a copy of this Extent that contains the provided extent,
	 * expanding it symmetric if necessary.
	 */
	public Extent contain(Extent e) {
		Extent res = new Extent(new Point(p1.getX(), p1.getY()), new Point(p2.getX(), p2.getY()));
		e = e.fix();
		double diff, prop, newHeight, newWidth;

		if (e.p1.getX() < res.p1.getX()) {
			diff = res.p1.getX() - e.p1.getX();
			prop = res.getHeight() / res.getWidth();

			res.p1.setX(e.p1.getX());
			res.p2.setX(res.p2.getX() + diff);

			newHeight = (prop * res.getWidth());
			diff = (newHeight - res.getHeight()) / 2;
			res.p1.setY(res.p1.getY() - diff);
			res.p2.setY(res.p2.getY() + diff);
		}
		if (e.p1.getY() < res.p1.getY()) {
			diff = res.p1.getY() - e.p1.getY();
			prop = res.getHeight() / res.getWidth();
			res.p1.setY(e.p1.getY());
			res.p2.setY(res.p2.getY() + diff);

			newWidth = res.getHeight() / prop;
			diff = (newWidth - res.getWidth()) / 2;
			res.p1.setX(res.p1.getX() - diff);
			res.p2.setX(res.p2.getX() + diff);
		}
		if (e.p2.getX() > res.p2.getX()) {
			diff = e.p2.getX() - res.p2.getX();
			prop = res.getHeight() / res.getWidth();
			res.p2.setX(e.p2.getX());
			res.p1.setX(res.p1.getX() - diff);

			newHeight = (prop * res.getWidth());
			diff = (newHeight - res.getHeight()) / 2;
			res.p1.setY(res.p1.getY() - diff);
			res.p2.setY(res.p2.getY() + diff);
		}
		if (e.p2.getY() > res.p2.getY()) {
			diff = e.p2.getY() - res.p2.getY();
			prop = res.getHeight() / res.getWidth();
			res.p2.setY(e.p2.getY());
			res.p1.setY(res.p1.getY() - diff);

			newWidth = res.getHeight() / prop;
			diff = (newWidth - res.getWidth()) / 2;
			res.p1.setX(res.p1.getX() - diff);
			res.p2.setX(res.p2.getX() + diff);
		}
		return res;
	}

	public Extent clone() {
		return new Extent(p1.clone(), p2.clone());
	}

	public void setP2(Point newP2) {
		if (p2 != null && p2.equals(newP2))
			return;
		if (p2 != null)
			p2.removeObserver(this);
		p2 = newP2;
		if (newP2 != null)
			newP2.addObserver(this);
		notifyObservers(P2_SWAPPED);
	}

	public Point getP2() {
		return p2;
	}

	public void setP1(Point newP1) {
		if (p1 != null && p1.equals(newP1))
			return;
		if (p1 != null)
			p1.removeObserver(this);
		p1 = newP1;
		if (newP1 != null)
			newP1.addObserver(this);
		notifyObservers(P1_SWAPPED);
	}

	public Point getP1() {
		return p1;
	}

	public String toString() {
		return "P1 = " + getP1() + ", P2 = " + getP2() + ", width = " + getWidth() + ", height = " + getHeight();
	}

	@Override
	public void update(Observable o, Object flag) {
		if (o == p1 && (flag == Point.X_UPDATED || flag == Point.Y_UPDATED))
			notifyObservers(P1_UPDATED);
		else if (o == p2 && (flag == Point.X_UPDATED || flag == Point.Y_UPDATED))
			notifyObservers(P2_UPDATED);
		else
			o.removeObserver(this);
	}
}