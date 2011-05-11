package org.jmodelica.icons.test;

import org.eclipse.swt.widgets.Composite;
import org.eclipse.swt.SWT;
import org.eclipse.ui.part.ViewPart;

public class ImageView extends ViewPart {
	
	TestCanvas canvas;
  
	public ImageView() {
		
	}
		
	public void createPartControl(Composite parent) {
		
		canvas = new TestCanvas(parent, SWT.TOOL | SWT.ON_TOP | SWT.RESIZE);
	}
	
	public void setFocus() {
		
	}
	
	public void dispose() {

	}
}