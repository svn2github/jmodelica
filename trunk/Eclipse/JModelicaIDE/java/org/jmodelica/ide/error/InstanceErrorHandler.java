package org.jmodelica.ide.error;

import java.util.ArrayList;
import java.util.Collection;
import java.util.HashSet;

import org.jmodelica.ast.ASTNode;
import org.jmodelica.ast.IErrorHandler;

public class InstanceErrorHandler implements IErrorHandler {
	
	private HashSet<InstanceError> foundErrors = new HashSet<InstanceError>();
	private HashSet<InstanceError> countedErrors = new HashSet<InstanceError>();
	private boolean lostErrors;

	public void error(String s, ASTNode n) {
		InstanceError error = new InstanceError(s, n);
		if (!foundErrors.contains(error)) {
			// TODO: if file/document isn't available, find them or attach later
			if (!error.attachToFile())
				lostErrors = true;
			foundErrors.add(error);
		}
		if (!countedErrors.contains(error)) {
			countedErrors.add(error);
		}
	}

	public void warning(String s, ASTNode n) {
		// Ignore for now - warnings are invoked for things that aren't implemented in compiler
	}
	
	public void reset() {
		foundErrors.clear();
		resetCounter();
	}
	
	public int getNumErrors() {
		return countedErrors.size();
	}

	public void resetCounter() {
		countedErrors.clear();
		lostErrors = false;
	}
	
	public boolean hasLostErrors() {
		return lostErrors;
	}

	public Collection<InstanceError> getLostErrors() {
		Collection<InstanceError> res = new ArrayList<InstanceError>(foundErrors.size());
		for (InstanceError e : foundErrors)
			if (!e.hasFile())
				res.add(e);
		return res;
	}
}
