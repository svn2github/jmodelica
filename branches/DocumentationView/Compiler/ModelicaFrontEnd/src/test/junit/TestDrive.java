import org.junit.Test;
import org.junit.Ignore;
// NB: static import
import static org.junit.Assert.assertTrue;
import static org.junit.Assert.assertEquals;

import org.jmodelica.graphs.EquationSystem;
import org.jmodelica.graphs.Variable;
import org.jmodelica.graphs.Equation;

import org.jmodelica.graphs.EquationSystem.PantelidesMaxDepthException;
import org.jmodelica.graphs.EquationSystem.PantelidesEmptyEquationException;

import java.util.Stack;
import java.util.LinkedList;

public class TestDrive {
    /* 
     * Testing specific assignment (eqn j matches var k) are
     * no good unless these are unique. The cheap assignment 
     * will change and with this the tests would have to change too.
     */

    //@Ignore
    @Test public void test1() throws Exception {
        /* 
         * System:
         *
         * x = 0  (1)
         *
         * We test:
         *  - #variables
         *  - Index is 1. 
         *  - Results in no differentiations.
         */
        EquationSystem eqSys = new EquationSystem(" ");
        Equation eq = eqSys.addEquation("(1)");

        String varName = "x";
        Variable var = eqSys.addVariable(varName);
        eq.addVariable(var);

        int index = eqSys.pantelides();

        assertEquals(eqSys.getNumVariables(), 1);
        assertEquals(index, 1);
        assertTrue( !eqSys.hasDifferentiatedEquations() );
    }

    //@Ignore
    @Test (expected = PantelidesEmptyEquationException.class) 
    public void test2() throws Exception {
        /* Test failure: one equation, no variables. */

        EquationSystem eqSys = new EquationSystem(" ");
        Equation eq = eqSys.addEquation("(1)");

        try {
            int index = eqSys.pantelides();
        } catch (PantelidesEmptyEquationException e) {
            throw e;
        } catch (Exception e) { }

        assertTrue("Unexpected Exception received", false);
    }

    @Ignore ("The calculation of index is off - this example fails")
    @Test
    public void test3() {
        /*  Test:
         * 
         *  x1 - x3 - U = 0 
         *  C(x3' - x2') + (x1 - x2)/R = 0
         *  x3 = 0
         *
         *  Test: 
         *  - index = 1
         *  - number of variables (x and x')
         */

        EquationSystem eqSys = new EquationSystem("Example 1.2");
        Variable x1 = eqSys.addVariable("x1");
        Variable x2 = eqSys.addVariable("x2");
        Variable x3 = eqSys.addVariable("x3");

        Variable dx2dt = eqSys.addVariable("x2", 1);
        Variable dx3dt = eqSys.addVariable("x3", 1);

        Equation eq1 = eqSys.addEquation("(1.6a)");
        Equation eq2 = eqSys.addEquation("(1.6b)");
        Equation eq3 = eqSys.addEquation("(1.6c)");

        eq1.addVariable(x1);
        eq1.addVariable(x3);

        eq2.addVariable(dx3dt);
        eq2.addVariable(dx2dt);
        eq2.addVariable(x1);
        eq2.addVariable(x2);

        eq3.addVariable(x3);

        assertEquals(eqSys.getNumVariables(), 5);

        int index = -1;
        try {
            index = eqSys.pantelides();

            System.out.println("$$ -------------");
            eqSys.dumpGraph();
            System.out.println("$$ -------------");
        } catch (Exception e) { 
            assertTrue("Unexpected Exception received", false);
        }

        assertEquals(index, 1);
    }

    @Test 
    public void test4() throws Exception {
        // Test BLT of:
        //
        // a = 0
        // a + b = 0
        // a + b + c = 0
        //
        // We test number of strong components (3)

        EquationSystem eqSys = new EquationSystem(" ");

        Variable a = eqSys.addVariable("a");
        Variable b = eqSys.addVariable("b");
        Variable c = eqSys.addVariable("c");

        Equation eq1 = eqSys.addEquation("(1)");
        Equation eq2 = eqSys.addEquation("(2)");
        Equation eq3 = eqSys.addEquation("(3)");

        eq1.addVariable(a);

        eq2.addVariable(a);
        eq2.addVariable(b);

        eq3.addVariable(a);
        eq3.addVariable(b);
        eq3.addVariable(c);

        int index = eqSys.pantelides();
        assertEquals(index, 1);

        LinkedList<Stack<Equation>> comp = eqSys.blt();
        assertEquals(comp.size(), 3);
    }

    @Test (expected = PantelidesMaxDepthException.class) 
    public void test5() throws Exception {
        // x2' = x1
        //  0 = x2
        EquationSystem eqSys = new EquationSystem(" ");

        Variable x1 = eqSys.addVariable("x1");
        Variable x2 = eqSys.addVariable("x2");
        Variable dx2dt = eqSys.addVariable("x2", 1);

        Equation eq1 = eqSys.addEquation("(1)");
        Equation eq2 = eqSys.addEquation("(2)");

        eq1.addVariable(x1);
        eq1.addVariable(dx2dt);
        eq2.addVariable(x2);

        try {
            eqSys.pantelides(0);
        } catch (PantelidesMaxDepthException e) {
            throw e;
        } catch (Exception e) { }

        assertTrue("Unexpected Exception received", false);
    }

