package testcases;

import junit.framework.TestCase;

import org.eclipse.jface.text.Document;
import org.jmodelica.generated.scanners.IndentationHintScanner;
import org.jmodelica.ide.indent.IndentedSection;


public class IndentedSectionTest extends TestCase {

    public void testInd(String in, String wanted) {

        IndentationHintScanner ihs = new IndentationHintScanner();
        String tmp = new IndentedSection(in).toString();
        ihs.analyze(tmp);
        
        String indented = new IndentedSection(in).
        indent(ihs.ancs.bindEnv(new Document(tmp), 
                IndentedSection.tabWidth)).toString();
        
        assertEquals(wanted, indented);
   }

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
                    ihs.ancs.bindEnv(new Document(tmp), 
                            IndentedSection.tabWidth)).toString(),
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
                indent(ihs.ancs.bindEnv(new Document(tmp), 
                        IndentedSection.tabWidth), 2, 4).toString());
        assertEquals(
                "\t model m\n" +
                "\t\t real r;\n" +
                "\t\t model q\n" +
                "\t\t\t real r;\n" +
                "end q;\n" +
                "\t   int i;\n" +
                "\t\t   end m;",
                new IndentedSection(testIndentData).
                    indent(ihs.ancs.bindEnv(new Document(tmp), 
                            IndentedSection.tabWidth), 1, 4).toString());
    }

    public void testIndentString() {
        
        IndentedSection.tabbed = false;
        IndentationHintScanner ihs = new IndentationHintScanner();
        String tmp = new IndentedSection(testIndentStringData).toString();
        ihs.analyze(tmp);

        assertEquals(
                testIndentStringData, 
                new IndentedSection(testIndentStringData).
                indent(ihs.ancs.bindEnv(new Document(tmp), 
                        IndentedSection.tabWidth)).toString());
        
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
    
    public void testStringsInAnnotations() {
        IndentedSection.tabWidth = 4;
        IndentedSection.tabbed = true;
        String test =
            "model m\n"+
            "annotation (x = Test(\n"+
            "        a = \"test\",\n"+
            "       b = \"test\"));\n"+
            "end m;";
            
        String wanted = 
            "model m\n"+
            "\tannotation (x = Test(\n"+
            "\t\t\t\t a = \"test\",\n"+
            "\t\t\t\t b = \"test\"));\n"+
            "end m;";

        testInd(test, wanted);
    }
    
    public void testWindows() {

        IndentedSection.lineSep = "\r\n";
        
        String expected = 
            "     model m\r\n" +
            "real r;\r\n" +
            "        model q\r\n" +
            "            real r;\r\n" +
            "end q;\r\n" +
            "       int i;\r\n" +
            "           end m;";
        
        String wanted = 
        "model m\r\n" +
        "\treal r;\r\n" +
        "\tmodel q\r\n" +
        "\t\treal r;\r\n" +
        "\tend q;\r\n" +
        "\tint i;\r\n" +
        "end m;";
        
        testInd(expected, wanted);
    }
    
    public void testMac() {

        IndentedSection.lineSep = "\r";
        
        String expected = 
            "     model m\r" +
            "real r;\r" +
            "        model q\r" +
            "            real r;\r" +
            "end q;\r" +
            "       int i;\r" +
            "           end m;";
        
        String wanted = 
        "model m\r" +
        "\treal r;\r" +
        "\tmodel q\r" +
        "\t\treal r;\r" +
        "\tend q;\r" +
        "\tint i;\r" +
        "end m;";
        
        testInd(expected, wanted);
    }    
}
