/* Written by Philip Reuterswärd 2007 and 2010. */
/* TODO: Insert GPL license / Modelon copyright (?). */
package org.jmodelica.graphs;

public class Variable {
    private Equation match;
    private String name;
    private int timesDiffed;
    private Variable integral;
    private Variable differential;
    private boolean active;

    private int id;

    public Variable(String name, int timesDiffed, int id) {
        this.name = name;
        this.timesDiffed = timesDiffed;
        this.id = id;

        match = null;
        active = false;
    }

    public int getId() {
        return id;
    }

    public boolean isActive() {
        return active;
    }

    public void setActive(boolean b) {
        active = b;
    }

    public Variable integrate() {
        return integral;
    }

    public Variable differentiate() {
        return differential;
    }

    public String getKey() {
        return calcKey(name, timesDiffed);
    }

    public static String calcKey(String name, int timesDiffed) {
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

    public void setDifferential(Variable dvar) {
        differential = dvar;
    }

    public void setIntegral(Variable ivar) {
        integral = ivar;
    }

    public int getTimesDiffed() {
        return timesDiffed;
    }

    public boolean isMatched() {
        return (match != null);
    }

    public Equation getMatch() {
        return match;
    }

    public void setMatch(Equation eq) {
        match = eq;
    }

    public String getName() {
        return name;
    }

    public String toString() {
        return calcKey(name, timesDiffed);
    }
}
