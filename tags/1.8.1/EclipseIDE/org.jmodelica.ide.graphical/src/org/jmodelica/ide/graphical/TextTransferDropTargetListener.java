package org.jmodelica.ide.graphical;

import org.eclipse.gef.EditPartViewer;
import org.eclipse.gef.Request;
import org.eclipse.gef.dnd.AbstractTransferDropTargetListener;
import org.eclipse.swt.dnd.Transfer;
import org.jmodelica.ide.graphical.editparts.NativeDropRequest;


public class TextTransferDropTargetListener extends AbstractTransferDropTargetListener {

	public TextTransferDropTargetListener(EditPartViewer viewer, Transfer xfer) {
		super(viewer, xfer);
	}

	@Override
	protected Request createTargetRequest() {
		return new NativeDropRequest();
	}

	@Override
	protected void updateTargetRequest() {
		((NativeDropRequest) getTargetRequest()).setData(getCurrentEvent().data);
		((NativeDropRequest) getTargetRequest()).setPoint(getDropLocation());
	}

}
