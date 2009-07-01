package org.jmodelica.ide.indent;


import org.jmodelica.ide.scanners.generated.IndentationHintScanner;
import org.jmodelica.ide.scanners.generated.IndentationHintScanner.Anchor;
import org.jmodelica.ide.scanners.generated.IndentationHintScanner.Indent;
import org.jmodelica.ide.scanners.generated.IndentationHintScanner.Sink;

/**
 * 
 * @author philip
 *
 */
public class IndentationTestCases {
	
	static final IndentationHintScanner ihs = new IndentationHintScanner();
	
	static class TestCase {
		String text, ref, refSink;
		Indent wantedIndent;
		
		public TestCase(String text, Indent wanted, String ref) {
			this(text, wanted, ref, null);
		}
		
		public TestCase(String text, Indent wanted, String ref, String sink) {
			this.text = text;
			this.ref = ref;
			this.wantedIndent = wanted;
			this.refSink = sink;
		}
	}
	
	static TestCase[] testCases = { 
		/* indentation tests */
		/* 0 */     new TestCase("", Indent.SAME, ""),
		/* 1 */     new TestCase("model m\n", Indent.INDENT, "model m"),
		/* 2 */		new TestCase("model m\nReal r ", Indent.INDENT, "Real r"),
		/* 3 */		new TestCase("model m\nReal r;", Indent.SAME, "Real r"),
		/* 4 */		new TestCase("model m\n  model q\n     Real r;", Indent.SAME, "Real r"),
		/* 5 */		new TestCase("model m /*   ", Indent.COMMENT, "/*"),
		/* 6 */		new TestCase("model m /* test", Indent.SAME, "test"),
		/* 7 */		new TestCase("model m /* test\n     line2", Indent.SAME, "line2"),
		/* 8 */		new TestCase("model m /* test\n     line2\nline3", Indent.SAME, "line3"),
		/* 9 */		new TestCase("model m model q", Indent.INDENT, "model q"),
		/* 10 */	new TestCase("model m model q end ", Indent.INDENT, "end"),
		/* 11 */	new TestCase("model m \n model q end q", Indent.INDENT, "end q"),
		/* 12 */	new TestCase("model m model q end q;", Indent.INDENT, "model m"),
		/* 13 */	new TestCase("model m \n  model q end z;", Indent.SAME, "model q"),
		/* 14 */	new TestCase("model /*testing*/ m", Indent.INDENT, "model /*"),
		/* 15 */	new TestCase("model /*testing*/ m end /* test */ m;", Indent.SAME, "model /*"),
		/* 16 */	new TestCase("model /*testing*/ m end /* test */ ", Indent.INDENT, "end /*"),
		/* 17 */	new TestCase("model /*testing*/ m end /* test ", Indent.SAME, "test"),
		/* 18 */	new TestCase("model 'apaa", Indent.NONE, "'apaa"),
		/* 19 */	new TestCase("model 'apaa'", Indent.INDENT, "model"),
		/* 20 */	new TestCase("model 'apaa'", Indent.INDENT, "model"),
		/* 21 */    new TestCase("model 'apa/*not a comment", Indent.NONE, "'apa"),
		/* 22 */    new TestCase("model \"teststr", Indent.NONE, "\"teststr"),
		/* 23 */    new TestCase("model \"teststring\" m", Indent.INDENT, "model"),
		/* 24 */    new TestCase("model 'test' \n  Real r;", Indent.SAME, "Real"),
		/* 25 */    new TestCase("model 'test'\n\n\nReal r;end 'test'", Indent.INDENT, "end"),
		/* 26 */    new TestCase("model 'test'\n\nReal r;end 'test';", Indent.SAME, "model"),
		/* 27 */    new TestCase("model q model z model w end w;", Indent.INDENT, "model z"),
		/* 28 */    new TestCase("model q model z model w end w; end z;", Indent.INDENT, "model q"),
		/* 29 */    new TestCase("model q \nReal r;\nmodel z end z;", Indent.SAME, "model z"),
		/* 30 */    new TestCase("model q \nReal r; /* comment */", Indent.SAME, "Real"),
		/* 31 */    new TestCase("model q \nReal r; \n Int i;", Indent.SAME, "Int"),
		/* 32 */    new TestCase("model q \n Real r; \n Int i", Indent.INDENT, "Int"),
		/* 33 */    new TestCase("model q \n Real r; \n /* comment */", Indent.SAME, "Real"),
		/* 34 */    new TestCase("model q \n Real r \n /* comment */", Indent.INDENT, "Real"),
		/* 35 */    new TestCase("model q \n Real r;;;;;; \n /* comment */", Indent.SAME, "Real"),
		/* 36 */    new TestCase("model q \n Real r;\n     Int i;;;;;\n /* comment */", Indent.SAME, "Int"),
		/* 37 */    new TestCase("model m \n   Real \n r;", Indent.SAME, "Real"),
		/* 38 */    new TestCase("model m \n  Real \n r ", Indent.SAME, "r"),
		/* 39 */    new TestCase("model m \n  Real \n r \n q", Indent.SAME, "q"),
		/* 40 */    new TestCase("model m /* comment \n */", Indent.INDENT, "model"),
		/* 41 */    new TestCase("model m\nReal r;end m;", null, null, "model m"),
		/* 42 */    new TestCase("model m annotation", Indent.INDENT, "annotation"),
		/* 43 */    new TestCase("model m annotation()", Indent.INDENT, "model"),
		/* 44 */    new TestCase("model m annotation ()", Indent.INDENT, "model"),
		/* 45 */    new TestCase("model m annotation (()bladibal/*sdklj*/(()))", Indent.INDENT, "model"),
		/* 46 */    new TestCase("model m annotation (", Indent.INDENT, "annot"),
		/* 47 */    new TestCase("model m annotation ( jjj \n iii", Indent.SAME, "iii"),
		/* 48 */    new TestCase("model m annotation ( jjj \n iii\n\n\n)", Indent.INDENT, "model"),
		/* 49 */    new TestCase("model m \n for i in 1:size(b,1) loop", Indent.INDENT, "for"),
		/* 50 */    new TestCase("model m \n for i in 1:size(b,1) loop\n result := 3;", Indent.SAME, "result"),
		/* 51 */    new TestCase("model m \n for i in 1:size(b,1) loop\n result := 3;\nend for;", Indent.SAME, "for"),
		/* 52 */    new TestCase("model m annotation ( \"string\nin annot", Indent.NONE, null),
		/* 53 */    new TestCase("model m annotation ( \"string\nin annot\"", Indent.INDENT, "annot"),
		/* 54 */    new TestCase("model m annotation ( /*   comment in annot", Indent.SAME, "comment"),
		/* 55 */    new TestCase("model m annotation ( /*   comment in annot */", Indent.INDENT, "annot"),
		/* 56 */    new TestCase("model m annotation\n(  \n   bla /*   comment in annot */", Indent.SAME, "bla"),
		/* 57 */    new TestCase("model m\n  /* comment */\n  Real r;", Indent.SAME, "Real"),
		/* 58 */    new TestCase("model m\n  annotation(x=20)", Indent.INDENT, "model"),
		/* 59 */    new TestCase("model m\n  annotation(x=20);", Indent.INDENT, "model"),
		/* 60 */    new TestCase("model q\n  /* comment */ \n annotation ()", Indent.INDENT, "model"),
		/* sink tests */
		/* 61 */    new TestCase("model m\nReal r; equation", null, null, "model m"),
		/* 62 */    new TestCase("model m\nReal r;\n\n\nequation", null, null, "model m"),
		/* 63 */    new TestCase("model m\nReal r;\n\n\n", null, null, null),
		/* 64 */    new TestCase("model m\nReal r;\n\n\n", null, null, null),
	};
	
