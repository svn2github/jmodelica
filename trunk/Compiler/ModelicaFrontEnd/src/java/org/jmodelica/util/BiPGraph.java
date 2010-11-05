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
import java.util.LinkedHashMap;
import java.util.LinkedHashSet;
import java.util.LinkedList;
import java.util.ListIterator;
import java.util.Random;
import java.util.Stack;

public class BiPGraph {

	private String name;
	private String description;
	
	private ArrayList<Eq> equations = new ArrayList<Eq>();
	private LinkedHashMap<String,Var> variableMap = new LinkedHashMap<String,Var>();
	private LinkedHashMap<String,Eq> equationMap = new LinkedHashMap<String,Eq>();
	
	public BiPGraph(String name, String description) {
		this.name = name;
		this.description = description;
	}

	public Eq getEquation(String name) {
		return equationMap.get(name);
	}
	
	public Eq addEquation(String name, String description, int id) {
		Eq e = equationMap.get(name);
		if (e==null) {
			e = new Eq(name,description,id);
			equations.add(e);
			equationMap.put(name,e);
		}
		return e;
	}
	
	public Var addVariable(String name, String description) {
		Var v = variableMap.get(name);
		if (v==null) {
			v = new Var(name,description);
			variableMap.put(name,v);
		}	
		return v;
	}
	
	public Var getVariable(String name) {
		return variableMap.get(name);
	}
	
	public boolean addEdge(String equationName, String variableName) {
		Eq e = equationMap.get(equationName);
		Var v = variableMap.get(variableName);
		if (v==null || e==null) {
			return false;
		}
		if (e.getVariables().contains(v)) {
			return false;
		}
		e.addVariable(v);
		return true;
	}

	public boolean addEdge(Eq e, Var v) {
		return addEdge(e.getName(),v.getName());
	}
	
	public void greedyMatching() {
		for (Eq e : getEquations()) {
			for (Var v : e.getVariables()) {
				if (v.getMatching()==null) {
					v.setMatching(e);
					e.setMatching(v);
					break;
				}
			}
		}
	}
	
	public ArrayList<LinkedHashMap<Var,LinkedHashSet<Eq>>> bfs(LinkedHashSet<Eq> startingNodes) {
		ArrayList<LinkedHashMap<Var,LinkedHashSet<Eq>>> Lv = new ArrayList<LinkedHashMap<Var,LinkedHashSet<Eq>>>();
		LinkedHashSet<Eq> Le_current = new LinkedHashSet<Eq>();
		LinkedHashSet<Eq> Le_next = new LinkedHashSet<Eq>();
		
		Le_current.addAll(startingNodes);
		// Reset nodes
		lightReset();
		
		int layer = 0;
		boolean freeVarNodeFound = false;
		//System.out.println("************** BFS ************* starting nodes: " + startingNodes);
		
		while (Le_current.size()>0 && !freeVarNodeFound) {
			//System.out.println("*** layer: " + layer);
			//System.out.println(Lv);
			//System.out.println(Le_current);
			Lv.add(new LinkedHashMap<Var,LinkedHashSet<Eq>>());
			
			for (Eq s : Le_current) {
				//System.out.println(" eq: " + s.getName());
				for (Var t : s.getVariables()) {
					//System.out.println("  " + t.getName() + " layer: " + t.getLayer());
					if (t.getLayer() >= layer) {
						//System.out.println("    adding " + t.getName());
						t.setLayer(layer);
						LinkedHashSet<Eq> h = Lv.get(layer).get(t);
						if (h==null) {
							h = new LinkedHashSet<Eq>();
							Lv.get(layer).put(t,h);
						}
						h.add(s);
						Eq u = t.getMatching();
						if (u!=null) {
							//System.out.println("     " + t.getName() + "'s matching is " + u.getName());
							u.setLayer(layer);
							Le_next.add(u);
						} else {
							//System.out.println("     " + t.getName() + "has no matching");
							freeVarNodeFound = true;
					
						}
					}
				}
			}
			layer++;
			Le_current = Le_next;
			Le_next = new LinkedHashSet<Eq>();
		}
		
		ArrayList<Var> delQueue = new ArrayList<Var>();
		for (Var v : Lv.get(Lv.size()-1).keySet()) {
			if (v.getMatching()!=null) {
				delQueue.add(v);
			}
		}
		for (Var v : delQueue) {
			Lv.get(Lv.size()-1).remove(v);
		}
		//System.out.println(Lv);
		//System.out.println("************** BFS ends *************");
		return Lv;
	}

