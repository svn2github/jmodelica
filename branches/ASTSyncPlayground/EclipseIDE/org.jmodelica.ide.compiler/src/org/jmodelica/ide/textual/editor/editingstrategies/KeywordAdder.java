package org.jmodelica.ide.textual.editor.editingstrategies;

import java.util.regex.Pattern;

import org.eclipse.jface.text.DocumentCommand;
import org.eclipse.jface.text.IDocument;
import org.jmodelica.ide.indent.DocUtil;

/**
 * Adds end for/if/while/when; when user types for/if/while/when ...
 * 
 * @author philip
 * 
 */

public class KeywordAdder extends EndStatementAdder {

	public final static KeywordAdder instance = new KeywordAdder();

	protected static final String[] KEYWORDS = { "for", "while", "when", "elsewhen", "elseif" };
	// Match if keyword is first non-whitespace on line
	protected static final String TEMPLATE_REGEX = "\\s*%s(\\s.*)?";
	// Match if keyword "if" is first non-whitespace on line and keyword "then" is last
	protected static final String IF_REGEX = "\\s*if\\s.*\\sthen\\s*";
	
	protected static final Pattern[] PATTERNS;
	protected static final String[] END_STR;
	
	static {
		int n = KEYWORDS.length + 1;
		PATTERNS = new Pattern[n];
		END_STR = new String[n];
		int i = 0;
		for (String keyword : KEYWORDS) {
			PATTERNS[i] = Pattern.compile(String.format(TEMPLATE_REGEX, keyword));
			END_STR[i] = String.format("end %s;", keyword.replace("else", ""));
			i++;
		}
		PATTERNS[i] = Pattern.compile(IF_REGEX);
		END_STR[i] = "end if;";
	}

	public void customizeDocumentCommand(IDocument doc, DocumentCommand c) {

		if (!c.text.matches("(\n|\r)\\s*"))
			return;

		String line = new DocUtil(doc).getLinePartial(c.offset);

		for (int i = 0; i < PATTERNS.length; i++) 
			if (PATTERNS[i].matcher(line).matches())
				addEndIfNotPresent(END_STR[i], doc, c);
	}

}
