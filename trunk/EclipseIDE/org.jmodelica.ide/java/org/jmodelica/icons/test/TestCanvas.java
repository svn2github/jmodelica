package org.jmodelica.icons.test;

import java.io.File;

import javax.imageio.ImageIO;

import org.eclipse.swt.widgets.Composite;
import org.eclipse.swt.widgets.Canvas;

import org.eclipse.swt.events.PaintListener;
import org.eclipse.swt.events.PaintEvent;
import org.eclipse.swt.events.MouseListener;
import org.eclipse.swt.events.MouseEvent;

import org.eclipse.swt.events.DragDetectListener;
import org.eclipse.swt.events.DragDetectEvent;

import org.eclipse.swt.graphics.GC;
import org.eclipse.swt.graphics.Image;
import org.eclipse.swt.graphics.Transform;


public class TestCanvas extends Canvas {

	public static Image image;
	private int imgx;
	private int imgy;
	
	public TestCanvas(Composite parent, int style) {
		super(parent, style);
		this.addPaintListener(new PaintListener() { /* paint listener */
			public void paintControl(PaintEvent event) {
	        	paint(event.gc);
	        }
		});
		
		this.addMouseListener(new MouseListener() {
			public void mouseDown(MouseEvent event) {
				
			}
			public void mouseUp(MouseEvent event) {
				imgx = event.x;
				imgy = event.y;
				redraw();
			}			
			public void mouseDoubleClick(MouseEvent event) {
			
			}
		});
	}
	
	private void paint(GC gc) {
		gc.drawImage(image, imgx, imgy);
	}
}