	static int i = -1;
	public static void testIndent(TestCase tc) {
		//System.out.println("------------------");
		i++;
		ihs.analyze(tc.text);
		Anchor anchor = ihs.anchorAt(tc.text.length());
		Sink tmp = ihs.sinkAt(0, tc.text.length());
		Anchor sink = tmp == null ? null : tmp.reference;
		if (!(
			(tc.wantedIndent == null || anchor.indent == tc.wantedIndent) &&
			(tc.ref == null          || tc.text.substring(anchor.offset).startsWith(tc.ref)) &&
			(tc.refSink == null || sink == null && tc.refSink == null || tc.text.substring(sink.offset).startsWith(tc.refSink))
		  )) {
			System.out.print(i + ":\t");
			System.out.println("FAILED");
			System.out.println(tc.text);
			if (anchor != null) {
				System.out.printf("got:%s wanted:%s\n", anchor.indent, tc.wantedIndent);
				System.out.printf("got:%s wanted:%s\n",
					tc.text.substring(anchor.offset),
					tc.ref);
			}
			if (sink != null) 
				System.out.printf("got:%s wanted:%s\n",
					tc.text.substring(sink.offset),
					tc.refSink);
		}
	}
	
	
	public static void main(String[] args) {
		System.out.println("Starting tests...");
		for (TestCase tc : testCases) {
			testIndent(tc);
		}
		System.out.println("All tests OK, unless failed tests listed above. ");
	}
}
