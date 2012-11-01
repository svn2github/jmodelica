package org.jmodelica.ide.graphical.edit;

import org.eclipse.gef.EditPart;
import org.jmodelica.icons.primitives.Ellipse;
import org.jmodelica.icons.primitives.Line;
import org.jmodelica.icons.primitives.Polygon;
import org.jmodelica.icons.primitives.Rectangle;
import org.jmodelica.icons.primitives.Text;
import org.jmodelica.ide.graphical.edit.parts.ComponentPart;
import org.jmodelica.ide.graphical.edit.parts.ConnectionPart;
import org.jmodelica.ide.graphical.edit.parts.ConnectorPart;
import org.jmodelica.ide.graphical.edit.parts.DiagramPart;
import org.jmodelica.ide.graphical.edit.parts.primitives.EllipseEditPart;
import org.jmodelica.ide.graphical.edit.parts.primitives.LineEditPart;
import org.jmodelica.ide.graphical.edit.parts.primitives.PolygonEditPart;
import org.jmodelica.ide.graphical.edit.parts.primitives.RectangleEditPart;
import org.jmodelica.ide.graphical.edit.parts.primitives.TextEditPart;
import org.jmodelica.ide.graphical.proxy.AbstractDiagramProxy;
import org.jmodelica.ide.graphical.proxy.ComponentProxy;
import org.jmodelica.ide.graphical.proxy.ConnectionProxy;
import org.jmodelica.ide.graphical.proxy.ConnectorProxy;

public class EditPartFactory implements org.eclipse.gef.EditPartFactory {

	@Override
	public EditPart createEditPart(EditPart context, Object model) {

		if (model instanceof AbstractDiagramProxy)
			return new DiagramPart((AbstractDiagramProxy) model);
		if (model instanceof ConnectorProxy)
			return new ConnectorPart((ConnectorProxy) model);
		if (model instanceof ComponentProxy)
			return new ComponentPart((ComponentProxy) model);
		if (model instanceof ConnectionProxy)
			return new ConnectionPart((ConnectionProxy) model);
		if (model instanceof Polygon)
			return new PolygonEditPart((Polygon) model);
		if (model instanceof Rectangle)
			return new RectangleEditPart((Rectangle) model);
		if (model instanceof Line)
			return new LineEditPart((Line) model);
		if (model instanceof Text)
			return new TextEditPart((Text) model);
		if (model instanceof Ellipse)
			return new EllipseEditPart((Ellipse) model);
		return null;
	}

}
