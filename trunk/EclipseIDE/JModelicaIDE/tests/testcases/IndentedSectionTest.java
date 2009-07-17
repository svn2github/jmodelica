package testcases;

import junit.framework.TestCase;

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
    
    public void testIndent() {
        IndentedSection.tabWidth = 4;
        IndentedSection.tabbed = true;
        IndentationHintScanner ihs = new IndentationHintScanner();
        ihs.analyze(new IndentedSection(testIndentData).toString());
        assertEquals(new IndentedSection(testIndentData).indent(
                    ihs.ancs.bindTabWidth(IndentedSection.tabWidth)).toString(),
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
        ihs.analyze(new IndentedSection(testIndentData).toString());        
        String[] tmp = testIndentData.split("\n");

        assertEquals(
                "\t model m\n" +
                "real r;\n" +
                "model q\n" +
                "\treal r;\n" +
                "end q;\n" +
                "\t   int i;\n" +
                "\t\t   end m;",
                new IndentedSection(testIndentData).
                indent(ihs.ancs.bindTabWidth(IndentedSection.tabWidth), 2, 4).toString());
        assertEquals(
                "\t model m\n" +
                "\t\t real r;\n" +
                "\t\t model q\n" +
                "\t\t\t real r;\n" +
                "end q;\n" +
                "\t   int i;\n" +
                "\t\t   end m;",
                new IndentedSection(testIndentData).
                    indent(ihs.ancs.bindTabWidth(IndentedSection.tabWidth), 1, 4).toString());
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