    @Test 
    public void test6() throws Exception {
        // Test:
        // a + b       = 0
        // a + b       = 0
        //       c + d = 0
        //       c + d = 0
        //
        // We test number of strong components (2)
        EquationSystem eqSys = new EquationSystem(" ");

        Variable a = eqSys.addVariable("a");
        Variable b = eqSys.addVariable("b");
        Variable c = eqSys.addVariable("c");
        Variable d = eqSys.addVariable("d");

        Equation eq1 = eqSys.addEquation("(1)");
        Equation eq2 = eqSys.addEquation("(2)");
        Equation eq3 = eqSys.addEquation("(3)");
        Equation eq4 = eqSys.addEquation("(4)");

        eq1.addVariable(a);
        eq1.addVariable(b);

        eq2.addVariable(a);
        eq2.addVariable(b);

        eq3.addVariable(c);
        eq3.addVariable(d);

        eq4.addVariable(c);
        eq4.addVariable(d);

        int index = -1;
        try {
            index = eqSys.pantelides();
        } catch (Exception e) { }
        assertEquals(index, 1);

        LinkedList<Stack<Equation>> comp = eqSys.blt();

        assertEquals(comp.size(), 2);
        // TODO: check size of components
    }

    @Test 
    public void test7() throws Exception {
        // Test:
        //
        // x2' = x1
        // x3' = x2
        // x4' = x3
        //  0  = x4
        EquationSystem eqSys = new EquationSystem(" ");

        Variable x1 = eqSys.addVariable("x1");
        Variable x2 = eqSys.addVariable("x2");
        Variable x3 = eqSys.addVariable("x3");
        Variable x4 = eqSys.addVariable("x4");

        Variable dx2dt = eqSys.addVariable("x2", 1);
        Variable dx3dt = eqSys.addVariable("x3", 1);
        Variable dx4dt = eqSys.addVariable("x4", 1);

        Equation eq1 = eqSys.addEquation("(1)");
        Equation eq2 = eqSys.addEquation("(2)");
        Equation eq3 = eqSys.addEquation("(3)");
        Equation eq4 = eqSys.addEquation("(4)");

        eq1.addVariable(x1);
        eq1.addVariable(dx2dt);

        eq2.addVariable(x2);
        eq2.addVariable(dx3dt);

        eq3.addVariable(x3);
        eq3.addVariable(dx4dt);

        eq4.addVariable(x4);

        int index = eqSys.pantelides();

        assertEquals(index, 4);
    }

    @Test 
    public void test8() throws Exception {
        EquationSystem eqSys = new EquationSystem("Pendulum");
        Equation eq;
        Variable var;

        // x1' = x2
        eq = eqSys.addEquation("(1)");
        var = eqSys.addVariable("x2");
        eq.addVariable(var);
        var = eqSys.addVariable("x1", 1);
        eq.addVariable(var);

        // m x2' + lambda/L x1 = 0
        eq = eqSys.addEquation("(2)");
        var = eqSys.addVariable("x1");
        eq.addVariable(var);
        var = eqSys.addVariable("x2", 1);
        eq.addVariable(var);
        var = eqSys.addVariable("lambda");
        eq.addVariable(var);
        
        // y1' = y2
        eq = eqSys.addEquation("(3)");
        var = eqSys.addVariable("y2");
        eq.addVariable(var);
        var = eqSys.addVariable("y1", 1);
        eq.addVariable(var);
       
        // m y2' + lambda/L y1 + m g = 0
        eq = eqSys.addEquation("(4)");
        var = eqSys.addVariable("y1");
        eq.addVariable(var);
        var = eqSys.addVariable("y2", 1);
        eq.addVariable(var);
        var = eqSys.addVariable("lambda");
        eq.addVariable(var);
        
        // x1^2 + y^2 = L^2
        eq = eqSys.addEquation("(5)");
        var = eqSys.addVariable("x1");
        eq.addVariable(var);
        var = eqSys.addVariable("y1");
        eq.addVariable(var);

        int index = -1;
        try {
            index = eqSys.pantelides(5);
        } catch (Exception e) { }

        assertEquals(index, 3);
    }
    
    // --- END of JUnit tests ---

    public static EquationSystem example4() {
        EquationSystem eqSys = new EquationSystem("Simple ODE");
        Equation eq;
        Variable var;

        // x1' = 0 
        eq = eqSys.addEquation("(1)");
        var = eqSys.addVariable("x1", 1);
        eq.addVariable(var);

        // x2' = 0 
        eq = eqSys.addEquation("(2)");
        var = eqSys.addVariable("x2", 1);
        eq.addVariable(var);

        return eqSys;
    }

