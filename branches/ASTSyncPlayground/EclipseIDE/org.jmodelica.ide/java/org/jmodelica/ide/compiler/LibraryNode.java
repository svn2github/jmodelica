package org.jmodelica.ide.compiler;

import java.util.ArrayList;

import org.jastadd.ed.core.model.IASTChangeListener;

public class LibraryNode {
	private ArrayList<LibraryNode> children = new ArrayList<LibraryNode>();
	private String id;
	private ArrayList<IASTChangeListener> listeners = new ArrayList<IASTChangeListener>();

	public LibraryNode(String id) {
		this.id = id;
	}

	public void addChild(LibraryNode node) {
		this.children.add(node);
	}

	public String getId() {
		return id;
	}

	public ArrayList<LibraryNode> getChildren() {
		return children;
	}

	public ArrayList<IASTChangeListener> getListeners() {
		return listeners; //TODO synchronize
	}

	public void addListener(IASTChangeListener listener) {
		listeners.add(listener);//TODO synchronize
	}
}
