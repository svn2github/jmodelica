package org.jastadd.ed.core.service.errors;

/**
 * Error object should implement this interface to communicate errors to
 * the IDE. Required by the core.compiler.ICompiler interface.
 * @author emma
 *
 */
public interface IError {
	
	/*
	 * Previously used error marker:
	 * "org.eclipse.ui.workbench.texteditor.error";
	 * Previously used warning marker:
	 * "org.eclipse.ui.workbench.texteditor.warning";
	 */
	
	public static final String MARKER_ID 			= "org.jastadd.ed.marker";
	public static final String SYNTAX_MARKER_ID 	= "org.jastadd.ed.marker.syntax";
	
	// kind
	public static class Kind {
		private Kind() {}
		public static final Kind LEXICAL	= new Kind();;
		public static final Kind SYNTACTIC 	= new Kind();
		public static final Kind SEMANTIC 	= new Kind();
		public static final Kind OTHER 		= new Kind();
	}
	
	// severity
	public static class Severity {
		public final int value;
		private Severity(int value) {this.value = value;}
		public static final Severity ERROR		= new Severity(2);
		public static final Severity WARNING	= new Severity(1);
		public static final Severity INFO		= new Severity(0);
	}
	
	public String getMessage();
	
	/**
	 * Severity of error. One of error or warning as provided
	 * by attributes in this interface
	 */
	public IError.Severity getSeverity();
	
	/**
	 * Kind of error as provided by the attributes in this interface
	 * lexical, syntactic, semantic or other
	 */
	public IError.Kind getKind();
	
	/**
	 * The line where the error starts
	 */
	public int getStartLine();
	
	/**
	 * The offset where the error starts
	 */
	public int getStartOffset();

	/**
	 * The offset where the error ends
	 */
	public int getEndOffset();
	
}

