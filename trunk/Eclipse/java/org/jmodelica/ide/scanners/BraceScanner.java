package org.jmodelica.ide.scanners;

import java.io.IOException;
import java.io.Reader;
import java.util.LinkedList;

import org.eclipse.jface.text.IDocument;
import org.eclipse.jface.text.IRegion;
import org.eclipse.jface.text.Region;
import org.jmodelica.ide.helpers.DocumentReader;

public abstract class BraceScanner {
	
	protected enum Brace {
		CURLY, PAREN, BRACK
	}

	protected enum Result {
		NONE, MATCH, MISMATCH, EOF
	}
	
	protected int start;

	private DocumentReader reader;
	private LinkedList<Brace> braces;

	public abstract Result yylex() throws IOException;
	protected abstract void reset(Reader reader);
	protected abstract int getLength();
	protected abstract int getOffset();
	protected abstract DocumentReader createReader();

	public BraceScanner() {
		braces = new LinkedList<Brace>();
		reader = createReader();
	}
	
	public IRegion match(IDocument document, int offset) {
		reset(document, offset);
		try {
			if (yylex() == Result.MATCH) {
				Region region = new Region(getOffset(), getLength());
				return region;
			}
		} catch (IOException e) {
		}
		return null;
	}

	public void reset(IDocument document, int offset) {
		start = offset;
		reader.reset(document, offset);
		reset(reader);
		braces.clear();
	}

	protected void addBrace(Brace type) {
		braces.push(type);
	}

	protected Result removeBrace(Brace type) {
		if (braces.isEmpty())
			return Result.MISMATCH;
		Brace match = braces.pop();
		if (type != match)
			return Result.MISMATCH;
		if (braces.isEmpty())
			return Result.MATCH;
		return Result.NONE;
	}
}
