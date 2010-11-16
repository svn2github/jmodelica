package testcases;

import java.io.File;
import java.util.ArrayList;
import java.util.Set;
import java.util.TreeSet;

import junit.framework.TestCase;
import mock.MockEditor;

import org.jmodelica.ide.compiler.ModelicaCompiler;
import org.jmodelica.ide.helpers.Maybe;
import org.jmodelica.ide.namecomplete.CompletionNode;
import org.jmodelica.ide.namecomplete.CompletionProcessor;
import org.jmodelica.modelica.compiler.SourceRoot;
import org.jmodelica.modelica.compiler.StoredDefinition;

public class NameCompleteTest extends TestCase {

	public void testCompletions(String path) throws Exception {

		BaseModelicaTestCase m = new BaseModelicaTestCase(path);

		CompletionProcessor c = new CompletionProcessor(new MockEditor(path));

		// if whitespace at caret, don't add '.'
		if (!("" + m.document.getChar(m.document.offset - 1)).matches("\\s")) {
			m.document.replace(m.document.offset, 0, ".");
			m.document.offset++;
		}

		SourceRoot root = new ModelicaCompiler().compileDirectory(new File("test_data/test_project/"));

		StoredDefinition testAST = new ModelicaCompiler().compileString(m.document.get());

		root.getProgram().addUnstructuredEntity(testAST);

		ArrayList<CompletionNode> decls = c.suggestedDecls(m.document, new Maybe<SourceRoot>(root));

		Set<String> expected = m.expectedSet();

		Set<String> actual = new TreeSet<String>();
		for (CompletionNode node : decls)
			actual.add(node.completionName());

		assertEquals(String.format(BaseModelicaTestCase.FAIL, path), expected, actual);
	}

	public void testCompletions() throws Exception {
		String format = "test_data/completion/suggestedDecls%d.mo";
		int nbrTestCases = BaseModelicaTestCase.nbrTestCasesMatching(format);

		assertTrue(nbrTestCases > 0);

		for (int i = 0; i <= nbrTestCases; i++) {
			testCompletions(String.format(format, i));
		}
	}

}
