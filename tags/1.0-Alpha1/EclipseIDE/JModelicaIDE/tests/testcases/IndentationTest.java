package testcases;

import junit.framework.TestCase;

import org.jmodelica.ide.editor.Indent;
import org.jmodelica.ide.indent.Anchor;
import org.jmodelica.ide.scanners.generated.IndentationHintScanner;

public class IndentationTest extends TestCase {

static IndentationHintScanner ihs;

static class IndentTestCase {
    String text, anchorstart, reference, sinkRef;
    Indent wantedIndent;
    
    public IndentTestCase(String text, Indent wanted, String start, String ref) {
        this(text, wanted, start, ref, null);
    }
    
    public IndentTestCase(String text, Indent wanted, String start, String ref, String sinkRef) {
        this.text = text;
        this.anchorstart = start;
        this.reference = ref;
        this.wantedIndent = wanted;
        this.sinkRef = sinkRef;
    }
}

static IndentTestCase[] testCases = { 
    /* indentation tests */
    /* 0 */     new IndentTestCase("Real\n", Indent.INDENT, "eal", "Real"),
    /* 1 */     new IndentTestCase("model mqadfdsa\n", Indent.INDENT, " m", "model"),
    /* 2 */     new IndentTestCase("model m\nReal r", Indent.INDENT, "eal r", "Real"),
    /* 3 */     new IndentTestCase("model m\nReal r;\t", Indent.SAME, "\t", "Rea"),
    /* 4 */     new IndentTestCase("model m\n  model q\n     Real r;\t", Indent.SAME, "\t", "Real"),
    /* 5 */     new IndentTestCase("model m /*   ", Indent.COMMENT, "   ", "/*"),
    /* 6 */     new IndentTestCase("model m /* test", Indent.SAME, "est", "test"),
    /* 7 */     new IndentTestCase("model m /* test\n     line2", Indent.SAME, "ine2", "line2"),
    /* 8 */     new IndentTestCase("mnodel m /* test\n     line2\nline3", Indent.SAME, "ine3", "line3"),
    /* 9 */     new IndentTestCase("model m model q", Indent.INDENT, " q", "model q"),
    /* 10 */    new IndentTestCase("model m model q end   ", Indent.INDENT, "   ", "end"),
    /* 11 */    new IndentTestCase("model m \n model q end q", Indent.INDENT, " q", "end q"),
    /* 12 */    new IndentTestCase("model m model q end q;\t", Indent.SAME, "\t", "model q"),
    /* 13 */    new IndentTestCase("model m \n model q end z;\t", Indent.SAME, "", "model q"),
    /* 14 */    new IndentTestCase("model /*testing*/ m", Indent.INDENT, " m", "model"),
    /* 15 */    new IndentTestCase("model /*testing*/ m end /* test */ m;\t", Indent.SAME, "\t", "model /*"),
    /* 16 */    new IndentTestCase("model /*testing*/ m end /*!!*/\t", Indent.INDENT, "\t", "end "),
    /* 17 */    new IndentTestCase("model /*testing*/ m end /* test ", Indent.SAME, "est", "test"),
    /* 18 */    new IndentTestCase("model 'apaa", Indent.NONE, "apaa", "'apaa"),
    /* 19 */    new IndentTestCase("model 'apaa'\t", Indent.INDENT, "\t", "model '"),
    /* 20 */    new IndentTestCase("model 'ap\n\na\na\t\f'\t", Indent.INDENT, "\t", "model"),
    /* 21 */    new IndentTestCase("model 'apa/*not a comment", Indent.NONE, "apa", "'apa"),
    /* 22 */    new IndentTestCase("model \"teststr", Indent.NONE, "teststr", null),
    /* 23 */    new IndentTestCase("model \"teststring\" m", Indent.INDENT, " m", "model"),
    /* 24 */    new IndentTestCase("model 'test' \n  Real r;\t", Indent.SAME, "\t", "Real"),
    /* 25 */    new IndentTestCase("model 'test'\n\n\nReal r;end 'test'", Indent.INDENT, " 'test", "end"),
    /* 26 */    new IndentTestCase("model 'test'\n\nReal r;end 'test';\t", Indent.SAME, "\t", "model"),
    /* 27 */    new IndentTestCase("model q model z model w end w;\t", Indent.SAME, "\t", "model w"),
    /* 28 */    new IndentTestCase("model q model z model w end w; end z;\t", Indent.SAME, "\t", "model z"),
    /* 29 */    new IndentTestCase("model q \nReal r;\nmodel z end z;\t", Indent.SAME, "\t", "model z"),
    /* 30 */    new IndentTestCase("model q \nReal r; /* comment */", Indent.SAME, "", "Real"),
    /* 31 */    new IndentTestCase("model q \nReal r; \n Int i;\t", Indent.SAME, "\t", "Int"),
    /* 32 */    new IndentTestCase("model q \n Real r; \n Int i", Indent.INDENT, "nt i", "Int"),
    /* 33 */    new IndentTestCase("model q \n Real r; \n /* comment */\t", Indent.SAME, "\t", "Real"),
    /* 34 */    new IndentTestCase("model q \n Real r \n /* comment */\t", Indent.INDENT, "\t", "Real"),
    /* 35 */    new IndentTestCase("model q \n Real r;;;;;; \n /* comment */\t", Indent.SAME, "\t", "Real"),
    /* 36 */    new IndentTestCase("model q \n Real r;\n     Int i;;;;;\n /* comment */\t", Indent.SAME, "\t", "Int"),
    /* 37 */    new IndentTestCase("model m \n  Real \n r;\t", Indent.SAME, "\t", "Real"),
    /* 38 */    new IndentTestCase("model m \n  Real \n r qwz", Indent.SAME, " qwz", "r qwz"),
    /* 39 */    new IndentTestCase("model m \n  Real \n r \n q\t", Indent.SAME, "\t", "q\t"),
    /* 40 */    new IndentTestCase("model m /* comment \n */\t", Indent.INDENT, "\t", "model"),
    /* 41 */    new IndentTestCase("model m\nReal r;end m;\t", Indent.SAME, "\t", "model"),
    /* 42 */    new IndentTestCase("model m annotation ", Indent.INDENT, " ", "anno"),
    /* 43 */    new IndentTestCase("model m annotation()\t", Indent.INDENT, "\t", "model"),
    /* 44 */    new IndentTestCase("model m annotation ()\t", Indent.INDENT, "\t", "model"),
    /* 45 */    new IndentTestCase("model m annotation (()bladibal/*sdklj*/(()))\t", Indent.INDENT, "\t", "model"),
    /* 46 */    new IndentTestCase("model m annotation (", Indent.INDENT, " (", "anno"),
    /* 47 */    new IndentTestCase("model m annotation ( jjj \n iii!", Indent.SAME, "ii!", "iii!"),
    /* 48 */    new IndentTestCase("model m annotation ( jjj \n iii\n\n\n)\t", Indent.INDENT, "\t", "model m"),
    /* 49 */    new IndentTestCase("model m \n for i in 1:size(b,1) loop", Indent.INDENT, " i in", "for i"),
    /* 50 */    new IndentTestCase("model m \n for i in 1:size(b,1) loop\n result := 3;\t", Indent.SAME, "\t", "result"),
    /* 51 */    new IndentTestCase("model m \n for i in 1:size(b,1) loop\n result := 3;\nend for;\t", Indent.SAME, "\t", "for"),
    /* 52 */    new IndentTestCase("model m annotation ( \"string\nin annot", Indent.NONE, null, null),
    /* 53 */    new IndentTestCase("model m annotation ( \"string\nin annot\"\t", Indent.INDENT, "\t", "annotation"),
    /* 54 */    new IndentTestCase("model m annotation ( /*   comment in annot", Indent.SAME, "omment", "comment"),
    /* 55 */    new IndentTestCase("model m annotation ( /*   comment in annot */\t", Indent.INDENT, "\t", "annotation"),
    /* 56 */    new IndentTestCase("model m annotation\n(  \n   bla /*   comment in annot */\t", Indent.SAME, "\t", "bla"),
    /* 57 */    new IndentTestCase("model m\n  /* comment */\n  Real r;\t", Indent.SAME, "\t", "Real"),
    /* 58 */    new IndentTestCase("model m\n  annotation(x=20)\t", Indent.INDENT, "\t", "model"),
    /* 59 */    new IndentTestCase("model m\n  annotation(x=20);\t", Indent.INDENT, "\t", "model"),
    /* 60 */    new IndentTestCase("model m\n  annotation(x=20\ny=30\nz=40", Indent.SAME, "=40", "z=40"),
    /* 61 */    new IndentTestCase("model q\n  /* comment */ \n annotation ()\t", Indent.INDENT, "\t", "model"),
    /* 62 */    new IndentTestCase("model m\nReal r;equation", Indent.SAME, "equation", "Real"),
    /* 63 */    new IndentTestCase("model m\nReal r;\n\n\nequation\n", Indent.SAME, "\n\n\nequation", "Real"),
    /* 64 */    new IndentTestCase("model m model q end q end m; end z;\t", Indent.SAME, "\t", "model m"),  
    /* 65 */    new IndentTestCase("\nmodel m model q end q end m; end z;\t", Indent.SAME, "\t", "model m"),  
    /* sink tests */
    /* 66 */    new IndentTestCase("model m\nend m;\t", Indent.SAME, "\t", "model m", "model m"),
    /* 67 */    new IndentTestCase("model m model q \nend q;\t", Indent.SAME, "\t", "model q", "model q"),
};

public void testIndent() {
    for (int i = 0; i < testCases.length; i++) {
        
        IndentTestCase tc = testCases[i];
        ihs.analyze(tc.text);

        Anchor anchor = ihs.ancs.anchorAt(tc.text.length()+1);
        Anchor sink = ihs.ancs.sinkAt(tc.text.length()+1);
        
        StringBuilder bob = new StringBuilder();
        
        bob.append("TestCase: #" + i + "failed\n");
        bob.append(tc.text + "\n");

        bob.append("anchor.offset: " + anchor.offset + "\n");
        bob.append("anchor.ref: " + anchor.reference + "\n");
        
        bob.append("anchor start:\n");
        bob.append(String.format("got:%s wanted:%s\n", anchor.indent, tc.wantedIndent));
        bob.append(String.format("got:%s wanted:%s\n",
                tc.text.substring(anchor.offset),
                tc.anchorstart));
        
        bob.append("reference:");
        bob.append(String.format("got:%s wanted:%s\n",
                anchor.reference < 0 ? "no indent" : 
                        tc.text.substring(anchor.reference),
                tc.reference));
    
        bob.append("sink:");
        bob.append(String.format("got:%s wanted:%s\n",
                tc.text.substring(sink.reference),
                tc.sinkRef));

        if (tc.wantedIndent != null) {
            assertEquals(bob.toString(), tc.wantedIndent, anchor.indent);
        }
        if (tc.anchorstart != null) {
            assertTrue(bob.toString(), tc.text.substring(anchor.offset).startsWith(tc.anchorstart));
        }
        if (tc.reference != null) {
            assertTrue(bob.toString(), tc.text.substring(anchor.reference).startsWith(tc.reference));
        }
        if (tc.sinkRef != null) {
            assertTrue(bob.toString(), tc.text.substring(sink.reference).startsWith(tc.sinkRef));
        }
    }    
}

protected void setUp() throws Exception {
    super.setUp();
    ihs = new IndentationHintScanner();
}



}
