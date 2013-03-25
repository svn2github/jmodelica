package org.jmodelica.ide.actions;

import org.eclipse.jface.action.Action;
import org.eclipse.swt.dnd.Clipboard;
import org.eclipse.swt.dnd.TextTransfer;
import org.eclipse.swt.dnd.Transfer;
import org.jmodelica.ide.outline.ClassCopySource;

public class CopyClassAction extends Action {

	private ClassCopySource source;
	private Clipboard clipboard;

	public CopyClassAction(ClassCopySource source, Clipboard clipboard) {
		this.source = source;
		this.clipboard = clipboard;
	}

	public void run() {
		if (source.canCopy()) {
			Object[] data = new Object[] { source.getStringData() };
			Transfer[] dataTypes = new Transfer[] { TextTransfer.getInstance() };
			clipboard.setContents(data, dataTypes);
		}
	}

}
