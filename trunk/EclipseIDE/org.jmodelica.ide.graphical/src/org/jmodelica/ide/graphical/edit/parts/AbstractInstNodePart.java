package org.jmodelica.ide.graphical.edit.parts;

import java.util.ArrayList;
import java.util.List;

import org.jmodelica.icons.Layer;
import org.jmodelica.icons.Observable;
import org.jmodelica.icons.Observer;
import org.jmodelica.icons.coord.CoordinateSystem;
import org.jmodelica.ide.graphical.proxy.AbstractNodeProxy;
import org.jmodelica.ide.graphical.util.ASTNodeResourceProvider;

public abstract class AbstractInstNodePart extends AbstractModelicaPart implements ASTNodeResourceProvider, Observer {

	public AbstractInstNodePart(AbstractNodeProxy model) {
		super(model);
	}

	@Override
	public AbstractNodeProxy getModel() {
		return (AbstractNodeProxy) super.getModel();
	}
	
	@Override
	public void activate() {
		super.activate();
		getModel().getLayer().addObserver(this);
		getModel().getLayer().getCoordinateSystem().addObserver(this);
	}
	
	@Override
	public void deactivate() {
		super.deactivate();
	}

	@Override
	protected void transformInvalid() {
		refreshVisuals();
	}

	@Override
	protected List<Object> getModelChildren() {
		List<Object> children = new ArrayList<Object>();
		children.addAll(getModel().getGraphics());
		children.addAll(getModel().getComponents());
		return children;
	}
	
	@Override
	public String getComponentName() {
		return getModel().getComponentName();
	}

	@Override
	public String getClassName() {
		return getModel().getClassName();
	}

	@Override
	public String getParameterValue(String parameter) {
		return getModel().getParameterValue(parameter);
	}

	@Override
	public void update(Observable o, Object flag, Object additionalInfo) {
		if (o == getModel().getLayer() && flag == Layer.GRAPHICS_SWAPPED)
			refreshChildren();
		if (o == getModel().getLayer().getCoordinateSystem()) {
			if (flag == CoordinateSystem.EXTENT_UPDATED)
				updateLayerExtent();
			if (flag == CoordinateSystem.GRID_CHANGED)
				updateGrid();
			if (flag == CoordinateSystem.INITIAL_SCALE_CHANGED)
				updateInitialScale();
			if (flag == CoordinateSystem.PRESERVE_ASPECT_RATIO_CHANGED)
				updatePreserveAspectRatio();
		}
		if (!isActive())
			o.removeObserver(this);
		super.update(o, flag, additionalInfo);
	}

	protected void updateLayerExtent() {
		invalidateTransform();
	}
	
	protected void updateGrid() {
	}

	protected void updateInitialScale() {
	}

	protected void updatePreserveAspectRatio() {
	}

}
