package org.jmodelica.util.exceptions;

import java.util.ArrayList;
import java.util.Collection;

import org.jmodelica.util.Problem;

/**
 * Exception containing a list of compiler errors/warnings.
 */
@SuppressWarnings("serial")
public class CompilerException extends ModelicaException {
	private Collection<Problem> errors;
	private Collection<Problem> warnings;

	/**
	 * Default constructor.
	 */
	public CompilerException() {
		errors = new ArrayList<Problem>();
		warnings = new ArrayList<Problem>();
	}

	/**
	 * Construct from a list of problems.
	 */
	public CompilerException(Collection<Problem> problems) {
		this();
		for (Problem p : problems)
			addProblem(p);
	}

	/**
	 * Add a new problem.
	 */
	public void addProblem(Problem p) {
		if (p.severity() == Problem.Severity.ERROR)
			errors.add(p);
		else
			warnings.add(p);
	}

	/**
	 * Get the list of problems.
	 */
	public Collection<Problem> getProblems() {
		Collection<Problem> problems = new ArrayList<Problem>();
		problems.addAll(errors);
		problems.addAll(warnings);
		return problems;
	}

	/**
	 * Get the list of errors.
	 */
	public Collection<Problem> getErrors() {
		return errors;
	}

	/**
	 * Get the list of warnings.
	 */
	public Collection<Problem> getWarnings() {
		return warnings;
	}

	/**
	 * Should these problems cause compilation to stop?
	 * 
	 * @param warnings value to return if there are warnings but not errors
	 */
	public boolean shouldStop(boolean warnings) {
		return !errors.isEmpty() || (warnings && !this.warnings.isEmpty());
	}

	/**
	 * Convert to error message.
	 */
	public String getMessage() {
		StringBuilder str = new StringBuilder();
		if (!errors.isEmpty()) {
			str.append(errors.size());
			str.append(" errors ");
			str.append(warnings.isEmpty() ? "found:\n\n" : "and ");
		}
		if (!warnings.isEmpty()) {
			str.append(warnings.size());
			str.append(" warnings found:\n\n");
		}
		for (Problem p : errors) {
			str.append(p);
			str.append("\n\n");
		}
		for (Problem p : warnings) {
			str.append(p);
			str.append("\n\n");
		}
		str.deleteCharAt(str.length() - 1);
		return str.toString();
	}

}