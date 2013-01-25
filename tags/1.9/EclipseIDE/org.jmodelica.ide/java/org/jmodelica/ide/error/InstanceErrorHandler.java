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

import java.util.ArrayList;
import java.util.Collection;
import java.util.HashSet;
import java.util.Set;

import org.jmodelica.modelica.compiler.ASTNode;
import org.jmodelica.modelica.compiler.IErrorHandler;
import org.jmodelica.modelica.compiler.Root;

public class InstanceErrorHandler implements IErrorHandler {
	
	private Set<InstanceProblem> found = new HashSet<InstanceProblem>();
	private Set<InstanceProblem> countedErrors = new HashSet<InstanceProblem>();
	private Set<InstanceProblem> countedWarnings = new HashSet<InstanceProblem>();
	private boolean lostErrors;
	
	private static final int MAX_ERRORS_SHOWN = 50;
	private static final String[] MSG_FORMATS = new String[] {
		"No errors found.", "%d warning%s found:\n", 
		"%d error%s found:\n", "%d error%s and %d warning%s found:\n"
	};
	private static final int MSG_FORMAT_ERR = 2;
	private static final int MSG_FORMAT_WARN = 1;

	protected void problem(InstanceProblem p) {
		if (!found.contains(p)) {
			// TODO: if file/document isn't available, find them or attach later
			p.attachToFile();
			found.add(p);
		}
		if (p.isLostError())
			lostErrors = true;
		count(p);
	}

	protected void count(InstanceProblem p) {
		Set<InstanceProblem> counted = p.isError() ? countedErrors : countedWarnings;
		if (!counted.contains(p)) 
			counted.add(p);
	}

	@SuppressWarnings("unchecked")
	public void error(String s, ASTNode n) {
		problem(new InstanceError(s, n));
	}

	public void compliance(String s, ASTNode n) {
		error(s, n);  // TODO: Perhaps these should be handled differently? issued for unimplemented features
	}

	@SuppressWarnings("unchecked")
    public void warning(String s, ASTNode n) {
		problem(new InstanceWarning(s, n));
	}
	
	public void reset() {
		found.clear();
		resetCounter();
	}
	
	public int getNumErrors() {
		return countedErrors.size();
	}
	
	public int getNumWarnings() {
		return countedWarnings.size();
	}

	public boolean hasErrors() {
		return getNumErrors() > 0;
	}

	public boolean hasProblems() {
		return (getNumErrors() + getNumWarnings()) > 0;
	}

	public void resetCounter() {
		countedErrors.clear();
		countedWarnings.clear();
		lostErrors = false;
	}
	
	public boolean hasLostErrors() {
		return lostErrors;
	}

	public Collection<InstanceProblem> getLostErrors() {
		Collection<InstanceProblem> res = new ArrayList<InstanceProblem>(found.size());
		for (InstanceProblem e : found)
			if (!e.hasFile() && e.isError())
				res.add(e);
		return res;
	}

	public Collection<InstanceProblem> getProblemsByType() {
		Collection<InstanceProblem> res = new ArrayList<InstanceProblem>(found.size());
		res.addAll(countedErrors);
		res.addAll(countedWarnings);
		return res;
	}

	public String resultMessage() {
		Collection<InstanceProblem> err = getProblemsByType();
		int numE = getNumErrors();
		int numW = getNumWarnings();
		String f = MSG_FORMATS[(numE > 0 ? MSG_FORMAT_ERR : 0) + (numW > 0 ? MSG_FORMAT_WARN : 0)];
		if (numE == 0)
			numE = numW;
		String msg = String.format(f, numE, (numE > 1 ? "s" : ""), numW, (numW > 1 ? "s" : ""));
		StringBuilder buf = new StringBuilder(msg);
		if (err.size() > MAX_ERRORS_SHOWN)
			buf.append(String.format("(First %d of %d problems shown.)\n",
					MAX_ERRORS_SHOWN, err.size()));
		int i = 0;
		for (InstanceProblem e : err) {
			if (i++ < MAX_ERRORS_SHOWN) {
				buf.append('\n');
				buf.append(e);
			}
		}
		return buf.toString();
	}

	public IErrorHandler connectTo(Root root) {
		root.setErrorHandler(this);
		return this;
	}
}
