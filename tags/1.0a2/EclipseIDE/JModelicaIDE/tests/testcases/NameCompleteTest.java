package testcases;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashSet;
import java.util.Set;

import junit.framework.TestCase;

import org.eclipse.jface.text.Document;
import org.jmodelica.ide.namecomplete.Completions;
import org.jmodelica.ide.namecomplete.Pair;
import org.jmodelica.modelica.compiler.InstNode;


public class NameCompleteTest extends TestCase {


public void testCompletions(String path, String failMessage) throws Exception {
    
    System.out.println(path);
    
    ModelicaTestCase m = new ModelicaTestCase(path);
    Completions c = new Completions(m.root);
    
    m.document.replace(m.caretOffset, 0, "."); 
    
    ArrayList<InstNode> decls = c.suggestedDecls(m.document, m.caretOffset+1);

    Set<String> expected = new HashSet<String>(
            Arrays.asList(m.expected().value().split(",\\s*")));
    
    Set<String> actual = new HashSet<String>();
    for (InstNode node : decls) 
        actual.add(node.name());
        
    assertEquals(
            failMessage,
            expected, 
            actual);
}

public void testCompletions() throws Exception {
    String format = "test_data/completion/suggestedDecls%d.mo";
    int nbrTestCases = ModelicaTestCase.nbrTestCasesMatchin(format);
    
    assertTrue(nbrTestCases > 0);
    
    for (int i = 1; i <= nbrTestCases; i++) {
        testCompletions(
            String.format(format, i),
            String.format(ModelicaTestCase.FAIL, i));
    }
}

public void testGetContext() {
    String s = "test.ing";
    Pair<String, String> p = new Completions().getContext(new Document(s), s.length());
    assertEquals(p, new Pair<String, String>("test", "ing"));
    
    s = "tes.ti.in.g";
    p = new Completions().getContext(new Document(s), s.length());
    assertEquals(p, new Pair<String, String>("tes.ti.in", "g"));

    s = "apa";
    p = new Completions().getContext(new Document(s), s.length());
    assertEquals(p, new Pair<String, String>("", "apa"));
    
    s = ".test";
    p = new Completions().getContext(new Document(s), s.length());
    assertEquals(p, new Pair<String, String>("", "test"));
    
    s = "              ";
    p = new Completions().getContext(new Document(s), s.length());
    assertEquals(p, new Pair<String, String>("", ""));

    s = "test.ti(";
    p = new Completions().getContext(new Document(s), s.length());
    assertEquals(p, new Pair<String, String>("", ""));
    
}

}
