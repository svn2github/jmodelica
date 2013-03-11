package org.jmodelica.ide.compiler;

import java.util.ArrayList;

import org.jastadd.ed.core.model.IASTChangeListener;

public class LibraryNode {
	private ArrayList<LibraryNode> children = new ArrayList<LibraryNode>();
	// Represents the index of this node at its parent in source AST.
	private Integer index;
	private ArrayList<ListenerObject> listeners = new ArrayList<ListenerObject>();

	public LibraryNode(Integer index) {
		this.index = index;
	}

	public void addChild(LibraryNode node) {
		this.children.add(node);
	}

	public Integer getId() {
		return index;
	}

	public ArrayList<LibraryNode> getChildren() {
		return children;
	}

	public ArrayList<ListenerObject> getListeners() {
		return listeners; // TODO synchronize
	}

	public void addListener(IASTChangeListener listener, int listenerType) {
		listeners.add(new ListenerObject(listener, listenerType));// TODO
																	// synchronize
	}

	public void decreaseIndex() {
		this.index--;
	}
}