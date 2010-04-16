package testcases;

import java.io.File;
import java.util.ArrayList;
import java.util.Set;
import java.util.TreeSet;

import junit.framework.TestCase;
import mock.MockEditor;

import org.jmodelica.ide.ModelicaCompiler;
import org.jmodelica.ide.helpers.Maybe;
import org.jmodelica.ide.namecomplete.CompletionNode;
import org.jmodelica.ide.namecomplete.CompletionProcessor;
import org.jmodelica.modelica.compiler.SourceRoot;
import org.jmodelica.modelica.compiler.StoredDefinition;


public class NameCompleteTest extends TestCase {

public void testCompletions(String path, String failMessage) throws Exception {
    
    System.out.println(path);
    
    ModelicaTestCase m =
        new ModelicaTestCase(path);
    
    CompletionProcessor c = 
        new CompletionProcessor(
            new MockEditor(path));
    
    // if whitespace at caret, don't add '.'
    if (!("" + m.document.getChar(m.document.offset - 1)).matches("\\s")) { 
        m.document.replace(m.document.offset, 0, "."); 
        m.document.offset++;
    }
    
    SourceRoot root = 
        new ModelicaCompiler().compileDirectory(
            new File("test_data/test_project/"));
    
    root.options.setStringOption(
            "MODELICAPATH",
            new File("test_data/MSL/").getAbsolutePath());
    
    StoredDefinition testAST = 
        new ModelicaCompiler().compileString(
            m.document.get());
    
    root.getProgram().addUnstructuredEntity(testAST);
    
    ArrayList<CompletionNode> decls = 
        c.suggestedDecls(m.document, new Maybe<SourceRoot>(root));

    Set<String> expected = m.expectedSet();
    
    Set<String> actual = new TreeSet<String>();
    for (CompletionNode node : decls) 
        actual.add(node.completionName());
        
    System.out.printf("%s, %s\n", expected, actual);

    assertEquals(
            failMessage,
            expected, 
            actual);
}

public void testCompletions() throws Exception {
    String format = "test_data/completion/suggestedDecls%d.mo";
    int nbrTestCases = ModelicaTestCase.nbrTestCasesMatching(format);
    
    assertTrue(nbrTestCases > 0);
    
    for (int i = 0; i <= nbrTestCases; i++) {
        testCompletions(
            String.format(format, i),
            String.format(ModelicaTestCase.FAIL, i));
    }
    
    System.out.println();
    System.out.println(" ** Complete **");
}

}
