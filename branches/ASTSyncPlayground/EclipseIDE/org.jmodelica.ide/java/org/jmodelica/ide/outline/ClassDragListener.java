package org.jmodelica.ide.outline;

import org.eclipse.swt.dnd.DragSourceEvent;
import org.eclipse.swt.dnd.DragSourceListener;
import org.eclipse.swt.dnd.TextTransfer;

public class ClassDragListener implements DragSourceListener {

	private ClassCopySource source;

	public ClassDragListener(ClassCopySource source) {
		this.source = source;
	}

	public void dragStart(DragSourceEvent event) {
		if (source.canCopy())
			event.doit = true;
	}

	public void dragSetData(DragSourceEvent event) {
		if (TextTransfer.getInstance().isSupportedType(event.dataType)) 
			event.data = source.getStringData();
	}

	public void dragFinished(DragSourceEvent event) {}

}
