package org.jmodelica.ide.documentation;

import java.util.Stack;

import org.jastadd.ed.core.model.IASTPathPart;

public class HistoryObject {
	public static final int TYPE_CLASS = 0;
	public static final int TYPE_URL = 1;
	private Stack<IASTPathPart> classASTPath;
	private String externalURL;
	private int type;

	public HistoryObject(int type, Stack<IASTPathPart> classASTPath) {
		this.classASTPath = classASTPath;
		this.type = type;
	}

	public HistoryObject(int type, String externalURL) {
		this.externalURL = externalURL;
	}

	public Stack<IASTPathPart> getClassASTPath() {
		return classASTPath;
	}

	public String getExternalURL() {
		return externalURL;
	}

	public int getType() {
		return type;
	}
}