	public ArrayList<ArrayList<Edge>> dfs(ArrayList<LinkedHashMap<Var,LinkedHashSet<Eq>>> Lv) {
		lightReset();
		ArrayList<ArrayList<Edge>> P = new ArrayList<ArrayList<Edge>>();
	
		boolean found_path = true;
		for (Var v : Lv.get(Lv.size()-1).keySet()) {
			ArrayList<Edge> P_tmp = new ArrayList<Edge>();
			
			ListIterator<LinkedHashMap<Var,LinkedHashSet<Eq>>> iter = 
				Lv.listIterator(Lv.size());
			while (iter.hasPrevious()) {
				LinkedHashMap<Var,LinkedHashSet<Eq>> l = iter.previous();
				v.setVisited(true);
				if (!found_path) {
					break;
				}
				found_path = false;
				for (Eq e : l.get(v)) {
					if (!e.isVisited()) {
						e.setVisited(true);
						P_tmp.add(new Edge(e,v));
						v = e.getMatching();
						found_path = true;
						break;
					}
				}
			}
			if (P_tmp.size() == Lv.size()) {
				P.add(P_tmp);
			}
		}
		//System.out.println(P);
		return P;
	}
	
	public void reassign(ArrayList<ArrayList<Edge>> P) {
		for (ArrayList<Edge> l : P) {
			for (Edge ed : l) {
				ed.getEquation().setMatching(ed.getVariable());
				ed.getVariable().setMatching(ed.getEquation());
			}
		}
	}
	
	public void maximumMatching(boolean resetMatching) {
		if (resetMatching) {
			reset();
			greedyMatching();
		}
		//System.out.println(printMatching());
		
		// Initialize set of free equations
		LinkedHashSet<Eq> startingNodes = new LinkedHashSet<Eq>();
		for (Eq e : getEquations()) {
			if (e.getMatching()==null) {
				startingNodes.add(e);
			}
		}
	
		LinkedHashSet<Eq> unmatchedEquations = new LinkedHashSet<Eq>();
		for (Eq e : equations) {
			if (e.getMatching()==null) {
				unmatchedEquations.add(e);
			}
		}
		
		ArrayList<LinkedHashMap<Var,LinkedHashSet<Eq>>> Lv = null;
		ArrayList<ArrayList<Edge>> P = null;
		
		while (unmatchedEquations.size()>0) {
		
			Lv = bfs(unmatchedEquations);
			P = dfs(Lv);

			if (Lv.get(Lv.size()-1).size()==0) {
				break;
			}
			
			reassign(P);
		
			//System.out.println(printMatching());

			for (ArrayList<Edge> l : P) {
				unmatchedEquations.remove(l.get(l.size()-1).getEquation());
			}
			
			/*
			unmatchedEquations = new LinkedHashSet<Eq>();
			for (Eq e : equations) {
				if (e.getMatching()==null) {
					unmatchedEquations.add(e);
				}
			}
*/
			
		}
	}
	
	public ArrayList<Eq> getUnmatchedEquations() {
		ArrayList<Eq> l = new ArrayList<Eq>();
		for (Eq e : equations) {
			if (e.getMatching()==null) {
				l.add(e);
			}
		}
		return l;
	}

	public ArrayList<Var> getUnmatchedVariables() {
		ArrayList<Var> l = new ArrayList<Var>();
		for (Var v : variableMap.values()) {
			if (v.getMatching()==null) {
				l.add(v);
			}
		}
		return l;
	}
	
    public LinkedList<Stack<Eq>> computeBLT() {

        int nbr = 0;
        Stack<Eq> stack = new Stack<Eq>();
        Stack<Eq> eStack = new Stack<Eq>();

        LinkedList<Stack<Eq>> components = new LinkedList<Stack<Eq>>();

        for (Eq eqn : getEquations()) {
//        while (!activeEqns.empty()) {
 //           Equation eq = activeEqns.pop();

            System.out.println("active: " + eqn);

            if (eqn.getTarjanNbr() == 0) {
                eqn.setTarjanNbr(++nbr);
                eqn.setTarjanLowLink(nbr);

                System.out.println("push: " + eqn);
                stack.push(eqn);
                eStack.push(eqn);

                while (!stack.empty()) {
                    eqn = stack.peek();
                    Var var = eqn.getNextVariable();

                    if (var != null) {
                        System.out.println("top: " + eqn + " - " + var);
                        Eq eqn2 = var.getMatching();
                        System.out.println("match: " + eqn2);

                        if (eqn2.getTarjanNbr() == 0) {
                            eqn2.setTarjanNbr(++nbr);
                            eqn2.setTarjanLowLink(nbr);

                            System.out.println("push: " + eqn2);

                            stack.push(eqn2); // recurse
                            eStack.push(eqn2);
                        } else if (eqn2.getTarjanNbr() < eqn.getTarjanNbr()) {
                            if (eStack.contains(eqn2)) {
                                eqn.setTarjanLowLink(Math.min(eqn.getTarjanLowLink(), 
                                                          	eqn2.getTarjanNbr()));
                            }
                        }
                    } else {
                        System.out.println("top: " + eqn + 
                            " - exhausted variables (estack = " + eStack.size() + ")");

                        if (eqn.getTarjanLowLink() == eqn.getTarjanNbr()) {
                        	System.out.println("Heppp---------------");
                            // 'eq' is the root of a strong component
                            if (!eStack.empty()) {
                                // new strong component
                                System.out.println("Strong component:");
                                Eq eqn2 = eStack.peek();

								/*
                                System.out.println("this: " + eq + " (" + 
                                                   eq.getTarjanNbr() + ", " + 
                                                   eq.getTarjanLink() + ")");
                                System.out.println("that: " + eq2 + " (" + 
                                                   eq2.getTarjanNbr() + ", " + 
                                                   eq2.getTarjanLink() + ")");
                               
                                System.out.print(" ");
								*/
                                Stack<Eq> comp = new Stack<Eq>();
                                while (eqn2.getTarjanNbr() >= eqn.getTarjanNbr()) {
                                    eqn2 = eStack.pop();

                                    comp.push(eqn2);
									
                                    System.out.println("In COMPONENT: (" + eqn2 + 
                                                     ", " + eqn2.getMatching() + ")");
													 

                                    if (eStack.empty()) {
                                        break;
                                    } else {
                                        eqn2 = eStack.peek();
										/*
                                        System.out.println("that: " + eq2 + " (" + 
                                                   eq2.getTarjanNbr() + ", " + 
                                                   eq2.getTarjanLink() + ")");
										*/
                                    }
                                }

                                if (!comp.empty()) {
                                    components.addLast(comp);
                                }
                            }
                        }

                        Eq eqn2 = stack.pop();
                        //System.out.println("pop: " + eq2);
                        if (!stack.empty()) {
                            eqn.setTarjanLowLink(Math.min(eqn.getTarjanLowLink(), 
                                                      eqn2.getTarjanLowLink()));
                        }
                    }
                }
            }
        }

		return components;

    }
	
