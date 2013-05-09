package org.jmodelica.ide.graphical.proxy;

import java.util.Stack;

import org.eclipse.jface.viewers.CellEditor;
import org.eclipse.jface.viewers.ILabelProvider;
import org.eclipse.jface.viewers.TextCellEditor;
import org.eclipse.swt.widgets.Composite;
import org.eclipse.ui.views.properties.IPropertyDescriptor;

public class ParameterProxy implements IPropertyDescriptor {

	private static final String CATEGORY = "Parameters";

	private ComponentProxy owner;
	private String name;

	private String value;

	public ParameterProxy(String name, ComponentProxy owner, String value) {
		this.name = name;
		this.owner = owner;
		this.value = value;
	}

	@Override
	public CellEditor createPropertyEditor(Composite parent) {
		return new TextCellEditor(parent);
	}

	@Override
	public String getCategory() {
		return CATEGORY;
	}

	@Override
	public String getDescription() {
		return null;
	}

	@Override
	public String getDisplayName() {
		return name;
	}

	@Override
	public String[] getFilterFlags() {
		return null;
	}

	@Override
	public Object getHelpContextIds() {
		return null;
	}

	@Override
	public Object getId() {
		return this;
	}

	@Override
	public ILabelProvider getLabelProvider() {
		return null;
	}

	@Override
	public boolean isCompatibleWith(IPropertyDescriptor anotherProperty) {
		return false;
	}

	public void setValue(String value) {
		this.value = value;
		Stack<String> path = new Stack<String>();
		path.push(name);
		owner.setParameterValue(null, path, value);
	}

	public String getValue() {
		return value;
	}
}