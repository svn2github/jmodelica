package org.jmodelica.ide.error;

import org.eclipse.core.resources.IMarker;
import org.eclipse.core.resources.IResource;
import org.jastadd.plugin.compiler.ast.IError;
import org.jmodelica.ide.helpers.Util;
import org.jmodelica.modelica.compiler.ASTNode;

public abstract class InstanceProblem implements IError {

	protected String msg;
	protected String fileName;
	protected int start;
	protected int end;
	protected int line;
	protected int col;
	private IResource file;
	protected ASTNode<?> node;
	private boolean hasFile;

	public InstanceProblem(String msg, ASTNode<?> n) {
		this.msg = msg;
		fileName = n.fileName();
		line = n.lineNumber();
		col = n.columnNumber();
		node = n;
		start = node.getBeginOffset();
		end = node.getEndOffset() + 1;
		updateFile();
	}

	protected void updateFile() {
		file = node.getDefinition().getFile();
		hasFile = file != null;
	}

	public boolean hasFile() {
		if (!hasFile)
			updateFile();
		return hasFile;
	}

	public boolean attachToFile() {
		if (hasFile()) {
			Util.addErrorMarker(file, this);
			return true;
		}
		return false;
	}
	
	public abstract boolean isError();

	public int getKind() {
		return IError.SEMANTIC;
	}

	public int getLine() {
		return line;
	}

	public String getMessage() {
		return msg;
	}

	public abstract int getSeverity();

	public int getStartOffset() {
		return start;
	}

	public int getEndOffset() {
		return end;
	}

	public String getFileName() {
		return fileName;
	}

	@Override
	public int hashCode() {
		return fileName.hashCode() + line + (col << 16) + msg.hashCode();
	}

	@Override
	public boolean equals(Object o) {
		if (o instanceof InstanceError) {
			InstanceError e = (InstanceError) o;
			return line == e.line && col == e.col && fileName.equals(e.fileName) && msg.equals(msg);
		}
		return false;
	}

	@Override
	public String toString() {
		return String.format("%s, line %d, col %d:\n%s\n", fileName, line, col, msg);
	}

}