    public static EquationSystem example3() {
        EquationSystem eqSys = new EquationSystem("Two independent blocks");
        Equation eq;
        Variable var;

        // x1 = 0 
        eq = eqSys.addEquation("(1)");
        var = eqSys.addVariable("x1");
        eq.addVariable(var);

        // x1 + x2 = 0 
        eq = eqSys.addEquation("(2)");
        var = eqSys.addVariable("x1");
        eq.addVariable(var);
        var = eqSys.addVariable("x2");
        eq.addVariable(var);

        // x3 = 0 
        eq = eqSys.addEquation("(3)");
        var = eqSys.addVariable("x3");
        eq.addVariable(var);

        // x3 + x4 = 0 
        eq = eqSys.addEquation("(4)");
        var = eqSys.addVariable("x3");
        eq.addVariable(var);
        var = eqSys.addVariable("x4");
        eq.addVariable(var);

        return eqSys;
    }

    // pendulum
    public static EquationSystem example2() {
        EquationSystem eqSys = new EquationSystem("Pendulum");
        Equation eq;
        Variable var;

        // x1' = x2
        eq = eqSys.addEquation("(1)");
        var = eqSys.addVariable("x2");
        eq.addVariable(var);
        var = eqSys.addVariable("x1", 1);
        eq.addVariable(var);

        // m x2' + lambda/L x1 = 0
        eq = eqSys.addEquation("(2)");
        var = eqSys.addVariable("x1");
        eq.addVariable(var);
        var = eqSys.addVariable("x2", 1);
        eq.addVariable(var);
        var = eqSys.addVariable("lambda");
        eq.addVariable(var);
        
        // y1' = y2
        eq = eqSys.addEquation("(3)");
        var = eqSys.addVariable("y2");
        eq.addVariable(var);
        var = eqSys.addVariable("y1", 1);
        eq.addVariable(var);
       
        // m y2' + lambda/L y1 + m g = 0
        eq = eqSys.addEquation("(4)");
        var = eqSys.addVariable("y1");
        eq.addVariable(var);
        var = eqSys.addVariable("y2", 1);
        eq.addVariable(var);
        var = eqSys.addVariable("lambda");
        eq.addVariable(var);
        
        // x1^2 + y^2 = L^2
        eq = eqSys.addEquation("(5)");
        var = eqSys.addVariable("x1");
        eq.addVariable(var);
        var = eqSys.addVariable("y1");
        eq.addVariable(var);

        return eqSys;
    }

    // Example from Fritzon 2000, p. 663
    public static EquationSystem example1() {
        EquationSystem eqSys = new EquationSystem("Fritzon");
        Equation eq;
        Variable var;

        eq = eqSys.addEquation("eq1");
        var = eqSys.addVariable("z4");
        eq.addVariable(var);
        var = eqSys.addVariable("z3");
        eq.addVariable(var);

        eq = eqSys.addEquation("eq2");
        var = eqSys.addVariable("z2");
        eq.addVariable(var);

        eq = eqSys.addEquation("eq3");
        var = eqSys.addVariable("z2");
        eq.addVariable(var);
        var = eqSys.addVariable("z3");
        eq.addVariable(var);
        var = eqSys.addVariable("z5");
        eq.addVariable(var);

        eq = eqSys.addEquation("eq4");
        var = eqSys.addVariable("z1");
        eq.addVariable(var);
        var = eqSys.addVariable("z2");
        eq.addVariable(var);

        eq = eqSys.addEquation("eq5");
        var = eqSys.addVariable("z1");
        eq.addVariable(var);
        var = eqSys.addVariable("z3");
        eq.addVariable(var);
        var = eqSys.addVariable("z5");
        eq.addVariable(var);

        return eqSys;
    }

    public static void doTest(EquationSystem eqSys) {
        System.out.println("example: " + eqSys.getName());

        System.out.println("graph:");
        eqSys.dumpGraph();

        if (true) {
            System.out.println("cheap assignment:");
            //eqSys.cheapAssignment();
            //eqSys.dumpGraph();

            System.out.println("Pantelides:");
            try {
                int index = eqSys.pantelides();
                System.out.println("index = " + index);
                eqSys.dumpGraph();

                if (eqSys.hasDifferentiatedEquations()) {
                    System.out.println("Pantelides differentiated some equations");
                } else {
                    System.out.println("Pantelides differentiated NO equations");
                }

                System.out.println("BLT:");
                eqSys.blt();
            } catch (PantelidesMaxDepthException e) {
                System.out.println("Pantelides reached max depth");
            } catch (PantelidesEmptyEquationException e) {
                System.out.println("Pantelides encountered empty equation");
            }
        }
    }

    public static void main(String[] arg) {
        doTest(example1()); // Fritzon
        System.out.println("##########################################");
        doTest(example2()); // pendulum
        System.out.println("##########################################");
        doTest(example3()); 
        System.out.println("##########################################");
        doTest(example4()); 
    }
}
