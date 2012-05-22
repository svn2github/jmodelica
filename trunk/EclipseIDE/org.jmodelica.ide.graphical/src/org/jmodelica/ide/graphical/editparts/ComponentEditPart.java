package org.jmodelica.ide.graphical.editparts;


import org.eclipse.gef.EditPart;
import org.eclipse.gef.EditPartListener;
import org.eclipse.gef.EditPolicy;
import org.eclipse.gef.GraphicalEditPart;
import org.eclipse.gef.Request;
import org.eclipse.gef.commands.Command;
import org.eclipse.gef.requests.GroupRequest;
import org.eclipse.ui.views.properties.IPropertyDescriptor;
import org.eclipse.ui.views.properties.IPropertySource;
import org.eclipse.ui.views.properties.PropertyDescriptor;
import org.eclipse.ui.views.properties.TextPropertyDescriptor;
import org.jmodelica.icons.Component;
import org.jmodelica.icons.Layer;
import org.jmodelica.icons.Observable;
import org.jmodelica.icons.coord.Extent;
import org.jmodelica.icons.coord.Point;
import org.jmodelica.icons.coord.Transformation;
import org.jmodelica.icons.primitives.Color;
import org.jmodelica.icons.primitives.Line;
import org.jmodelica.ide.graphical.commands.DeleteComponentCommand;
import org.jmodelica.ide.graphical.commands.RotateComponentCommand;
import org.jmodelica.ide.graphical.editparts.primitives.AbstractPolygonEditPart;
import org.jmodelica.ide.graphical.editparts.primitives.GraphicEditPart;
import org.jmodelica.ide.graphical.editparts.primitives.TextEditPart;
import org.jmodelica.ide.graphical.graphics.IconLayer;
import org.jmodelica.ide.graphical.util.Converter;
import org.jmodelica.ide.graphical.util.Transform;



public class ComponentEditPart extends AbstractIconEditPart implements EditPartListener, IPropertySource{

	private Component component;

	public ComponentEditPart(Component component) {
		super(component.getIcon());
		this.component = component;
		this.addEditPartListener(this);
	}

	@Override
	public void deactivate() {
		super.deactivate();
		component.getPlacement().getTransformation().removeObserver(this);
	}

	@Override
	public void activate() {
		super.activate();
		component.getPlacement().getTransformation().addObserver(this);
		getModel().addObserver(this);
	}

	@Override
	protected IconLayer createFigure() {
		return new IconLayer();
	}

	@Override
	public IconLayer getFigure() {
		return (IconLayer) super.getFigure();
	}

	@Override
	protected void createEditPolicies() {
		installEditPolicy(EditPolicy.COMPONENT_ROLE, new RotationEditPolicy() {

			@Override
			protected Command createRotateCommand(Request request, double angle) {
				return new RotateComponentCommand(getComponent(), angle);
			}

			@Override
			protected Command createDeleteCommand(GroupRequest deleteRequest) {
				return new DeleteComponentCommand(getParent().getModel(), getComponent());
			}
		});
	}

	@Override
	protected void refreshVisuals() {
		if (getModel().getLayer() == Layer.NO_LAYER) {
			getFigure().setVisible(false);
			return;
		}
		invalidateTransform();
		for (Object part : getChildren()) {
			if (part instanceof GraphicEditPart)
				((GraphicEditPart) part).refresh();
			if (part instanceof ComponentEditPart)
				((ComponentEditPart) part).refreshVisuals();

		}
		getFigure().setDeclaredBounds(Converter.convert(getComponentTransform().transform(Transform.yInverter.transform(getComponent().getPlacement().getTransformation().getExtent()))));
		getFigure().figureMoved(null);
		((GraphicalEditPart) getParent()).setLayoutConstraint(this, getFigure(), getFigure().getBounds());

	}

	public Component getComponent() {
		return component;
	}

	@Override
	public AbstractIconEditPart getParent() {
		return (AbstractIconEditPart) super.getParent();
	}

	public Transform getParentTransform() {
		if (getParent() instanceof AbstractIconEditPart) {
			return ((AbstractIconEditPart) getParent()).getTransform();
		}
		return null;
	}

	private Transform componentTransform;

	public Transform getComponentTransform() {
		// Make sure it's calculated and up to date.
		getTransform();
		return componentTransform.clone();
	}

