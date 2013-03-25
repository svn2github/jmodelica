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

	public ParameterProxy(String name, ComponentProxy owner,String value) {
		this.name = name;
		this.owner = owner;
		this.value=value;
	}

	/*
	 * protected InstPrimitive getInstPrimitive() { return (InstPrimitive)
	 * owner.getInstComponentDecl(name); }
	 */// TODO NOT NEEDED, DUNNO?

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
		// TODO Auto-generated method stub
		return null;
	}

	@Override
	public String getDisplayName() {
		return name;
	}

	@Override
	public String[] getFilterFlags() {
		// TODO Auto-generated method stub
		return null;
	}

	@Override
	public Object getHelpContextIds() {
		// TODO Auto-generated method stub
		return null;
	}

	@Override
	public Object getId() {
		return this;
	}

	@Override
	public ILabelProvider getLabelProvider() {
		// TODO Auto-generated method stub
		return null;
	}

	@Override
	public boolean isCompatibleWith(IPropertyDescriptor anotherProperty) {
		// TODO Auto-generated method stub
		return false;
	}

	public void setValue(String value) {
		Stack<String> path = new Stack<String>();
		path.push(name);
		owner.setParameterValue(path, value);
	}

	public String getValue() {
		//InstComponentDecl icd;
		//icd.syncLookupParameterValue(parameter)
		//return owner.getComponentDecl().syncLookupParameterValue(name);
		return value;
	}

}
