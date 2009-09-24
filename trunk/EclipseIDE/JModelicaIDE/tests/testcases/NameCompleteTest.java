package testcases;

import junit.framework.TestCase;


public class NameCompleteTest extends TestCase {

@SuppressWarnings("unused")
public void testCompletions(String path, String failMessage) throws Exception {
//    
//    System.out.println(path);
//    
//    ModelicaTestCase m = new ModelicaTestCase(path);
//    Completions c = new Completions(m.root);
//    
//    // if whitespace at caret, don't add '.'. not qualified lookup 
//    if (!("" + m.document.getChar(m.caretOffset-1)).matches("\\s")) 
//        m.document.replace(m.caretOffset, 0, "."); 
//    
//    ArrayList<CompletionNode> decls = c.suggestedDecls(m.document, m.caretOffset+1);
//
//    Set<String> expected = new HashSet<String>(
//            Arrays.asList(m.expected().value().split(",\\s*")));
//    
//    
//    Set<String> actual = new HashSet<String>();
//    for (CompletionNode node : decls) 
//        actual.add(node.completionName());
//        
//    System.out.printf("%s, %s\n", expected, actual);
//
//    assertEquals(
//            failMessage,
//            expected, 
//            actual);
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

public static void main(String[] args) throws Exception {
    
    int i = Integer.parseInt(args[0]);
    
    String format = "test_data/completion/suggestedDecls%d.mo";
    int nbrTestCases = ModelicaTestCase.nbrTestCasesMatchin(format);
    
    assertTrue(nbrTestCases > 0);
 
    new NameCompleteTest().testCompletions(
        String.format(format, i),
        String.format(ModelicaTestCase.FAIL, i));

    
}

public void testGetContext() {
//    String s = "test.ing";
//    Pair<String, String> p = new Completions().getContext(new Document(s), s.length());
//    assertEquals(p, new Pair<String, String>("test", "ing"));
//    
//    s = "tes.ti.in.g";
//    p = new Completions().getContext(new Document(s), s.length());
//    assertEquals(p, new Pair<String, String>("tes.ti.in", "g"));
//
//    s = "unqualified";
//    p = new Completions().getContext(new Document(s), s.length());
//    assertEquals(p, new Pair<String, String>("", "unqualified"));
//    
//    s = ".test";
//    p = new Completions().getContext(new Document(s), s.length());
//    assertEquals(p, new Pair<String, String>("", "test"));
//    
//    s = "              ";
//    p = new Completions().getContext(new Document(s), s.length());
//    assertEquals(p, new Pair<String, String>("", ""));
//
//    s = "test.ti(";
//    p = new Completions().getContext(new Document(s), s.length());
//    assertEquals(p, new Pair<String, String>("", ""));
//    
}

}
