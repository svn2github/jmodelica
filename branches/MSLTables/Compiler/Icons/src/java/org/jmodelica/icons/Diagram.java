package org.jmodelica.icons;

import java.util.HashSet;
import java.util.Set;

import org.jmodelica.icons.drawing.IconConstants.Context;

public class Diagram extends Icon implements Observer {
	
	public static final Object CONNECTION_ADDED = new Object();
	public static final Object CONNECTION_REMOVED = new Object();
	
	public static Diagram NULL_DIAGRAM = new Diagram();
	
	private Set<Connection> activeConnections = new HashSet<Connection>();
	
	private DiagramFactory factory;
	
	public Diagram(String className, Layer layer, Context context, DiagramFactory factory) {
		super(className, layer, context);
		this.factory = factory;
		addObserver(this);
	}
	
	public Diagram(String className, Layer layer, Context context) {
		this(className, layer, context, null);
	}
	
	private Diagram() {
		super("", Layer.NO_LAYER, null);
	}
	
	private void startObserving(Icon icon) {
		icon.addObserver(this);
		for (Icon superClass : icon.getSuperclasses())
			startObserving(superClass);
		for (Component subComponent : icon.getSubcomponents())
			startObserving(subComponent);
	}
	
	private void startObserving(Component component) {
		if (component instanceof Connector) {
			component.addObserver(this);
		} else {
			startObserving(component.getIcon());
		}
	}
	
	private void stopObserving(Icon icon) {
		icon.addObserver(this);
		for (Icon superClass : icon.getSuperclasses())
			stopObserving(superClass);
		for (Component subComponent : icon.getSubcomponents())
			stopObserving(subComponent);
	}
	
	private void stopObserving(Component component) {
		if (component instanceof Connector) {
			component.addObserver(this);
		} else {
			stopObserving(component.getIcon());
		}
	}
	
	@Override
	public void update(Observable o, Object flag, Object additionalInfo) {
		if (o instanceof Connection) {
			if (flag == Connection.CONNECTED && activeConnections.add((Connection) o)) {
				notifyObservers(CONNECTION_ADDED, o);
			} else if (flag == Connection.DISCONNECTED && activeConnections.remove(o)) {
				notifyObservers(CONNECTION_REMOVED, o);
			}
		} else if (o instanceof Connector) {
			if (flag == Connector.SOURCE_ADDED || flag == Connector.TARGET_ADDED) {
				((Connection) additionalInfo).addObserver(this);
			}
		} else if (o instanceof Icon) {
			if (flag == Icon.SUBCOMPONENT_ADDED) {
				startObserving((Component) additionalInfo);
			} else if (flag == Icon.SUBCOMPONENT_REMOVED) {
				stopObserving((Component) additionalInfo);
			} else if (flag == Icon.SUPERCLASS_ADDED) {
				startObserving((Icon) additionalInfo);
			} else if (flag == Icon.SUPERCLASS_REMOVED) {
				stopObserving((Icon) additionalInfo);
			}
		}
	}
	
	public DiagramFactory getFactory() {
		return factory;
	}

}
