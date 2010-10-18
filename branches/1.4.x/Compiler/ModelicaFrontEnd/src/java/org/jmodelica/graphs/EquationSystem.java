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
 
     Written by Philip Reuterswärd 2007 and 2010.
*/

package org.jmodelica.graphs;

import java.util.LinkedList;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.HashSet;
import java.util.LinkedHashSet;
import java.util.Stack;
import java.util.Collection;

/* 
 * References:
 *
 * Pantelides, The Consistent Initialization of Differential-Algebraic Systems,
 * SIAM J. Sci. Stat. Comput., 1988
 *
 * Tarjan, Depth-First Search and Linear Graph Algorithms, SIAM J. Comput., 1972
 *
 * ----
 * Rmk: A lot of these methods should not be 'public', but ~'package private'.
 * Rmk: Introduce interfaces for the different graph-algos.
 * Rmk: The cheap assignment should use the Hopcroft-Karp algorithm instead?
 * Rmk: Full dummy derivative selection possibilities requires 
 *      algorithms for calculating all possible matchings. 
 * Rmk: The (structural) index calculation is off. 
 *      Maybe there's a reason that some 
 *      commercial tools don't output this information.
 */

/*
 * Usage:
 *
 * 1. Create a graph:
 *
 *      EquationSystem eqSys = new EquationSystem("equation system name");
 *      Equation eq;
 *      Variable var;
 *
 *      eq = eqSys.addEquation("(1)");
 *      var = eqSys.addVariable("x2");
 *      eq.addVariable(var);
 *      var = eqSys.addVariable("x1", 1);
 *      eq.addVariable(var);
 *      ... 
 *
 * 2. Run pantelides
 *
 *      int index = eqSys.pantelides();
 *
 *    This might call for differentition of subsets of equations.
 *    To check for this:
 *
 *       eqSys.hasDifferentiatedEquations();
 *
 *    NB: the index calculation is off for some examples. Maybe it should be removed.
 *
 * 3. Run BLT
 *
 *      LinkedList<Stack<Equation>> comp = eqSys.blt();
 *
 *    This returns a sorted list of strong components (equations). 
 *     
 *      Variable v = Equation.getMatch();
 *
 *    return the variable matched to an equation.
 */

public class EquationSystem {
    private LinkedList<Equation> equations;
    private HashMap<String, Variable> variables;
    private HashMap<String, Variable> activeVariables;
    private String name;

    private int maxId = Integer.MIN_VALUE;
    private int varIdCounter;

    /*
     * Exceptions used to report errors 
     */
    public class PantelidesMaxDepthException extends Exception {  
        PantelidesMaxDepthException(String s) {
            super(s);
        }
    }

    public class PantelidesEmptyEquationException extends Exception {  
        PantelidesEmptyEquationException(String s) {
            super(s);
        }
    }

    public EquationSystem(String name) {
        equations = new LinkedList<Equation>();
        variables = new LinkedHashMap<String, Variable>();
        activeVariables = new LinkedHashMap<String, Variable>();
        this.name = name;
        varIdCounter = 1; // this will number {1,2,3,...}
    }

    public int getNumVariables() {
        return varIdCounter - 1;
    }

    public String getName() {
        return name;
    }

    public Equation addEquation(String name) {
        int id;
        if (maxId == Integer.MIN_VALUE) {
            id = 1;
            maxId = id;
        } else {
            id = ++maxId;
        }

        return addEquation(name, id);
    }

    public Equation addEquation(String name, int id) {
        Equation eq = new Equation(name, 0, id);

        equations.addLast(eq);

        return eq;
    }

    public void activateAllVariables() {
        for (Variable v : variables.values()) {
            v.setActive(true);
        }
    }

    public void activateVariables() {
        for (Variable v : variables.values()) {
            v.setActive(false);
        }
        // Rmk: we touch the active elements twice
        //      this could be improved
        for (Variable v : activeVariables.values()) {
            v.setActive(true);
        }
    }

