package org.jastadd.ed.core.model.node;

public interface ISelectionNode extends IJastAddNode {
	public int selectionLine();
	public int selectionColumn();
	public int selectionLength();
	public int selectionEndLine();
	public int selectionEndColumn();
}
