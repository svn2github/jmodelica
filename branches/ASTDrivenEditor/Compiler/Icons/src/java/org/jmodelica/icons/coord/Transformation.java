package org.jmodelica.icons.coord;

import org.jmodelica.icons.listeners.ExtentListener;
import org.jmodelica.icons.listeners.Observable;
import org.jmodelica.icons.listeners.PointListener;
import org.jmodelica.icons.listeners.TransformationListener;

public class Transformation extends Observable<TransformationListener> implements PointListener, ExtentListener {
	private Point origin;
	private Extent extent;
	private double rotation;

	private static final Point DEFAULT_ORIGIN = new Point(0, 0);
	private static final double DEFAULT_ROTATION = 0;

	public Transformation(Extent extent, Point origin, double rotation) {
		setExtent(extent);
		setOrigin(origin);
		setRotation(rotation);
	}

	public Transformation() {
		this(Extent.NO_EXTENT, DEFAULT_ORIGIN, DEFAULT_ROTATION);
	}

	public Transformation(Extent extent) {
		this(extent, DEFAULT_ORIGIN, DEFAULT_ROTATION);
	}

	public Transformation(Extent extent, Point origin) {
		this(extent, origin, DEFAULT_ROTATION);
	}

	public Transformation(Extent extent, double rotation) {
		this(extent, DEFAULT_ORIGIN, rotation);
	}

	public Point getOrigin() {
		return origin;
	}

	public void setOrigin(Point newOrigin) {
		if (origin != null && origin.equals(newOrigin))
			return;
		if (origin != null)
			origin.removeListener(this);
		origin = newOrigin;
		if (newOrigin != null)
			newOrigin.addlistener(this);
		notifyOriginChange();
	}

	public Extent getExtent() {
		return extent;
	}

	public void setExtent(Extent newExtent) {
		if (extent != null && extent.equals(newExtent))
			return;
		if (extent != null)
			extent.removeListener(this);
		extent = newExtent;
		if (newExtent != null)
			newExtent.addlistener(this);
		notifyExtentChange();
	}

	public double getRotation() {
		return rotation;
	}

	public void setRotation(double newRotation) {
		if (rotation == newRotation)
			return;
		rotation = newRotation;
		notifyRotationChange();
	}

	public String toString() {
		String s = "";
		s += "extent = " + extent;
		s += "\norigin = " + origin;
		s += "\nrotation = " + rotation;
		return s;
	}

	@Override
	public void extentP1Updated(Extent e) {
		if (e != extent)
			return;
		notifyExtentChange();
	}

	@Override
	public void extentP2Updated(Extent e) {
		if (e != extent)
			return;
		notifyExtentChange();
	}

	@Override
	public void pointXCordUpdated(Point p) {
		if (p != origin)
			return;
		notifyOriginChange();
	}

	@Override
	public void pointYCordUpdated(Point p) {
		if (p != origin)
			return;
		notifyOriginChange();
	}

	private void notifyOriginChange() {
		for (TransformationListener l : getListeners())
			l.transformationOriginChanged(this);
	}

	private void notifyExtentChange() {
		for (TransformationListener l : getListeners())
			l.transformationExtentChanged(this);
	}

	private void notifyRotationChange() {
		for (TransformationListener l : getListeners())
			l.transformationRotationChanged(this);
	}

}