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

import org.eclipse.core.resources.IFile;
import org.jastadd.plugin.compiler.ast.IError;
import org.jmodelica.ide.helpers.Util;
import org.jmodelica.modelica.parser.ModelicaScanner;
import org.jmodelica.modelica.parser.ModelicaParser.Terminals;

import beaver.Scanner;
import beaver.Symbol;
import beaver.Parser.Events;

public class CompileErrorReport extends Events {
	
	public static final String[] EXPECTED = new String[Terminals.NAMES.length];
	{
		EXPECTED[Terminals.EOF] = "end-of-file";
		EXPECTED[Terminals.ID] = "identifier";
		EXPECTED[Terminals.STRING] = "string";
		EXPECTED[Terminals.UNSIGNED_NUMBER] = "number";
		EXPECTED[Terminals.UNSIGNED_INTEGER] = "integer";
		EXPECTED[Terminals.SEMICOLON] = "';'";
		EXPECTED[Terminals.COLON] = "':'";
		EXPECTED[Terminals.DOT] = "'.'";
		EXPECTED[Terminals.COMMA] = "','";
		EXPECTED[Terminals.RPAREN] = "'('";
		EXPECTED[Terminals.LPAREN] = "')'";
		EXPECTED[Terminals.RBRACK] = "']'";
		EXPECTED[Terminals.LBRACK] = "'['";
		EXPECTED[Terminals.RBRACE] = "'}'";
		EXPECTED[Terminals.LBRACE] = "'{'";
		EXPECTED[Terminals.PLUS] = "'+'";
		EXPECTED[Terminals.MINUS] = "'-'";
		EXPECTED[Terminals.MULT] = "'*'";
		EXPECTED[Terminals.DIV] = "'/'";
		EXPECTED[Terminals.POW] = "'^'";
		EXPECTED[Terminals.DOTPLUS] = "'.+'";
		EXPECTED[Terminals.DOTMINUS] = "'.-'";
		EXPECTED[Terminals.DOTMULT] = "'.*'";
		EXPECTED[Terminals.DOTDIV] = "'./'";
		EXPECTED[Terminals.DOTPOW] = "'.^'";
		EXPECTED[Terminals.EQUALS] = "'='";
		EXPECTED[Terminals.ASSIGN] = "':='";
		EXPECTED[Terminals.LT] = "'<'";
		EXPECTED[Terminals.LEQ] = "'<='";
		EXPECTED[Terminals.GT] = "'>'";
		EXPECTED[Terminals.GEQ] = "'>='";
		EXPECTED[Terminals.EQ] = "'=='";
		EXPECTED[Terminals.NEQ] = "'<>'";

		EXPECTED[Terminals.END_ID] = "'end <identifier>'";
		
		for (int i = 0; i < EXPECTED.length; i++) 
			if (EXPECTED[i] == null)
				EXPECTED[i] = Terminals.NAMES[i].toLowerCase().replace('_', ' ');
	}

	private ModelicaScanner.Symbol lastSyntaxError;
	private IFile file;
	
	public void setFile(IFile file) {
		this.file = file;
		if (file != null)
			Util.deleteErrorMarkers(file);
		lastSyntaxError = null;
	}
	
	public void cleanUp() {
		if (lastSyntaxError != null)
			report(getUnexpectedMessage());
	}

	private void report(StringBuilder msg) {
		report(new CompileError(msg.toString(), IError.SYNTACTIC, lastSyntaxError));
		lastSyntaxError = null;
	}

	private void report(CompileError err) {
		if (file != null)
			err.addAsMarkerTo(file);
	}

	@Override
	public void errorPhraseRemoved(Symbol error) {
		report(getUnexpectedMessage());
	}

	@Override
	public void missingTokenInserted(Symbol token) {
		if (token.getId() == Terminals.EOF) {
			misspelledTokenReplaced(token);
		} else {
			StringBuilder msg = getUnexpectedMessage();
			msg.append(", insert ");
			msg.append(EXPECTED[token.getId()]);
			msg.append(" to complete statement");
			report(msg);
		}
	}

	@Override
	public void misspelledTokenReplaced(Symbol token) {
		StringBuilder msg = getUnexpectedMessage();
		msg.append(", expected ");
		msg.append(EXPECTED[token.getId()]);
		report(msg);
	}

	@Override
	public void scannerError(Scanner.Exception e) {
		report(new CompileError((ModelicaScanner.Exception) e));
	}

	@Override
	public void syntaxError(Symbol token) {
		cleanUp();
		lastSyntaxError = (ModelicaScanner.Symbol) token;
	}

	@Override
	public void unexpectedTokenRemoved(Symbol token) {
		StringBuilder msg = getUnexpectedMessage();
		msg.append(", delete this token");
		report(msg);
	}

	private StringBuilder getUnexpectedMessage() {
		StringBuilder msg = new StringBuilder("Unexpected ");
		if (lastSyntaxError.getId() == Terminals.STRING) {
			msg.append("string ");
			msg.append(lastSyntaxError.value);
		} else if (lastSyntaxError.getId() == Terminals.EOF) {
			msg.append("end-of-file");
		} else {
			msg.append("token '");
			msg.append(lastSyntaxError.value);
			msg.append("'");
		}
		return msg;
	}
	
	// TODO: CompileError unnecessary, create markers directly
}
