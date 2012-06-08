package org.jmodelica.ide.graphical.graphics;


import org.eclipse.draw2d.Figure;
import org.eclipse.draw2d.Graphics;
import org.eclipse.draw2d.geometry.Dimension;
import org.eclipse.draw2d.geometry.Rectangle;
import org.eclipse.swt.graphics.Color;
import org.jmodelica.icons.coord.Point;
import org.jmodelica.ide.graphical.util.Converter;
import org.jmodelica.ide.graphical.util.Transform;

public class TransformableTextLabel extends Figure {
	
	private static final boolean DEBUG = false;
	
	private String text = "";
	private Point textLocation = new Point();
	private double rotation = 0;
	
	@Override
	protected void paintFigure(Graphics graphics) {
		if (DEBUG) {
			System.out.println("location:" + textLocation + " bounds:" + getBounds() + " rotation:" + (rotation * 180 / Math.PI + " font:" + getFont().getFontData()[0].height + " text:\"" + getText() + "\""));
			Color c = graphics.getForegroundColor();
			graphics.setForegroundColor(new Color(null, 0xFF, 0x00, 0xFF));
			graphics.drawRectangle(getBounds().x, getBounds().y, getBounds().width - 1, getBounds().height - 1);
			graphics.setForegroundColor(new Color(null, 0xFF, 0xFF, 0x00));
		}
		graphics.rotate((float) (rotation * 180 / Math.PI));
		Transform unRotate = new Transform();
		unRotate.rotate(-rotation);
		Point location = unRotate.transform(textLocation);
		
		if (DEBUG) {
			Color c = graphics.getForegroundColor();
			graphics.setForegroundColor(new Color(null, 0xFF, 0x00, 0x00));
			graphics.drawOval(new Rectangle(Converter.convert(location).getCopy().translate(-2, -2), new Dimension(4, 4)));
		}
		
		graphics.setForegroundColor(getForegroundColor());
		graphics.drawText(text, Converter.convert(location));
	}
	
	public Point getTextLocation() {
		return textLocation;
	}
	
	public void setTextLocation(Point textLocation) {
		if (this.textLocation == textLocation) {
			return;
		}
		this.textLocation = textLocation;
		revalidate();
		repaint();
	}
	
	public String getText() {
		return text;
	}
	
	public void setText(String text) {
		if (this.text.equals(text)) {
			return;
		}
		this.text = text;
		revalidate();
		repaint();
	}
	
	public double getRotation() {
		return rotation;
	}
	
	public void setRotation(double rotation) {
		if (this.rotation == rotation) {
			return;
		}
		this.rotation = rotation;
		revalidate();
		repaint();
	}
	
}
