package testcases;

import java.io.File;
import java.io.StringReader;
import java.util.Scanner;

import junit.framework.TestCase;

import org.eclipse.jface.text.Document;
import org.eclipse.jface.text.IDocument;
import org.jmodelica.ide.ModelicaCompiler;
import org.jmodelica.ide.helpers.Maybe;
import org.jmodelica.ide.namecomplete.CompletionFilter;
import org.jmodelica.ide.namecomplete.CompletionUtil;
import org.jmodelica.ide.namecomplete.Completions;
import org.jmodelica.ide.namecomplete.Lookup;
import org.jmodelica.ide.namecomplete.Pair;
import org.jmodelica.modelica.compiler.ASTNode;
import org.jmodelica.modelica.compiler.ClassDecl;
import org.jmodelica.modelica.compiler.InstAccess;
import org.jmodelica.modelica.compiler.InstClassDecl;
import org.jmodelica.modelica.compiler.InstNode;
import org.jmodelica.modelica.compiler.SourceRoot;
import org.jmodelica.modelica.parser.ModelicaParser;
import org.jmodelica.modelica.parser.ModelicaScanner;


public class NameCompleteTest extends TestCase {

static ModelicaCompiler compiler = new ModelicaCompiler();

/**
 * these variables are set by parseTestCase
 */
IDocument tcDocument;
ASTNode<?> tcRoot;
ClassDecl tcEnclosingClass;
int tcCaretOffset;

/**
 * Parses a name completion test case containing a Modelica program, and a '^'
 * character in the source where the caret is imagined to be.
 */
public void parseTestCase(String filename) {

    try {
        File file = new File(filename);

        String testCase = new Scanner(file).useDelimiter("\\Z").next();
        tcCaretOffset = testCase.indexOf('^');

        testCase = testCase.replaceAll("\\^", "");
        
        ModelicaScanner scanner = new ModelicaScanner(
                new StringReader(testCase));
        ModelicaParser parser = new ModelicaParser();

        tcRoot = (SourceRoot) parser.parse(scanner);

        Maybe<? extends ASTNode<?>> result = 
            tcRoot.getNodeAt(new Document(testCase), tcCaretOffset);
        
        tcDocument = new Document(testCase);
        int lineNbr = tcDocument.getLineOfOffset(tcCaretOffset);
        int column = tcCaretOffset - tcDocument.getLineOffset(lineNbr);

        assert result.value() != null : 
            String.format("Unable to get ASTNode at (row:%d col:%d) in %s", 
                    lineNbr, column, filename);

        tcEnclosingClass = (ClassDecl)result.value();

    } catch (Exception e) {
        e.printStackTrace();
        throw new RuntimeException("Failed to parse test case");
    }

}

public void testCompletions() {
    
    parseTestCase("test_data/test.mo"); //sets members tcX
    
    Completions c = new Completions(tcRoot);
    Pair<String, String> context = c.getContext(tcDocument, tcCaretOffset);
    
    InstClassDecl encInst = new Lookup(tcRoot)
        .instClassAt(tcDocument, tcCaretOffset).value(); 
    
    String name = context.fst() + "." + context.snd();
    if (name.startsWith(".")) name = name.substring(1);
    InstAccess dotAccess = CompletionUtil.createDotAccess(name.split("\\."))
        .newInstAccess();
    
    Maybe<InstNode> node = Maybe.Nothing(InstNode.class)
        .orElse(new Lookup(null).tryAddComponentDecl(encInst, dotAccess))
        .orElse(new Lookup(null).tryAddClassDecl(encInst, dotAccess));
    
    if (node.isNull()) {
        System.out.println("FAIL");
        return; 
    }
    
    for (InstNode n : node.value().completionProposals(
            new CompletionFilter(""))) 
        System.out.println(n.name());
    
}

public void testBorked() {
    parseTestCase("test_data/test.mo"); //sets members tcX
    
    //tcRoot.printASTqq("");
    
    tcRoot.prettyPrint(System.out, "");
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
        
}

public static void main(String[] args) throws Throwable {
    new NameCompleteTest().testBorked();
}
}
