package org.jmodelica.graphs;

import java.util.LinkedList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Stack;
import java.util.Collection;

public class EquationSystem {
    private LinkedList<Equation> equations;
    private HashMap<String, Variable> variables;
    private HashMap<String, Variable> activeVariables;
    private String name;

    private int maxId = Integer.MIN_VALUE;

    public EquationSystem(String name) {
        equations = new LinkedList<Equation>();
        variables = new HashMap<String, Variable>();
        activeVariables = new HashMap<String, Variable>();
        this.name = name;
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

    private Variable differentiateVariable(Variable var) {
        Variable dvar = var.differentiate();
        if (dvar == null) {
            // TODO:
            dvar = new Variable(var.getName(), var.getTimesDiffed()+1);
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

            // TODO:
            Variable dvar = differentiateVariable(var);
            deq.addVariable(dvar);
        }
        
        return deq;
    }

    public void blt() {
        Stack<Equation> activeEqns = new Stack<Equation>();
        
        for (Equation eq : equations) {
            // highest appearing derivatives are active
            if (eq.differentiate() == null) {
                eq.resetVariableIterator();
                eq.setTarjanNbr(0);
                activeEqns.push(eq);
            }

        }

        System.out.println("Active equations for BLT:");
        System.out.print("  ");
        for (Equation eq : activeEqns) {
            System.out.print(eq + " ");
        }
        System.out.println();

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
                         //" - exhausted variables (estack = " + eStack.size() + ")");

                        if (eq.getTarjanLink() == eq.getTarjanNbr()) {
                            if (!eStack.empty()) {
                                //System.out.println("estack: ");
                                for (Equation e : eStack) {
                                    //System.out.println("  " + e + " : (" + 
                                                       //e.getTarjanNbr() + ", " + 
                                                       //e.getTarjanLink() + ")");
                                }
                                
                                // new strong component
                                //System.out.println("Strong component:");
                                Equation eq2 = eStack.peek();

                                //System.out.println("this: " + eq + " (" + 
                                                   //eq.getTarjanNbr() + ", " + 
                                                   //eq.getTarjanLink() + ")");
                                //System.out.println("that: " + eq2 + " (" + 
                                                   //eq2.getTarjanNbr() + ", " + 
                                                   //eq2.getTarjanLink() + ")");
                               
                                //System.out.print(" ");
                                Stack<Equation> comp = new Stack<Equation>();
                                while (eq2.getTarjanNbr() >= eq.getTarjanNbr()) {
                                    eq2 = eStack.pop();

                                    comp.push(eq2);
                                    //System.out.println("In COMPONENT: (" + eq2 + 
                                    //               ", " + eq2.getMatch() + ")");

                                    if (eStack.empty()) {
                                        break;
                                    } else {
                                        eq2 = eStack.peek();
                                        //System.out.println("that: " + eq2 + " (" + 
                                                   //eq2.getTarjanNbr() + ", " + 
                                                   //eq2.getTarjanLink() + ")");
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
    }

    public int pantelides() {
        int index; // DAE index

        // it is recommended to run 'cheapAssignment' first
        
        Stack<Equation> unassigned = new Stack<Equation>();
        //Stack<Equation> differentiate = new Stack<Equation>();

        for (Equation eq : equations) {
            eq.resetVariableIterator();
            if (!eq.isMatched()) {
                unassigned.push(eq);
            }
        }

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

        index = 0;
        Collection<Equation> differentiate = new LinkedList<Equation>();
        while (!unassigned.empty()) {
            differentiate.clear();
            Equation eq = unassigned.pop();

            if (eq.getTimesDiffed() > index) {
                index = eq.getTimesDiffed();
            }
            
            if (index > 4) {
                System.out.println("pantelides reached max depth = " + index);
                return -1;
            }

            //System.out.println("pantelides pop unassigned: " + eq);

            if (!augmentPath(eq, differentiate)) {
                System.out.println("subset needs differentiation (level = " + eq.getTimesDiffed() + "):");
                System.out.print("  equation: " + eq);

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
                    System.out.print(" " + eqn);
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
                System.out.println();

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
        for (Variable var : activeVariables.values()) {
            if (var.getTimesDiffed() == 0) {
                return index+1;
            }
        }

        // all matched variables appear differentiated
        return index;
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
            var = new Variable(name, timesDiffed);
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
}
