package org.jmodelica.icons.listeners;

import org.jmodelica.icons.coord.Transformation;

public interface TransformationListener {
	public void transformationOriginChanged(Transformation t);
	public void transformationExtentChanged(Transformation t);
	public void transformationRotationChanged(Transformation t);
}
