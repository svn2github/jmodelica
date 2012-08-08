package org.jmodelica.ide.graphical.edit.parts;

import java.beans.PropertyChangeEvent;
import java.beans.PropertyChangeListener;

import org.eclipse.draw2d.IFigure;
import org.eclipse.draw2d.XYAnchor;
import org.eclipse.draw2d.geometry.Point;
import org.eclipse.gef.ConnectionEditPart;
import org.eclipse.gef.EditPart;
import org.eclipse.gef.EditPolicy;
import org.eclipse.gef.LayerConstants;
import org.eclipse.swt.SWT;
import org.jmodelica.icons.Observable;
import org.jmodelica.icons.primitives.Line;
import org.jmodelica.icons.primitives.Types.LinePattern;
import org.jmodelica.ide.graphical.edit.policies.ConnectionBendpointPolicy;
import org.jmodelica.ide.graphical.edit.policies.ConnectionPolicy;
import org.jmodelica.ide.graphical.graphics.ConnectionFigure;
import org.jmodelica.ide.graphical.proxy.ConnectionProxy;
import org.jmodelica.ide.graphical.util.Converter;
import org.jmodelica.ide.graphical.util.Transform;

public class ConnectionPart extends AbstractModelicaPart implements ConnectionEditPart, PropertyChangeListener {

	private ConnectorPart sourcePart;
	private ConnectorPart targetPart;
	private boolean updatingFigurePoints = false;

	public ConnectionPart(ConnectionProxy model) {
		super(model);
	}
	
	@Override
	public void activate() {
		super.activate();
		getLine().addObserver(this);
	}
	
	@Override
	public void deactivate() {
		getLine().removeObserver(this);
		super.deactivate();
	}

	@Override
	public ConnectionProxy getModel() {
		return (ConnectionProxy) super.getModel();
	}

	@Override
	public AbstractModelicaPart getParent() {
		return (AbstractModelicaPart) super.getParent();
	}

	public Line getLine() {
		return getModel().getLine();
	}

	@Override
	protected IFigure createFigure() {
		ConnectionFigure cf = new ConnectionFigure();
		cf.addPropertyChangeListener(ConnectionFigure.REAL_POINTS_CHANGED, this);
		return cf;
	}

	@Override
	public ConnectionFigure getFigure() {
		return (ConnectionFigure) super.getFigure();
	}

	@Override
	public void setParent(EditPart parent) {
		while (parent != null && !(parent instanceof DiagramPart)) {
			parent = parent.getParent();
		}
		boolean wasNull = getParent() == null;
		boolean becomingNull = parent == null;
		if (becomingNull && !wasNull)
			removeNotify();
		super.setParent(parent);
		if (wasNull && !becomingNull)
			addNotify();
	}

	@Override
	public void refresh() {
		refreshAnchors();
		super.refresh();
		getFigure().layout();
	}

	private void refreshAnchors() {
		if (getSource() == null)
			getFigure().setSourceAnchor(new XYAnchor(new Point(10, 10)));
		else
			getFigure().setSourceAnchor(getSource().getSourceConnectionAnchor(this));

		if (getTarget() == null)
			getFigure().setTargetAnchor(new XYAnchor(new Point(100, 100)));
		else
			getFigure().setTargetAnchor(getTarget().getTargetConnectionAnchor(this));
	}

	@Override
	public void addNotify() {
		updateArrows();
		updateColor();
		updatePattern();
		updatePoints();
		updateSmooth();
		updateThickness();
		getLayer(LayerConstants.CONNECTION_LAYER).add(getFigure());
		super.addNotify();
	}

	@Override
	public void removeNotify() {
		getLayer(LayerConstants.CONNECTION_LAYER).remove(getFigure());
		getFigure().setSourceAnchor(null);
		getFigure().setTargetAnchor(null);
		super.removeNotify();
	}

	@Override
	public ConnectorPart getSource() {
		return sourcePart;
	}

	@Override
	public void setSource(EditPart source) {
		if (source == sourcePart)
			return;
		if (!(source instanceof ConnectorPart))
			source = null;
		sourcePart = (ConnectorPart) source;
		if (sourcePart != null) {
			setParent(sourcePart);
		} else if (getTarget() == null) {
			setParent(null);
		}
		if (sourcePart != null && getTarget() != null)
			refresh();
	}

	@Override
	public ConnectorPart getTarget() {
		return targetPart;
	}

	@Override
	public void setTarget(EditPart target) {
		if (target == targetPart)
			return;
		if (!(target instanceof ConnectorPart))
			target = null;
		targetPart = (ConnectorPart) target;
		if (targetPart != null) {
			setParent(targetPart);
		} else if (getSource() == null) {
			setParent(null);
		}
		if (targetPart != null && getSource() != null)
			refresh();
	}

	@Override
	public void propertyChange(PropertyChangeEvent arg) {
		if (arg.getPropertyName() == ConnectionFigure.REAL_POINTS_CHANGED && !updatingFigurePoints) {
			getLine().setPoints(Transform.yInverter.transform(getTransform().getInverseTransfrom().transform(Converter.convert(getFigure().getRealPoints()))));
		}
	}

	@Override
	protected void createEditPolicies() {
		installEditPolicy(EditPolicy.CONNECTION_BENDPOINTS_ROLE, new ConnectionBendpointPolicy(this));
		installEditPolicy(EditPolicy.CONNECTION_ROLE, new ConnectionPolicy(this));
	}

	@Override
	protected Transform calculateTransform() {
		return getParent().getTransform();
	}

	@Override
	protected void transformInvalid() {}

	@Override
	public void update(Observable o, Object flag, Object additionalInfo) {
		if (o == getLine()) {
			if (flag == Line.ARROW_SIZE_UPDATED || flag == Line.ARROW_UPDATED)
				updateArrows();
			else if (flag == Line.COLOR_UPDATE)
				updateColor();
			else if (flag == Line.LINE_PATTERN_UPDATED)
				updatePattern();
			else if (flag == Line.POINTS_UPDATED)
				updatePoints();
			else if (flag == Line.SMOOTH_UPDATED)
				updateSmooth();
			else if (flag == Line.THICKNESS_UPDATE)
				updateThickness();
		}
		super.update(o, flag, additionalInfo);
	}

	private void updateArrows() {
		// TODO Implement arrows
	}

	protected void updateColor() {
		getFigure().setForegroundColor(Converter.convert(getLine().getColor()));
	}

	private void updatePattern() {
		if (getLine().getLinePattern() == LinePattern.NONE) {
			getFigure().setVisible(false);
		} else {
			getFigure().setVisible(true);
			if (getLine().getLinePattern() == LinePattern.SOLID) {
				getFigure().setLineStyle(SWT.LINE_SOLID);
			} else {
				getFigure().setLineStyle(SWT.LINE_CUSTOM);
				getFigure().setLineDash(getLine().getLinePattern().getDash());
			}
		}
	}

	private void updatePoints() {
		updatingFigurePoints = true;
		getFigure().setRealPoints(Converter.convert(getTransform().transform(Transform.yInverter.transform(getLine().getPoints()))));
		refresh();
		updatingFigurePoints = false;
	}

	private void updateSmooth() {
		// TODO Implement smoothnes
	}

	private void updateThickness() {
		getFigure().setLineWidthFloat((float) (getTransform().getScale() * getLine().getThickness()));
	}
}