	public void randomTest(int n_eq, int n_var, int n_ed) {
		
		BiPGraph g = new BiPGraph("Random Graph","");
		
		for (int i=0;i<n_eq;i++) {
			g.addEquation("e_"+(i+1), "",i);
		}

		for (int i=0;i<n_var;i++) {
			g.addVariable("v_"+(i+1), "");
		}

		Random r = new Random();
		for (int i=0;i<n_ed;i++) {
			boolean added=false;
			while (!added) {
				int e_ind = r.nextInt(n_eq) + 1;
				int v_ind = r.nextInt(n_var) + 1;
				if (g.addEdge("e_"+e_ind,"v_"+v_ind)) {
					added = true;
				}
			}
		}
		
		//System.out.println(g);
		long before = System.currentTimeMillis();
		g.maximumMatching(true);
		long after = System.currentTimeMillis();
		System.out.println("Matching n_equations="+n_eq+" n_variables="+n_var+" n_edges="+n_ed+" --- " + (((double)(after-before))/1000.));
		
		//System.out.println(g.printMatching());
		
	}
	
	public void reset() {
		for (Eq e : getEquations()) {
			e.reset();
		}		
		for (Var v : variableMap.values()) {
			v.reset();
		}		
	}

	public void lightReset() {
		for (Eq e : getEquations()) {
			e.lightReset();
		}		
		for (Var v : variableMap.values()) {
			v.lightReset();
		}		
	}

	public void tarjanReset() {
		for (Eq e : getEquations()) {
			e.tarjanReset();
		}		
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

	public ArrayList<Eq> getEquations() {
		return equations;
	}

	public String printMatching() {
		StringBuffer str = new StringBuffer();
		str.append("----------------------------------------\n");
		str.append("BiPGraph " + getName() + " matching:\n");
		for (Eq e : getEquations()) {
			if (e.getMatching()!=null) {
				str.append(e.getName());
//				str.append(e.getName() + "(" + e.getDescription() + ")");
				str.append(" : ");
				str.append(e.getMatching().getName());
				str.append("\n");
			}
		}		
		str.append("Unmatched equations: {");
		for (Eq e : getUnmatchedEquations()) {
			str.append(e.getName() + " ");
		}
		str.append("}\n");

		str.append("Unmatched variables: {");
		for (Var v : getUnmatchedVariables()) {
			str.append(v.getName() + " ");
		}
		str.append("}\n");

		str.append("----------------------------------------\n");
		return str.toString();
	}
	
	public String toString() {
		StringBuffer str = new StringBuffer();
		str.append("BiPGraph " + getName() + "\n");
		if (!getDescription().equals("")) {
			str.append(" (");
			str.append(getDescription());
			str.append(")\n");
		}
		for (Eq e : getEquations()) {
			str.append(e.getName());
			str.append(" : ");
			for (Var v : e.getVariables()) {
				str.append(v.getName() + " ");
			}
			str.append("\n");
		}
		return str.toString();
	}
	
    class Edge {
    	private Var variable;
    	private Eq equation;
    	
    	public Edge(Eq e, Var v) {
    		this.equation = e;
    		this.variable = v;
    	}

		public Var getVariable() {
			return variable;
		}

		public void setVariable(Var variable) {
			this.variable = variable;
		}

		public Eq getEquation() {
			return equation;
		}

		public void setEquation(Eq equation) {
			this.equation = equation;
		}
    	
		public String toString() {
			return "(" + equation.getName() + "," + variable.getName() + ")";
		}
    	
    }
}
