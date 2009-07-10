package org.jmodelica.ide.folding;

import org.eclipse.jface.text.source.Annotation;
import org.eclipse.jface.text.source.AnnotationPainter;
import org.eclipse.jface.text.source.AnnotationPainter.IDrawingStrategy;
import org.eclipse.jface.text.source.projection.ProjectionAnnotation;
import org.eclipse.swt.SWT;
import org.eclipse.swt.custom.StyleRange;
import org.eclipse.swt.custom.StyledText;
import org.eclipse.swt.graphics.Color;
import org.eclipse.swt.graphics.Font;
import org.eclipse.swt.graphics.FontData;
import org.eclipse.swt.graphics.FontMetrics;
import org.eclipse.swt.graphics.GC;
import org.eclipse.swt.graphics.Point;
import org.eclipse.swt.graphics.RGB;
import org.eclipse.swt.graphics.Rectangle;
import org.eclipse.swt.widgets.Display;
import org.jmodelica.folding.CharacterProjectionAnnotation;

public class AnnotationDrawer implements IDrawingStrategy {
	private Font lastFont;
	private Font lastOldFont;
	private Color cursorLineBackground;
	private AnnotationPainter.IDrawingStrategy fDelegateDrawingStrategy;

	public AnnotationDrawer(IDrawingStrategy delegateDrawingStrategy) {
		fDelegateDrawingStrategy = delegateDrawingStrategy;
	}

	/*
	 * @see org.eclipse.jface.text.source.AnnotationPainter.IDrawingStrategy#draw(org.eclipse.swt.graphics.GC, org.eclipse.swt.custom.StyledText, int, int, org.eclipse.swt.graphics.Color)
	 */
	public void draw(Annotation annotation, GC gc, StyledText textWidget, int offset, int length, Color color) {
		if (annotation instanceof ProjectionAnnotation) {
			if (annotation instanceof CharacterProjectionAnnotation) {
				ProjectionAnnotation projectionAnnotation= (ProjectionAnnotation) annotation;
				if (projectionAnnotation.isCollapsed()) {

					if (gc != null) {
						offset--;
						Color fg = gc.getForeground();
						Color bg = gc.getBackground();
						Font oldFont = gc.getFont();

						StyleRange style = textWidget.getStyleRangeAtOffset(offset);
						boolean selected = isSelected(textWidget, offset);

						gc.setForeground(getForeground(textWidget, selected));
						gc.setBackground(getBackground(textWidget, style, selected, offset));
						gc.setFont(getFont(style, oldFont));

						Point pos = textWidget.getLocationAtOffset(offset);
						gc.fillRectangle(getArea(gc, textWidget, offset, pos));
						gc.drawString("@", pos.x, pos.y, true);

						gc.setForeground(fg);
						gc.setBackground(bg);
						gc.setFont(oldFont);
					} else {
						textWidget.redrawRange(offset - 1, length + 1, true);
					}
				}
			} else {
				fDelegateDrawingStrategy.draw(annotation, gc, textWidget, offset, length, color);
			}
		}
	}

	private Rectangle getArea(GC gc, StyledText textWidget, int offset,
			Point start) {
		FontMetrics metrics = gc.getFontMetrics();
		Rectangle res = new Rectangle(start.x, start.y, metrics.getAverageCharWidth(), metrics.getHeight());
		Point next = textWidget.getLocationAtOffset(offset + 1);
		if (start.y == next.y)
			res.width = next.x - start.x;
		return res;
	}

	private Font getFont(StyleRange style, Font oldFont) {
		if (oldFont != null && oldFont == lastOldFont) 
			return lastFont;

		lastOldFont = oldFont;
		if (lastFont != null)
			lastFont.dispose();
		lastFont = style.font;
		if (lastFont == null) 
			lastFont = oldFont;
		FontData data = lastFont.getFontData()[0];
		lastFont = new Font(lastFont.getDevice(), data.getName(), data.getHeight(), data.getStyle() | SWT.BOLD);
		return lastFont;

	}

	private Color getBackground(StyledText textWidget, StyleRange style,
			boolean selected, int offset) {
		Color bg;
		if (selected) {
			bg = textWidget.getSelectionBackground();
	    } else {
	    	int line = textWidget.getLineAtOffset(offset);
			bg = textWidget.getLineBackground(line);
	    	if (bg == null) {
	    		if (useCursorBackground(textWidget, line) || style == null) 
					bg = cursorLineBackground;
	    		else 
	    			bg = style.background;
	    	}
	    }
		if (bg == null) 
			bg = textWidget.getBackground();
		return bg;
	}

	private boolean useCursorBackground(StyledText textWidget, int line) {
		int caret = textWidget.getLineAtOffset(textWidget.getCaretOffset());
		return caret == line && cursorLineBackground != null;
	}

	private Color getForeground(StyledText textWidget, boolean selected) {
		Color fg;
		if (selected)
			fg = textWidget.getSelectionForeground();
		else 
			fg = new Color(Display.getCurrent(), new RGB(0x03, 0xA5, 0x44));
		return fg;
	}

	private boolean isSelected(StyledText textWidget, int offset) {
		Point selection = textWidget.getSelection();
		return selection.x <= offset && selection.y > offset;
	}

	public void setCursorLineBackground(Color bg) {
		cursorLineBackground = bg;
	}
}
