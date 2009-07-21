package testcases;

import junit.framework.TestCase;

import org.eclipse.jface.text.Document;
import org.jmodelica.ide.indent.IndentedSection;
import org.jmodelica.ide.scanners.generated.IndentationHintScanner;


public class IndentedSectionTest extends TestCase {
    String testIndentData = 
        "     model m\n" +
        "real r;\n" +
        "        model q\n" +
        "            real r;\n" +
        "end q;\n" +
        "       int i;\n" +
        "           end m;";
    String testIndentStringData = 
        "\"bla\n" +
        "     bla\n" +
        "bla\n" +
        "   bla\"";
    
    public void testIndent() {
        IndentedSection.tabWidth = 4;
        IndentedSection.tabbed = true;
        IndentationHintScanner ihs = new IndentationHintScanner();
        
        String tmp = new IndentedSection(testIndentData).toString();
        
        ihs.analyze(tmp);

        assertEquals(new IndentedSection(testIndentData).indent(
                    ihs.ancs.bindTabWidth(IndentedSection.tabWidth, 
                            new Document(tmp))).toString(),
                "model m\n" +
                "\treal r;\n" +
                "\tmodel q\n" +
                "\t\treal r;\n" +
                "\tend q;\n" +
                "\tint i;\n" +
                "end m;");
    }
    
    public void testIndentPartial() {
        IndentedSection.tabWidth = 4;
        IndentedSection.tabbed = true;
        IndentationHintScanner ihs = new IndentationHintScanner();
        
        String tmp = new IndentedSection(testIndentData).toString();
        ihs.analyze(tmp);

        assertEquals(
                "\t model m\n" +
                "real r;\n" +
                "model q\n" +
                "\treal r;\n" +
                "end q;\n" +
                "\t   int i;\n" +
                "\t\t   end m;",
                new IndentedSection(testIndentData).
                indent(ihs.ancs.bindTabWidth(IndentedSection.tabWidth, 
                        new Document(tmp)), 2, 4).toString());
        assertEquals(
                "\t model m\n" +
                "\t\t real r;\n" +
                "\t\t model q\n" +
                "\t\t\t real r;\n" +
                "end q;\n" +
                "\t   int i;\n" +
                "\t\t   end m;",
                new IndentedSection(testIndentData).
                    indent(ihs.ancs.bindTabWidth(IndentedSection.tabWidth, 
                            new Document(tmp)), 1, 4).toString());
    }

    public void testIndentString() {
        
        IndentedSection.tabbed = false;
        IndentationHintScanner ihs = new IndentationHintScanner();
        String tmp = new IndentedSection(testIndentStringData).toString();
        ihs.analyze(tmp);

        assertEquals(
                testIndentStringData, 
                new IndentedSection(testIndentStringData).
                indent(ihs.ancs.bindTabWidth(IndentedSection.tabWidth, 
                        new Document(tmp))).toString());
        
    }
    
    public void testAnnotations() {
        IndentedSection.tabbed = false;
        IndentedSection.tabWidth = 2;
        String in = 
            "model m\n" +
            "  annotation (\n" +
            "x = 10,\n" +
            "y = Point(\n" +
            "a = 1,\n" +
            "b = f(\n" +
            ")),\n" +
            "k = 10);";
        String wanted = 
            "model m\n" +
            "  annotation (\n" +
            "              x = 10,\n" +
            "              y = Point(\n" +
            "               a = 1,\n" +
            "               b = f(\n" +
            "              )),\n" +
            "              k = 10);";
        testInd(in, wanted);
    }
    
    public void testInd(String in, String wanted) {

        IndentationHintScanner ihs = new IndentationHintScanner();
        String tmp = new IndentedSection(in).toString();
        ihs.analyze(tmp);
        
        String indented = new IndentedSection(in).
        indent(ihs.ancs.bindTabWidth(IndentedSection.tabWidth, 
                new Document(tmp))).toString();
        
        assertEquals(wanted, indented);
   }

    public void testSpacify() {
        IndentedSection.tabWidth = 4;
        assertEquals(IndentedSection.spacify("\t  test\n" +
        		                             "  \ttest"),
                "      test\n" +
                "    test");
        assertEquals(IndentedSection.spacify(""), "");
    }
    
    public void testTabify() {
        IndentedSection.tabWidth = 5;
        assertEquals(IndentedSection.tabify("       test"), "\t  test");
    }
    
    public void testCountIndent() {
        IndentedSection.tabWidth = 4;
        assertEquals(IndentedSection.countIndent(""), 0);
        assertEquals(IndentedSection.countIndent("  "), 2);
        assertEquals(IndentedSection.countIndent("\t"), 4);
        assertEquals(IndentedSection.countIndent("  \t"), 4);
        assertEquals(IndentedSection.countIndent("test"), 0);
        IndentedSection.tabWidth = 10;
        assertEquals(IndentedSection.countIndent("         \ttest"), 10);
        assertEquals(IndentedSection.countIndent("          \ttest"), 20);
    }
    
}