    /*
    public void cheapAssignment() {
        for (Equation eq : equations) {
            eq.resetVariableIterator();
            Variable var = eq.getNextActiveVariable();

            while (var != null) {
                if (!var.isMatched()) {
                    var.setMatch(eq);
                    eq.setMatch(var);
                    break;
                }

                var = eq.getNextActiveVariable();
            }
        }
    }
    */

    private Variable differentiateVariable(Variable var) {
        Variable dvar = var.differentiate();
        if (dvar == null) {
            /* Do I need to know if I have equations of the type
             *       x' = vx;
             *       vx' = ...; ?
             * I don't think so.
             */
            dvar = new Variable(var.getName(), var.getTimesDiffed()+1, 
                                varIdCounter++);
            var.setDifferential(dvar);
            dvar.setIntegral(var);

            Variable highestDeriv = activeVariables.get(var.getName());
            if (dvar.getTimesDiffed() > highestDeriv.getTimesDiffed()) {
                highestDeriv.setActive(false);
                dvar.setActive(true);

                activeVariables.put(var.getName(), dvar);
            }

            variables.put(dvar.calcKey(dvar.getName(), 
                                       dvar.getTimesDiffed()), dvar);
        }

        return dvar;
    }

    private Equation differentiateEquation(Equation eq) {
        Equation deq = new Equation(eq.getName(), eq.getTimesDiffed()+1,
                                    eq.getId());

        eq.setDifferential(deq);
        deq.setIntegral(eq);

        eq.resetVariableIterator();
        Variable var;
        while ((var = eq.getNextVariable()) != null) {
            // note: for linear equations we shouldn't add 'var' here, e.g. (var = {x,y})
            // x + y = 0   d/dt -> x' + y' = 0
            deq.addVariable(var);

            Variable dvar = differentiateVariable(var);
            deq.addVariable(dvar);
        }
        
        return deq;
    }

