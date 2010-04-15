package testcases;

import junit.framework.TestCase;

import org.jmodelica.ide.helpers.Maybe;
import org.jmodelica.ide.namecomplete.Lookup;
import org.jmodelica.modelica.compiler.InstClassDecl;
import org.jmodelica.modelica.compiler.InstNode;

public class LookupTest extends TestCase {


public void testInstEnclosingClassAt(String path, String fail) {
    
    ModelicaTestCase m = new ModelicaTestCase(path);

    Maybe<InstClassDecl> decl = new Lookup(m.root)
        .instEnclosingClassAt(m.document);
    
    Maybe<String> expected = m.expected();
    
    assertTrue(
            fail, 
            decl.isNothing() == expected.isNothing());
    
    if (expected.isNothing())
        return;
        
    assertEquals(
            fail, 
            expected.value(), 
            decl.value().getClassDecl().name());
    
}

public void testInstEnclosingClassAt() {
    String format = "test_data/lookup/instEnclosingClassAt%d.mo";
    int nbrTestCases = ModelicaTestCase.nbrTestCasesMatchin(format);
    
    assertTrue(nbrTestCases > 0);
    
    for (int i = 1; i <= nbrTestCases; i++) {
        testInstEnclosingClassAt(
                String.format(format, i),
                String.format(ModelicaTestCase.FAIL, i));
    }
}

public void testDeclFromAccessAt(String path, String failMessage) {
    
    ModelicaTestCase m = new ModelicaTestCase(path);
    
    Maybe<InstNode> node = 
        new Lookup(m.root).declarationFromAccessAt(m.document);
    
    Maybe<String> expected = m.expected();
    
    assertTrue(
            failMessage,
            node.isNothing() == expected.isNothing());

    if (expected.isNothing()) 
        return;
    
    //TODO: fails here in test case, but not in plugin. investigate
    assertEquals(failMessage,
            expected.value(), 
            node.value().name());
    
}

public void testDeclFromAccessAt() {

    String format = "test_data/lookup/declFromAccessAt%d.mo";
    int nbrTestCases = ModelicaTestCase.nbrTestCasesMatchin(format);
    
    assertTrue(nbrTestCases > 0);
    
    for (int i = 1; i <= nbrTestCases; i++) {
        testDeclFromAccessAt(
            String.format(format, i),
            String.format(ModelicaTestCase.FAIL, i));
    }
}

}
