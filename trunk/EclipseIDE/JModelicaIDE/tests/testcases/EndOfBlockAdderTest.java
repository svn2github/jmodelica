package testcases;

import java.io.File;
import java.util.Scanner;

import junit.framework.TestCase;

import org.eclipse.jface.text.Document;
import org.jmodelica.ide.editor.editingstrategies.EndOfBlockAdder;
import org.jmodelica.ide.indent.IndentedSection;


public class EndOfBlockAdderTest extends TestCase {

public void testEndOfBlockAdder(String filename) throws Exception {

    String doc = new Scanner(new File(filename)).useDelimiter("\\Z").next();

    int caretOffset = doc.indexOf('^');
    Document d = new Document(doc.replace("^", ""));

    EndOfBlockAdder eoba = new EndOfBlockAdder();
    eoba.addEndIfNotPresent("end p2;", d, caretOffset);

    
    
    assertEquals(new Scanner(new File(filename + ".wanted"))
            .useDelimiter("\\Z").next(), d.get());

}

public void testEndOfBlockAdder() throws Exception {
    IndentedSection.tabWidth = 4;
    IndentedSection.lineSep = "\r\n";
    IndentedSection.tabbed = true;
    new EndOfBlockAdderTest() .testEndOfBlockAdder(
            "test_data/editing_strategies/end_of_block_adder1.mo");
    new EndOfBlockAdderTest() .testEndOfBlockAdder(
            "test_data/editing_strategies/end_of_block_adder2.mo");
}
}
