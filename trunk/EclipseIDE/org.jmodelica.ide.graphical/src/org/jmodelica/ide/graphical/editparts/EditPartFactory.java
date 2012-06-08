package org.jmodelica.ide.graphical.editparts;

import org.eclipse.gef.EditPart;
import org.jmodelica.icons.Component;
import org.jmodelica.icons.Connection;
import org.jmodelica.icons.Connector;
import org.jmodelica.icons.Diagram;
import org.jmodelica.icons.primitives.Ellipse;
import org.jmodelica.icons.primitives.Line;
import org.jmodelica.icons.primitives.Polygon;
import org.jmodelica.icons.primitives.Rectangle;
import org.jmodelica.icons.primitives.Text;
import org.jmodelica.ide.graphical.editparts.primitives.EllipseEditPart;
import org.jmodelica.ide.graphical.editparts.primitives.LineEditPart;
import org.jmodelica.ide.graphical.editparts.primitives.PolygonEditPart;
import org.jmodelica.ide.graphical.editparts.primitives.RectangleEditPart;
import org.jmodelica.ide.graphical.editparts.primitives.TextEditPart;
import org.jmodelica.ide.graphical.util.ASTResourceProvider;


public class EditPartFactory implements org.eclipse.gef.EditPartFactory {
	
	private ASTResourceProvider provider;
	
	public EditPartFactory(ASTResourceProvider provider) {
		this.provider = provider;
	}

	@Override
	public EditPart createEditPart(EditPart context, Object model) {
		if (model instanceof Diagram) {
			return new DiagramEditPart((Diagram)model, provider);
		}
		if (model instanceof Connector) {
			return new ConnectorEditPart((Connector)model);
		}
		if (model instanceof Component) {
			return new ComponentEditPart((Component)model);
		}
		if (model instanceof Polygon) {
			return new PolygonEditPart((Polygon)model);
		}
		if (model instanceof Rectangle) {
			return new RectangleEditPart((Rectangle)model);
		}
		if (model instanceof Connection) {
			return new ConnectionEditPart((Connection)model);
		}
		if (model instanceof Line) {
			return new LineEditPart((Line)model);
		}
		if (model instanceof Text) {
			return new TextEditPart((Text)model);
		}
		if (model instanceof Ellipse) {
			return new EllipseEditPart((Ellipse)model);
		}
		return null;
	}
	
}
