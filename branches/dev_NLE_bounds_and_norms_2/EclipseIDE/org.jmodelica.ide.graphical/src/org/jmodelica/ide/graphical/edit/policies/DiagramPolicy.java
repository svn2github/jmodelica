package org.jmodelica.ide.graphical.edit.policies;

import org.eclipse.draw2d.geometry.Rectangle;
import org.eclipse.gef.EditPart;
import org.eclipse.gef.Request;
import org.eclipse.gef.RequestConstants;
import org.eclipse.gef.commands.Command;
import org.eclipse.gef.editpolicies.XYLayoutEditPolicy;
import org.eclipse.gef.requests.ChangeBoundsRequest;
import org.eclipse.gef.requests.CreateRequest;
import org.jmodelica.icons.coord.Extent;
import org.jmodelica.icons.coord.Placement;
import org.jmodelica.icons.coord.Point;
import org.jmodelica.icons.coord.Transformation;
import org.jmodelica.ide.graphical.commands.AddComponentCommand;
import org.jmodelica.ide.graphical.commands.MoveComponentCommand;
import org.jmodelica.ide.graphical.commands.ResizeComponentCommand;
import org.jmodelica.ide.graphical.edit.NativeDropRequest;
import org.jmodelica.ide.graphical.edit.parts.ComponentPart;
import org.jmodelica.ide.graphical.edit.parts.DiagramPart;
import org.jmodelica.ide.graphical.proxy.ComponentProxy;
import org.jmodelica.ide.graphical.util.Converter;
import org.jmodelica.ide.graphical.util.Transform;

public class DiagramPolicy extends XYLayoutEditPolicy {

	private DiagramPart diagram;

	public DiagramPolicy(DiagramPart diagram) {
		this.diagram = diagram;
	}

	@Override
	public Command getCommand(Request request) {
		if (NativeDropRequest.ID.equals(request.getType())) {
			NativeDropRequest ndr = (NativeDropRequest) request;
			org.eclipse.draw2d.geometry.Point draw2dOrigin = ndr.getPoint().getCopy();
			diagram.getFigure().translateToRelative(draw2dOrigin);
			Point origin = Transform.yInverter.transform(diagram.getTransform().getInverseTransfrom().transform(Converter.convert(draw2dOrigin)));
			Placement placement = new Placement(new Transformation(new Extent(new Point(-10, -10), new Point(10, 10)), origin));
			return new AddComponentCommand(diagram.getModel(), (String) ndr.getData(), placement);
		}
		return super.getCommand(request);
	}

	@Override
	public EditPart getTargetEditPart(Request request) {
		if (NativeDropRequest.ID.equals(request.getType()))
			return diagram;
		return super.getTargetEditPart(request);
	}

	@Override
	protected Command createChangeConstraintCommand(final ChangeBoundsRequest request, EditPart child, final Object constraint) {
		if (child instanceof ComponentPart && constraint instanceof Rectangle) {
			final ComponentPart componentPart = (ComponentPart) child;
			final ComponentProxy componentModel = componentPart.getModel();
			if (RequestConstants.REQ_RESIZE_CHILDREN.equals(request.getType())) {
				return new ResizeComponentCommand(componentModel) {
					@Override
					protected Extent calculateNewExtent() {
						Transform t = diagram.getTransform();
						t.translate(componentModel.getPlacement().getTransformation().getOrigin().getX(), -componentModel.getPlacement().getTransformation().getOrigin().getY());
						t = t.getInverseTransfrom();

						Rectangle newBounds = request.getTransformedRectangle(componentPart.getFigure().getHandleBounds());
						Extent newExtent = Transform.yInverter.transform(t.transform(Converter.convert(newBounds)));
						return newExtent;
					}

				};
			}
			if (RequestConstants.REQ_MOVE_CHILDREN.equals(request.getType())) {
				return new MoveComponentCommand(componentModel) {
					@Override
					protected Point calculateNewOrigin() {
						Transform t = diagram.getTransform().getInverseTransfrom();

						Point newActualOrigin = Transform.yInverter.transform(t.transform(Converter.convert(((Rectangle) constraint).getTopLeft())));
						Point oldActualOrigin = Transform.yInverter.transform(t.transform(Converter.convert((componentPart.getFigure().getBounds()).getTopLeft())));
						Point oldOrigin = componentModel.getPlacement().getTransformation().getOrigin();

						double deltaX = newActualOrigin.getX() - oldActualOrigin.getX();
						double deltaY = newActualOrigin.getY() - oldActualOrigin.getY();

						return new Point(oldOrigin.getX() + deltaX, oldOrigin.getY() + deltaY);
					}
				};
			}
		}
		return super.createChangeConstraintCommand(request, child, constraint);
	}

	@Override
	protected Command getCreateCommand(CreateRequest request) {
		return null; // Not possible to create components this way.
	}

}
