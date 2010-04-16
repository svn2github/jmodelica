package testcases;

import java.io.File;
import java.io.StringReader;
import java.util.Arrays;
import java.util.Scanner;
import java.util.Set;
import java.util.TreeSet;

import org.eclipse.jface.text.Document;
import org.jmodelica.ide.OffsetDocument;
import org.jmodelica.ide.helpers.Maybe;
import org.jmodelica.ide.indent.DocUtil;
import org.jmodelica.modelica.compiler.ClassDecl;
import org.jmodelica.modelica.compiler.SourceRoot;
import org.jmodelica.modelica.parser.ModelicaParser;
import org.jmodelica.modelica.parser.ModelicaScanner;

public class ModelicaTestCase {
    
    static final String FAIL = "<<FAILURE: in test %d>>";

    public OffsetDocument document;
    public SourceRoot root;
    public ClassDecl enclosingClass;
    
    public ModelicaTestCase(String filename) {
        try {
            File file = new File(filename);
            
            if (!file.exists()) {
                System.out.printf("File not found: %s\n", 
                        file.getAbsolutePath());
                return;
            }

            String testCase = new Scanner(file).useDelimiter("\\Z").next();
            int caretOffset = testCase.indexOf('^');

            testCase = testCase.replaceAll("\\^", "");
            
            ModelicaScanner scanner = new ModelicaScanner(
                    new StringReader(testCase));
            ModelicaParser parser = new ModelicaParser();

            root = (SourceRoot) parser.parse(scanner);
            document = new OffsetDocument(testCase, caretOffset);

            if (caretOffset < 0) {
                System.out.println("^ not found. not setting related variables. ");
                return;
            }
            
            Maybe<ClassDecl> result 
                    = root.getClassDeclAt(new Document(testCase), caretOffset);
            
            int lineNbr = document.getLineOfOffset(caretOffset);
            int column = caretOffset - document.getLineOffset(lineNbr);

            assert result.hasValue() : 
                String.format("Unable to get ASTNode at (row:%d col:%d) in %s", 
                        lineNbr, column, filename);

            enclosingClass = result.value();

        } catch (Exception e) {
            e.printStackTrace();
            throw new RuntimeException("Failed to parse test case");
        }
    }

    /**
     * Parses test cases where expected output is written in a comment on the first
     * line of the test case source code file, on either of two formats:
     * 
     * // Nothing (if nothing is expected) 
     * // Just 'id' (if class with name 'id' is expected.
     * 
     */
    public Set<String> expectedSet() {
        String expected = 
            new DocUtil(document).getLine(0);

        if (expected.matches("//\\s*Nothing.*")) {
            return new TreeSet<String>();
        }
        
        String name = 
            expected.substring(expected.indexOf("Just") + 4).trim();
        
        return 
            new TreeSet<String>(
                Arrays.asList(name.split(",\\s*")));
    }

    
    public Maybe<String> expected() {
        Set<String> set = expectedSet();
        return Maybe.guard(new DocUtil(document).getLine(0), !set.isEmpty());
    }

    /**
     * Counts number of test cases matching format % i, for i = 1..
     */
    public static int nbrTestCasesMatching(String format) {
        
        int i = 0;
        while ((new File(String.format(format, i+1))).exists())
            i++;
        return i;
        
    }
    

}