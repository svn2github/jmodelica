package org.jmodelica.ide.graphical.edit.parts;

import java.util.List;

import org.jmodelica.icons.Icon;
import org.jmodelica.icons.Layer;
import org.jmodelica.icons.Observable;
import org.jmodelica.icons.Observer;
import org.jmodelica.ide.graphical.proxy.AbstractNodeProxy;
import org.jmodelica.ide.graphical.util.ASTNodeResourceProvider;
import org.jmodelica.modelica.compiler.InstExtends;
import org.jmodelica.modelica.compiler.InstNode;

public abstract class AbstractInstNodePart extends AbstractModelicaPart implements ASTNodeResourceProvider, Observer {

	public AbstractInstNodePart(AbstractNodeProxy anp) {
		super(anp);
	}

	@Override
	public AbstractNodeProxy getModel() {
		return (AbstractNodeProxy) super.getModel();
	}

	@Override
	protected void transformInvalid() {
		refreshVisuals();
	}

	protected static void collectGraphics(InstNode node, List<Object> graphics, boolean inDiagram) {
		Icon icon = inDiagram ? node.diagram() : node.icon();
		if (icon.getLayer() != Layer.NO_LAYER)
			graphics.addAll(icon.getLayer().getGraphics());
		for (InstExtends ie : node.getInstExtendss()) {
			collectGraphics(ie, graphics, inDiagram);
		}
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
		if (!isActive())
			o.removeObserver(this);
		super.update(o, flag, additionalInfo);
	}
}
