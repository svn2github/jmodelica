package org.jmodelica.ide.error;

import org.eclipse.core.resources.IMarker;
import org.eclipse.core.resources.IResource;
import org.jastadd.plugin.compiler.ast.IError;

import org.jmodelica.ide.helpers.Util;
import org.jmodelica.parser.ModelicaScanner;
import org.jmodelica.parser.ModelicaScanner.Symbol;

public class CompileError implements IError {
	
	private int line;
	private int start;
	private int end;
	private int kind;
	private String msg;
	
	public CompileError(String msg, int kind, Symbol sym) {
		this.msg = msg;
		this.kind = kind;
		line = Symbol.getLine(sym.getStart());
		start = sym.getOffset();
		end = sym.getEndOffset() + 1;
	}
	
	public CompileError(ModelicaScanner.Exception e) {
		msg = e.getMessage();
		kind = IError.LEXICAL;
		line = e.line;
		start = e.offset;
		end = start + 1;
	}

	public int getEndOffset() {
		return end;
	}

	public int getKind() {
		return kind;
	}

	public int getLine() {
		return line;
	}

	public String getMessage() {
		return msg;
	}

	public int getSeverity() {
		return IMarker.SEVERITY_ERROR;
	}

	public int getStartOffset() {
		return start;
	}

	public void addAsMarkerTo(IResource res) {
		Util.addErrorMarker(res, this);
	}
}
