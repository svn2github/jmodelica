package org.jmodelica.ide.error;

import java.util.ArrayList;
import java.util.Collection;

import org.jastadd.plugin.compiler.ast.IError;
import org.jmodelica.parser.ModelicaScanner;
import org.jmodelica.parser.ModelicaParser.Terminals;

import beaver.Symbol;
import beaver.Parser.Events;
import beaver.Scanner;

public class CompileErrorReport extends Events {
	
	
	public static final String[] EXPECTED = new String[Terminals.NAMES.length];
	{
		EXPECTED[Terminals.EOF] = "end-of-file";
		EXPECTED[Terminals.ID] = "identifier";
		EXPECTED[Terminals.STRING] = "string";
		EXPECTED[Terminals.ANNOTATION] = "\"annotation\"";
		EXPECTED[Terminals.SEMICOLON] = "\";\"";
		EXPECTED[Terminals.COMMA] = "\",\"";
		EXPECTED[Terminals.IF] = "\"if\"";
		EXPECTED[Terminals.RPAREN] = "\"(\"";
		EXPECTED[Terminals.LPAREN] = "\")\"";
		EXPECTED[Terminals.END] = "\"end\"";
		EXPECTED[Terminals.PLUS] = "\"+\"";
		EXPECTED[Terminals.FOR] = "\"for\"";
		EXPECTED[Terminals.MINUS] = "\"-\"";
		EXPECTED[Terminals.INITIAL] = "\"initial\"";
		EXPECTED[Terminals.CONSTRAINEDBY] = "\"constrainedby\"";
		EXPECTED[Terminals.ELSE] = "\"else\"";
		EXPECTED[Terminals.ELSEIF] = "\"elseif\"";
		EXPECTED[Terminals.LBRACK] = "\"[\"";
		EXPECTED[Terminals.ASSIGN] = "\"=\"";
		EXPECTED[Terminals.RBRACE] = "\"}\"";
		EXPECTED[Terminals.LBRACE] = "\"{\"";
		EXPECTED[Terminals.UNSIGNED_NUMBER] = "number";
		EXPECTED[Terminals.UNSIGNED_INTEGER] = "integer";
		EXPECTED[Terminals.TRUE] = "\"true\"";
		EXPECTED[Terminals.FALSE] = "\"false\"";
		EXPECTED[Terminals.TIME] = "\"time\"";
		EXPECTED[Terminals.COLON] = "\":\"";
		EXPECTED[Terminals.THEN] = "\"then\"";
		EXPECTED[Terminals.LOOP] = "\"loop\"";
		EXPECTED[Terminals.RBRACK] = "\"]\"";
		EXPECTED[Terminals.INPUT] = "\"input\"";
		EXPECTED[Terminals.OUTPUT] = "\"output\"";
		EXPECTED[Terminals.EXTERNAL] = "\"external\"";
		EXPECTED[Terminals.PUBLIC] = "\"public\"";
		EXPECTED[Terminals.PROTECTED] = "\"protected\"";
		EXPECTED[Terminals.EQUATION] = "\"equation\"";
		EXPECTED[Terminals.INITIAL_EQUATION] = "\"initial equation\"";
		EXPECTED[Terminals.ALGORITHM] = "\"algorithm\"";
		EXPECTED[Terminals.INITIAL_ALGORITHM] = "\"initial algorithm\"";
		EXPECTED[Terminals.CONNECTOR] = "\"connector\"";
		EXPECTED[Terminals.EXPANDABLE] = "\"expandable\"";
		EXPECTED[Terminals.CLASS] = "\"class\"";
		EXPECTED[Terminals.MODEL] = "\"model\"";
		EXPECTED[Terminals.BLOCK] = "\"block\"";
		EXPECTED[Terminals.TYPE] = "\"type\"";
		EXPECTED[Terminals.PACKAGE] = "\"package\"";
		EXPECTED[Terminals.FUNCTION] = "\"function\"";
		EXPECTED[Terminals.RECORD] = "\"record\"";
		EXPECTED[Terminals.NOT] = "\"not\"";
		EXPECTED[Terminals.PARTIAL] = "\"partial\"";
		EXPECTED[Terminals.DISCRETE] = "\"discrete\"";
		EXPECTED[Terminals.PARAMETER] = "\"parameter\"";
		EXPECTED[Terminals.CONSTANT] = "\"constant\"";
		EXPECTED[Terminals.ENCAPSULATED] = "\"encapsulated\"";
		EXPECTED[Terminals.WHEN] = "\"when\"";
		EXPECTED[Terminals.OR] = "\"or\"";
		EXPECTED[Terminals.AND] = "\"and\"";
		EXPECTED[Terminals.FLOW] = "\"flow\"";
		EXPECTED[Terminals.REPLACEABLE] = "\"replaceable\"";
		EXPECTED[Terminals.LT] = "\"<\"";
		EXPECTED[Terminals.LEQ] = "\"<=\"";
		EXPECTED[Terminals.GT] = "\">\"";
		EXPECTED[Terminals.GEQ] = "\">=\"";
		EXPECTED[Terminals.EQ] = "\"==\"";
		EXPECTED[Terminals.NEQ] = "\"<>\"";
		EXPECTED[Terminals.MULT] = "\"*\"";
		EXPECTED[Terminals.ELSEWHEN] = "\"elsewhen\"";
		EXPECTED[Terminals.DIV] = "\"/\"";
		EXPECTED[Terminals.EXTENDS] = "\"extends\"";
		EXPECTED[Terminals.FINAL] = "\"final\"";
		EXPECTED[Terminals.OUTER] = "\"outer\"";
		EXPECTED[Terminals.WHILE] = "\"while\"";
		EXPECTED[Terminals.RETURN] = "\"return\"";
		EXPECTED[Terminals.INNER] = "\"inner\"";
		EXPECTED[Terminals.POW] = "\"^\"";
		EXPECTED[Terminals.REDECLARE] = "\"redeclare\"";
		EXPECTED[Terminals.IMPORT] = "\"import\"";
		EXPECTED[Terminals.CONNECT] = "\"connect\"";
		EXPECTED[Terminals.DOT] = "\".\"";
		EXPECTED[Terminals.EACH] = "\"each\"";
		EXPECTED[Terminals.IN] = "\"in\"";
		EXPECTED[Terminals.WITHIN] = "\"within\"";
	}

