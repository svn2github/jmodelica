/*
    Copyright (C) 2009 Modelon AB

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, version 3 of the License.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/
package org.jmodelica.ide.error;

import org.eclipse.core.resources.IResource;
import org.jastadd.ed.core.service.errors.IError;

import org.jmodelica.ide.helpers.Util;
import org.jmodelica.modelica.parser.ModelicaScanner;
import org.jmodelica.modelica.parser.ModelicaScanner.Symbol;

public class CompileError implements IError {
	
	private int line;
	private int start;
	private int end;
	private Kind kind;
	private String msg;
	
	public CompileError(String msg, Kind kind, Symbol sym) {
		this.msg = msg;
		this.kind = kind;
		line = Symbol.getLine(sym.getStart());
		start = sym.getOffset();
		end = sym.getEndOffset() + 1;
	}
	
	public CompileError(ModelicaScanner.Exception e) {
		msg = e.getMessage();
		kind = IError.Kind.LEXICAL;
		line = e.line;
		start = e.offset;
		end = start + 1;
	}

	public int getEndOffset() {
		return end;
	}

	public Kind getKind() {
		return kind;
	}

	public int getLine() {
		return line;
	}

	public String getMessage() {
		return msg;
	}

	public Severity getSeverity() {
		return IError.Severity.ERROR;
	}

	public int getStartOffset() {
		return start;
	}

	public void addAsMarkerTo(IResource res) {
		Util.addErrorMarker(res, this);
	}

	@Override
	public int getStartLine() {
		// TODO Auto-generated method stub
		return 0;
	}
}
