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

import java.util.HashSet;
import java.util.LinkedHashSet;
import java.util.Iterator;

public class Equation {
    private String name;
    // unique set of elements
    private HashSet<Variable> variables;
    private Iterator<Variable> varIterator;
    private Variable match;
    private Equation integral, differential;
    private int timesDiffed;

    private int tarjanNbr = 0;
    private int llink = 0;

    private int id;
    
    public Equation(String name, int timesDiffed, int id) {
        this.name = name;
        this.timesDiffed = timesDiffed;
        this.id = id;

        variables = new LinkedHashSet<Variable>();
        varIterator = null;
        match = null;
    }

    public int getId() {
        return id;
    }

    public String getName() {
        return name;
    }

    public int getTarjanLink() {
        return llink;
    }

    public void setTarjanLink(int link) {
        llink = link;
    }

    public int getTarjanNbr() {
        return tarjanNbr;
    }

    public void setTarjanNbr(int nbr) {
        tarjanNbr = nbr;
    }

    public int getTimesDiffed() {
        return timesDiffed;
    }

    public boolean isMatched() { 
        return (match != null);
    }

    public Variable getMatch() {
        return match;
    }

    public void setMatch(Variable var) {
        match = var;
    }

    public void resetVariableIterator() {
        varIterator = variables.iterator();
    }

    public Variable getNextVariable() {
        if (varIterator == null) {
            resetVariableIterator();
        }

        if (!varIterator.hasNext()) {
            return null;
        }

        return varIterator.next();
    }
    
    public Variable getNextActiveVariable() {
        if (varIterator == null) {
            resetVariableIterator();
        }

        if (varIterator.hasNext()) {
            Variable var = varIterator.next();

            while (!var.isActive()) {

                if (varIterator.hasNext()) {
                    var = varIterator.next();
                } else {
                    return null;
                }
            }

            return var;
        } else {
            return null;
        }
    }

    public void setIntegral(Equation ieq) {
        integral = ieq;
    }

    public void setDifferential(Equation deq) {
        differential = deq;
    }

    public Equation integrate() {
        return integral;
    }

    public Equation differentiate() {
        return differential;
    }

    public String toString() {
        String str;
        
        if (timesDiffed > 2) {
            str = "d" + timesDiffed + "(" + name + ")";
        } else if (timesDiffed == 2) {
            str = name + "\"";
        } else if (timesDiffed == 1) {
            str = name + "'";
        } else {
            str = name;
        }

        return str;
    }

    public boolean addVariable(Variable var) {
        return variables.add(var);
    }

    public int getNumVariables() {
        return variables.size();
    }
}