	@Override
	protected Transform calculateTransform() {
		// Based on org.jmodelica.icons.drawing.AWTIconDrawer.setTransformation()
		Transformation compTransformation = getComponent().getPlacement().getTransformation();
		Extent transformationExtent = compTransformation.getExtent();
		Extent componentExtent = getModel().getLayer().getCoordinateSystem().getExtent();
		Transform transform = getParentTransform().clone();
		transform.translate(Transform.yInverter.transform(compTransformation.getOrigin()));
		componentTransform = transform.clone();
		transform.translate(Transform.yInverter.transform(transformationExtent.getMiddle()));

		if (transformationExtent.getP2().getX() < transformationExtent.getP1().getX()) {
			transform.scale(-1.0, 1.0);
			componentTransform.scale(-1.0, 1.0);
		}
		if (transformationExtent.getP2().getY() < transformationExtent.getP1().getY()) {
			transform.scale(1.0, -1.0);
			componentTransform.scale(1.0, -1.0);
		}

		double angle = -compTransformation.getRotation() * Math.PI / 180;
		transform.rotate(angle);
		componentTransform.rotate(angle);

		transform.scale(transformationExtent.getWidth() / componentExtent.getWidth(), transformationExtent.getHeight() / componentExtent.getHeight());

		return transform;
	}

	public Extent declaredExtent() {
		Extent e = getComponent().getPlacement().getTransformation().getExtent();
		Point o = getComponent().getPlacement().getTransformation().getOrigin();
		return new Extent(new Point(o.getX() + e.getP1().getX(), o.getY() + e.getP1().getY()), new Point(o.getX() + e.getP2().getX(), o.getY() + e.getP2().getY()));
	}

	@Override
	public void update(Observable o, Object flag, Object additionalInfo) {
		if (o == getComponent().getPlacement().getTransformation() && (flag == Transformation.ORIGIN_UPDATED))
			refreshVisuals();
		else if (o == getComponent().getPlacement().getTransformation() && (flag == Transformation.EXTENT_UPDATED))
			refreshVisuals();
		else if (o == getComponent().getPlacement().getTransformation() && (flag == Transformation.ROTATION_CHANGED))
			refreshVisuals();
		else
			super.update(o, flag, additionalInfo);
	}

	@Override
	public void childAdded(EditPart child, int index) {
		if (child instanceof TextEditPart) {
			if (((TextEditPart) child).getTextString().equals("%name"))
				((TextEditPart) child).setOverrideTextString(getComponent().getComponentName());
		}
	}

	@Override
	public void partActivated(EditPart editpart) {}

	@Override
	public void partDeactivated(EditPart editpart) {}

	@Override
	public void removingChild(EditPart child, int index) {}

	@Override
	public void selectedStateChanged(EditPart editpart) {}

	protected Color calculateConnectionColor() {
		for (Object o : getChildren()) {
			Color c = Line.DEFAULT_COLOR;
			if (o instanceof AbstractPolygonEditPart) {
				c = ((AbstractPolygonEditPart) o).getModel().getLineColor();
			} else if (o instanceof ComponentEditPart) {
				c = ((ComponentEditPart) o).calculateConnectionColor();
			}
			if (c != Line.DEFAULT_COLOR)
				return c;
		}
		return Line.DEFAULT_COLOR;
	}

	@Override
	public Object getEditableValue() {
		System.out.println("getEditableValue");
		return this;
	}

	@Override
	public IPropertyDescriptor[] getPropertyDescriptors() {
		return new IPropertyDescriptor[] {
				new TextPropertyDescriptor("componentName", "Component Name"),
				new PropertyDescriptor("readOnly", "Read only")
		};
	}

	@Override
	public Object getPropertyValue(Object id) {
		if ("componentName".equals(id))
			return getComponent().getComponentName();
		else if ("readOnly".equals(id))
			return "value";
		else
			return null;
	}

	@Override
	public boolean isPropertySet(Object id) {
		System.out.println("isPropertySet");
		return false;
	}

	@Override
	public void resetPropertyValue(Object id) {
		System.out.println("resetPropertyValue");
	}

	@Override
	public void setPropertyValue(Object id, Object value) {
		System.out.println("setPropertyValue");
	}

}
