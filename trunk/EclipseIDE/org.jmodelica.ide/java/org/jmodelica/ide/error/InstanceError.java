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

import org.eclipse.core.resources.IMarker;
import org.eclipse.core.resources.IResource;
import org.jastadd.plugin.compiler.ast.IError;
import org.jmodelica.modelica.compiler.ASTNode;
import org.jmodelica.ide.helpers.Util;

public class InstanceError implements IError {
	
	private String msg;
	private String fileName;
	private int start;
	private int end;
	private int line;
	private int col;
	private IResource file;
	private ASTNode<?> node;
	private boolean hasFile;
	
	public InstanceError(String msg, ASTNode<?> n) {
		super();
		this.msg = msg;
		fileName = n.fileName();
		line = n.lineNumber();
		col = n.columnNumber();
		node = n;
		start = node.getBeginOffset();
		end = node.getEndOffset() + 1;
		updateFile();
	}

	private void updateFile() {
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

	public int getKind() {
		return IError.SEMANTIC;
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

	public int getEndOffset() {
		return end;
	}

	public String getFileName() {
		return fileName;
	}

	@Override
	public int hashCode() {
		return fileName.hashCode() + line + col + msg.hashCode();
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