	// returns the sorted strong components
	// someone should probably change the return format
    public LinkedList<Stack<Equation>> blt() {
        Stack<Equation> activeEqns = new Stack<Equation>();
        
        for (Equation eq : equations) {
            // highest appearing derivatives are active
            if (eq.differentiate() == null) {
                eq.resetVariableIterator();
                eq.setTarjanNbr(0);
                activeEqns.push(eq);
            }

        }

		/*
        System.out.println("Active equations for BLT:");
        System.out.print("  ");
        for (Equation eq : activeEqns) {
            System.out.print(eq + " ");
        }
        System.out.println();
		*/

        int j = 0;
        Stack<Equation> stack = new Stack<Equation>();
        Stack<Equation> eStack = new Stack<Equation>();

        LinkedList<Stack<Equation>> components = new LinkedList<Stack<Equation>>();

        while (!activeEqns.empty()) {
            Equation eq = activeEqns.pop();

            //System.out.println("active: " + eq);

            if (eq.getTarjanNbr() == 0) {
                eq.setTarjanNbr(++j);
                eq.setTarjanLink(j);

                //System.out.println("push: " + eq);
                stack.push(eq);
                eStack.push(eq);

                while (!stack.empty()) {
                    eq = stack.peek();
                    Variable var = eq.getNextActiveVariable();

                    if (var != null) {
                        //System.out.println("top: " + eq + " - " + var);
                        Equation eq2 = var.getMatch();
                        //System.out.println("match: " + eq2);

                        if (eq2.getTarjanNbr() == 0) {
                            eq2.setTarjanNbr(++j);
                            eq2.setTarjanLink(j);

                            //System.out.println("push: " + eq2);

                            stack.push(eq2); // recurse
                            eStack.push(eq2);
                        } else if (eq2.getTarjanNbr() < eq.getTarjanNbr()) {
                            if (eStack.contains(eq2)) {
                                eq.setTarjanLink(Math.min(eq.getTarjanLink(), 
                                                          eq2.getTarjanNbr()));
                            }
                        }
                    } else {
                        //System.out.println("top: " + eq + 
                        //    " - exhausted variables (estack = " + eStack.size() + ")");

                        if (eq.getTarjanLink() == eq.getTarjanNbr()) {
                            // 'eq' is the root of a strong component
                            if (!eStack.empty()) {
                                //System.out.println("estack: ");
                                for (Equation e : eStack) {
                                    //System.out.println("  " + e + " : (" + 
                                    //                   e.getTarjanNbr() + ", " + 
                                     //                  e.getTarjanLink() + ")");
                                }
                                
                                // new strong component
                                //System.out.println("Strong component:");
                                Equation eq2 = eStack.peek();

								/*
                                System.out.println("this: " + eq + " (" + 
                                                   eq.getTarjanNbr() + ", " + 
                                                   eq.getTarjanLink() + ")");
                                System.out.println("that: " + eq2 + " (" + 
                                                   eq2.getTarjanNbr() + ", " + 
                                                   eq2.getTarjanLink() + ")");
                               
                                System.out.print(" ");
								*/
                                Stack<Equation> comp = new Stack<Equation>();
                                while (eq2.getTarjanNbr() >= eq.getTarjanNbr()) {
                                    eq2 = eStack.pop();

                                    comp.push(eq2);
									/*
                                    System.out.println("In COMPONENT: (" + eq2 + 
                                                     ", " + eq2.getMatch() + ")");
													 */

                                    if (eStack.empty()) {
                                        break;
                                    } else {
                                        eq2 = eStack.peek();
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

                        Equation eq2 = stack.pop();
                        //System.out.println("pop: " + eq2);
                        if (!stack.empty()) {
                            eq.setTarjanLink(Math.min(eq.getTarjanLink(), 
                                                      eq2.getTarjanLink()));
                        }
                    }
                }
            }
        }

		return components;

		/*
        System.out.println("Strong components (" + components.size() + "):");
        int k = 1;
        for (Stack<Equation> s : components) {
            //System.out.println("component " + (k++) + ":");
            for (Equation eq : s) {
                System.out.print(eq + " : ");

                eq.resetVariableIterator();
                Variable var = eq.getNextVariable();
                while (var != null) {
                    String str = var.toString();
                    if (!var.isActive()) {
                        str = "~" + str;
                    }

                    if (var.getMatch() == eq) {
                        System.out.print("[" + str + "] ");
                    } else {
                        System.out.print(str + " ");
                    }
                    var = eq.getNextVariable();
                }
                System.out.println();
            }
            System.out.println("---");
        }
		*/
    }

	// Pantelides algorithm
	//
    // call 'cheapAssignment' prior to this
    // 
    // Returns index. 
    // NB: Still experimental!! This may be wrong!!
    public int pantelides() throws PantelidesMaxDepthException, 
                                   PantelidesEmptyEquationException {
        int defaultMaxDepth = 5;

		return pantelides(defaultMaxDepth);
	}

	//
	// maxDepth - the algorithm might fail, this is the max number 
	//            of consecutive equation differentiations
    public int pantelides(int maxDepth) throws PantelidesMaxDepthException, 
                                        PantelidesEmptyEquationException {
        int index; // DAE index
        
        Stack<Equation> unassigned = new Stack<Equation>();
        /* TODO: collect differentiated equations
         *       in a special place
         *
         */
        //Stack<Equation> differentiate = new Stack<Equation>();

        // cheapAss
        for (Equation eq : equations) {
            if (eq.getNumVariables() == 0) {
                throw new PantelidesEmptyEquationException(
                                          "Encountered empty equation");
            }

            eq.resetVariableIterator();
            Variable var = eq.getNextActiveVariable();

            while (var != null) {
                if (!var.isMatched()) {
                    var.setMatch(eq);
                    eq.setMatch(var);
                    break;
                }

                var = eq.getNextActiveVariable();
            } 

            // could no match equation
            /* TODO:
            eq.resetVariableIterator();
            unassigned.push(eq);
            */
        }

        for (Equation eq : equations) {
            eq.resetVariableIterator();
            if (!eq.isMatched()) {
                unassigned.push(eq);
            }
        }

        // Debug stuff:
        /*
        if (unassigned.empty()) {
            System.out.println("No unassigned equations");
        } else {
            System.out.println("Unassigned equations:");
            System.out.print("  ");
            for (Equation eq : unassigned) {
                System.out.print(eq + " ");

            }
            System.out.println();
        }
        */

        index = 0;
        Collection<Equation> differentiate = new LinkedList<Equation>();
        while (!unassigned.empty()) {
            differentiate.clear();
            Equation eq = unassigned.pop();

            if (eq.getTimesDiffed() > index) {
                index = eq.getTimesDiffed();
            }
            
            if (index > maxDepth) {
                //System.out.println("pantelides reached max depth.");

                throw new PantelidesMaxDepthException("Reached max depth = " + index);
            }

            //System.out.println("pantelides pop unassigned: " + eq);

            if (!augmentPath(eq, differentiate)) {
				/*
                System.out.println("subset needs differentiation (level = " + eq.getTimesDiffed() + "):");
                System.out.print("  equation: " + eq);
				*/

                // remove previous matching
                if (eq.getMatch() != null) {
                    eq.getMatch().setMatch(null);
                    eq.setMatch(null);
                }

                Equation deq = differentiateEquation(eq);
                unassigned.push(deq);
                equations.addLast(deq);

                // Rmk: when differentiate comes back it may 
                //      contain duplicates...
                //      This is the lazy way:
                //
                //      Another way would be to have augmentPath
                //      accept a java.util.Set instead
                //      (but it still would not be optimal..)
                HashSet<Equation> set = new HashSet<Equation>(differentiate);
                for (Equation eqn : set) {
                    //System.out.print(" " + eqn);
                    deq = differentiateEquation(eqn);

                    unassigned.push(deq);
                    equations.addLast(deq);

                    // remove previous matching.
                    // the variable isn't active anymore
                    // since we differentiate the equation..
                    if (eqn.getMatch() != null) {
                        eqn.getMatch().setMatch(null);
                        eqn.setMatch(null);
                    }
                }

                //System.out.println();

				/*
                // do some heavy printous
                System.out.println("graph after subset diff:");
                set = new HashSet<Equation>(equations);
                // keep active equations
                set.removeAll(unassigned);
                for (Equation e : set) {
                    dumpEquation(e);
                }
                System.out.println("------------");
                for (Equation e : unassigned) {
                    dumpEquation(e);
                }
				*/
            }
        }

        // index calculation:
        //
        // if all matched variables (which should be the active by now)
        // are differentiated then we have reduced to index 0,
        // else we have reduced to index 1.
        //
        // index has counted the number of times of differentiation
        // for the most diffed equation
        //
        // TODO:
        //
        // This test isn't good enough.
        for (Variable var : activeVariables.values()) {
            if (var.getTimesDiffed() == 0) {
                ++index;
                break;
            }
        }

        // all matched variables appear differentiated
        return index;
    }

    public boolean hasDifferentiatedEquations() {
        // differentiated equations are inserted last
        return (equations.getLast().getTimesDiffed() > 0);
    }

    private boolean augmentPath(Equation equation, Collection<Equation> differentiate) {
        Stack<Equation> stack = new Stack<Equation>();

        // use a stack instead of recursion, we don't know how deep we will run...
        equation.resetVariableIterator();
        stack.push(equation);

        while (!stack.empty()) {
            Equation eq = stack.peek();

            //System.out.println("top: " + eq);

            Variable var = eq.getNextActiveVariable();

            //System.out.println("next: variable - " + var);

            while (var != null) {
                //System.out.println("  " + var + " -> " + var.getMatch());
                if (var.getMatch() == eq) {
                    //System.out.println("    don't circulate");
                    // don't follow your own match
                    //var = eq.getNextVariable();
                    var = eq.getNextActiveVariable();
                    continue;
                }

                if (var.isMatched()) {
                    //System.out.println("  push: " + var.getMatch());
                    eq = var.getMatch();

                    eq.resetVariableIterator();
                    stack.push(var.getMatch());
                    // Rmk: this introduces duplicates. 
                    //      find a better solution...
                    differentiate.add(eq);
                    break;
                } else {
                    //System.out.println("  found augmenting path (depth = " + stack.size() + "):");

                    eq = stack.pop();

                    // eq is current top, var is unmatched
                    //
                    // Remark: this is problematic if the stack holds more than 1 element after the cheap assignment
                    while (!stack.empty()) {
                        // eq always has a match here
                        Variable tmp = eq.getMatch();

                        eq.setMatch(var);
                        var.setMatch(eq);

                        //System.out.println("    match: " + eq + " - " + var);

                        var = tmp;
                        eq = stack.pop();
                    }

                    eq.setMatch(var);
                    var.setMatch(eq);
                    //System.out.println("    match: " + eq + " - " + var);

                    differentiate.clear();

                    return true;
                }         
            }

            if (var == null) {
                eq = stack.pop();
                //System.out.println("pop: " + eq);
            }
        }

        return false;
    }

    public Variable addVariable(String name) {
        return addVariable(name, 0);
    }


    public Variable addVariable(String name, int timesDiffed) {
        String key = Variable.calcKey(name, timesDiffed);

        //System.out.println("BEGIN: " + name + ", " + timesDiffed + 
                           //", key = " + key);

        Variable var; 
        if (variables.containsKey(key)) {
            var = variables.get(key);
            //System.out.println("contains OK: " + var);
        } else {
            var = new Variable(name, timesDiffed, ++varIdCounter);
            variables.put(key, var);

            // make sure we keep the highest derivative collection
            // up to date. 
            // pantelides might call for addition derivative variables
            // while matching.
            Variable highestDeriv;
            if ((highestDeriv = activeVariables.get(name)) != null) {
                if (var.getTimesDiffed() > highestDeriv.getTimesDiffed()) {
                    activeVariables.put(name, var);

                    highestDeriv.setActive(false);
                    var.setActive(true);
                }
            } else {
                activeVariables.put(name, var);
                var.setActive(true);
            }
        }

        key = Variable.calcKey(name, timesDiffed - 1);
        if (variables.containsKey(key)) {
            Variable integral = variables.get(key);

            var.setIntegral(integral);
            integral.setDifferential(var);
        }

        key = Variable.calcKey(name, timesDiffed + 1);
        if (variables.containsKey(key)) {
            Variable diff = variables.get(key);

            var.setDifferential(diff);
            diff.setIntegral(var);
        } 

        //System.out.println("END: " + var);

        return var;
    }

    public void dumpGraph() {
        for (Equation eq : equations) {
            dumpEquation(eq);
        }
    }

    public void dumpEquation(Equation eq) {
        System.out.print(eq + ": ");
        eq.resetVariableIterator();

        Variable var = eq.getNextVariable();

        while (var != null) {
            String str = var.toString();
            if (!var.isActive()) {
                str = "~" + str;
            }

            if (var.getMatch() == eq) {
                System.out.print("[" + str + "] ");
            } else {
                System.out.print(str + " ");
            }
            var = eq.getNextVariable();
        }
        System.out.println();
    }

    public void dumpMatrixMarket(String file) {
        // dump as sparse integer matrix
        String header = "%%MatrixMarket matrix coordinate integer general";
        System.out.println(header);

        int m = equations.size();
        int n = variables.size();

        // count non-zeros
        int nnz = 0;
        for (Equation eq : equations) {
            nnz += eq.getNumVariables(); 
        }

        // print matrix size
        System.out.println("  " + m + "  " + n + "  " + nnz);
        
        for (Equation eq : equations) {
            eq.resetVariableIterator();

            Variable var = eq.getNextVariable();

            // Rmk: Right now this dumps all variables, not just active.
            int i = eq.getId();
            while (var != null) {
                int j = var.getId();
                System.out.println("    " + i + "  " + j + "  " + j);

                var = eq.getNextVariable();
            }
        }
    }
}
