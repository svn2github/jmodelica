package org.jmodelica.util;

public class Var {

	private String name;
	private String description;
	private Eq matching = null;
	private boolean visited = false;
	private int layer = 1000000;
	
	public Var(String name, String description) {
		this.name = name;
		this.description = description;
	}

	public void reset() {
		setMatching(null);
		setVisited(false);
		setLayer(1000000);
	}

	public void lightReset() {
		setVisited(false);
		setLayer(1000000);
	}
	
	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
	}

	public String getDescription() {
		return description;
	}

	public void setDescription(String description) {
		this.description = description;
	}

	public Eq getMatching() {
		return matching;
	}

	public void setMatching(Eq matching) {
		this.matching = matching;
	}

	public boolean isVisited() {
		return visited;
	}

	public void setVisited(boolean visited) {
		this.visited = visited;
	}

	public int getLayer() {
		return layer;
	}

	public void setLayer(int layer) {
		this.layer = layer;
	}
	
	public String toString() {
		return getName();
	}
	
}