	private Collection<IError> errors = new ArrayList<IError>();
	private ModelicaScanner.Symbol lastSyntaxError;
	
	public Collection<IError> getAndResetErrors() {
		Collection<IError> temp = errors;
		errors = new ArrayList<IError>();
		return temp;
	}
	
	public boolean hasErrors() {
		return !errors.isEmpty();
	}

	@Override
	public void errorPhraseRemoved(Symbol error) {
		StringBuilder msg = getUnexpectedMessage();
		errors.add(new CompileError(msg.toString(), IError.SYNTACTIC, lastSyntaxError));
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
			errors.add(new CompileError(msg.toString(), IError.SYNTACTIC, lastSyntaxError));
		}
	}

	@Override
	public void misspelledTokenReplaced(Symbol token) {
		StringBuilder msg = getUnexpectedMessage();
		msg.append(", expected ");
		msg.append(EXPECTED[token.getId()]);
		errors.add(new CompileError(msg.toString(), IError.SYNTACTIC, lastSyntaxError));
	}

	@Override
	public void scannerError(Scanner.Exception e) {
		errors.add(new CompileError((ModelicaScanner.Exception) e));
	}

	@Override
	public void syntaxError(Symbol token) {
		lastSyntaxError = (ModelicaScanner.Symbol) token;
	}

	@Override
	public void unexpectedTokenRemoved(Symbol token) {
		StringBuilder msg = getUnexpectedMessage();
		msg.append(", delete this token");
		errors.add(new CompileError(msg.toString(), IError.SYNTACTIC, lastSyntaxError));
	}

	private StringBuilder getUnexpectedMessage() {
		StringBuilder msg = new StringBuilder("Unexpected ");
		if (lastSyntaxError.getId() == Terminals.STRING) {
			msg.append("string ");
			msg.append(lastSyntaxError.value);
		} else {
			msg.append("token \"");
			msg.append(lastSyntaxError.value);
			msg.append('"');
		}
		return msg;
	}

}
