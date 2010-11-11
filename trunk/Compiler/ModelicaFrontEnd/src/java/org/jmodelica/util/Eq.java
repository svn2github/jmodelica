/*
    Copyright (C) 2010 Modelon AB

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, version 3 of the License.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

package org.jmodelica.util;
import java.util.ArrayList;
import java.util.Iterator;

public class Eq {

	private String name;
	private ArrayList<Var> variables = new ArrayList<Var>();
	private Iterator<Var> varIterator;
	private Var matching = null;
    private boolean visited = false;
    private int layer = 1000000;
    private String description;
    private int id = -1;

	private int tarjanNbr = 0;
    private int tarjanLowLink = 0;
	
	public Eq(String name,String description,int id) {
		this.name = name;
		this.description = description;
		this.id = id;
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
	
	public void tarjanReset() {
		setTarjanLowLink(0);
		setTarjanNbr(0);
		resetVariableIterator();
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
	 
	
    public int getId() {
		return id;
	}

	public void setId(int id) {
		this.id = id;
	}

	public int getTarjanNbr() {
		return tarjanNbr;
	}

	public void setTarjanNbr(int tarjanNbr) {
		this.tarjanNbr = tarjanNbr;
	}

	public int getTarjanLowLink() {
		return tarjanLowLink;
	}

	public void setTarjanLowLink(int tarjanLowLink) {
		this.tarjanLowLink = tarjanLowLink;
	}
	
    public void resetVariableIterator() {
        varIterator = variables.iterator();
    }

    public Var getNextVariable() {
        if (varIterator == null) {
            resetVariableIterator();
        }

        if (!varIterator.hasNext()) {
            return null;
        }

        return varIterator.next();
    }
	
	public String toString() {
		return getName();
	}

}
