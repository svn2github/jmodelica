package org.jmodelica.util;
import java.util.ArrayList;

public class Eq {

	private String name;
	private ArrayList<Var> variables = new ArrayList<Var>();
	private Var matching = null;
    private boolean visited = false;
    private int layer = 1000000;
    private String description;
	
	public Eq(String name,String description) {
		this.name = name;
		this.description = description;
	}
	
	public void addVariable(Var v) {
		variables.add(v);
	}

	public void reset() {
		setMatching(null);
		setVisited(false);
		setLayer(1000000);
//		for (Var v : getVariables()) {
//			v.reset();
//		}
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

	public ArrayList<Var> getVariables() {
		return variables;
	}

	public Var getMatching() {
		return matching;
	}

	public void setMatching(Var matching) {
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

	public String getDescription() {
		return description;
	}

	public void setDescription(String description) {
		this.description = description;
	}	
	
	public String toString() {
		return getName();
	}

}
