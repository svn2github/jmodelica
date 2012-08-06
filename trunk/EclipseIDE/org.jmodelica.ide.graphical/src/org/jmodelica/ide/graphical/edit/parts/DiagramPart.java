package org.jmodelica.ide.graphical.edit.parts;

import java.util.ArrayList;
import java.util.List;

import org.eclipse.draw2d.ConnectionLayer;
import org.eclipse.draw2d.FreeformLayer;
import org.eclipse.draw2d.FreeformLayout;
import org.eclipse.draw2d.IFigure;
import org.eclipse.draw2d.MarginBorder;
import org.eclipse.gef.EditPolicy;
import org.eclipse.gef.LayerConstants;
import org.jmodelica.icons.Observable;
import org.jmodelica.ide.graphical.edit.DiagramConnectionRouter;
import org.jmodelica.ide.graphical.edit.policies.DiagramPolicy;
import org.jmodelica.ide.graphical.proxy.AbstractDiagramProxy;
import org.jmodelica.ide.graphical.proxy.ClassDiagramProxy;
import org.jmodelica.ide.graphical.util.Transform;

public class DiagramPart extends AbstractInstNodePart {

	public DiagramPart(AbstractDiagramProxy model) {
		super(model);
	}

	@Override
	public AbstractDiagramProxy getModel() {
		return (AbstractDiagramProxy) super.getModel();
	}

	@Override
	protected IFigure createFigure() {
		IFigure f = new FreeformLayer();
		f.setBorder(new MarginBorder(3));
		f.setLayoutManager(new FreeformLayout());

		// Create the static router for the connection layer
		ConnectionLayer connLayer = (ConnectionLayer) getLayer(LayerConstants.CONNECTION_LAYER);
		connLayer.setConnectionRouter(new DiagramConnectionRouter());

		return f;
	}

	@Override
	protected Transform calculateTransform() {
		Transform transform = new Transform();
		transform.translate(300, 300);
		transform.scale(3);
		return transform;
	}

	@Override
	protected void createEditPolicies() {
		installEditPolicy(EditPolicy.LAYOUT_ROLE, new DiagramPolicy(this));
	}

	@Override
	protected List<Object> getModelChildren() {
		List<Object> children = new ArrayList<Object>();
		children.addAll(getModel().getGraphics());
		children.addAll(getModel().getComponents());
		return children;
	}

	@Override
	public void update(Observable o, Object flag, Object additionalInfo) {
		if (o == getModel() && flag == ClassDiagramProxy.COMPONENT_ADDED)
			refreshChildren();
		if (o == getModel() && flag == ClassDiagramProxy.COMPONENT_REMOVED)
			refreshChildren();
		super.update(o, flag, additionalInfo);
	}

}
