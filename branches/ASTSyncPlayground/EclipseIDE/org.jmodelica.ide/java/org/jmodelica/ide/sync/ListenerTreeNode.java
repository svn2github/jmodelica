package org.jmodelica.ide.sync;

import java.util.ArrayList;

import org.jastadd.ed.core.model.IASTChangeListener;

public class ListenerTreeNode {
	private ArrayList<ListenerTreeNode> children = new ArrayList<ListenerTreeNode>();
	private String id;
	private ArrayList<ListenerObject> listeners = new ArrayList<ListenerObject>();

	public ListenerTreeNode(String id) {
		this.id = id;
	}

	public void addChild(ListenerTreeNode node) {
		this.children.add(node);
	}

	public String getId() {
		return id;
	}

	public ArrayList<ListenerTreeNode> getChildren() {
		return children;
	}

	public ArrayList<ListenerObject> getListeners() {
		return listeners;
	}

	public void addListener(ListenerObject list) {
		listeners.add(list);
	}

	public boolean removeListener(IASTChangeListener listener) {
		for (ListenerObject obj : listeners) {
			if (obj.equals(listener)){
				listeners.remove(obj);
				return true;
			}
		}
		return false;
	}
}