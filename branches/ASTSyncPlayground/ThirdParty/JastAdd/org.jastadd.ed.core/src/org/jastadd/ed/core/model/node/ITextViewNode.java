package org.jastadd.ed.core.model.node;

import org.eclipse.core.resources.IFile;

public interface ITextViewNode extends IASTNode {

	public int startSelectionOffset();
	public int endSelectionOffset();
	
	public int startTextOffset();
	public int endTextOffset();
	
	public ITextViewNode findNodeForOffset(int offset);
	
	public IFile enclosingFile();

}
