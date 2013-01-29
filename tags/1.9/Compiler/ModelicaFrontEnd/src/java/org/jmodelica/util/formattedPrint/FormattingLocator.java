package org.jmodelica.util.formattedPrint;

public class FormattingLocator {
	
	public enum Locator {
		START,
		END,
	}
	
	public final Locator locator;
	public final int line;
	public final int col;

	public FormattingLocator(Locator locator, int line, int col) {
		this.locator = locator;
		this.line = line;
		this.col = col;
	}
	
}
