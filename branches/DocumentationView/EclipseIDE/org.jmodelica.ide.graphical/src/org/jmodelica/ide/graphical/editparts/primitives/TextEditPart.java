package org.jmodelica.ide.graphical.editparts.primitives;


import org.eclipse.draw2d.IFigure;
import org.eclipse.draw2d.TextUtilities;
import org.eclipse.draw2d.geometry.Dimension;
import org.eclipse.swt.SWT;
import org.eclipse.swt.graphics.Font;
import org.jmodelica.icons.Observable;
import org.jmodelica.icons.coord.Extent;
import org.jmodelica.icons.coord.Point;
import org.jmodelica.icons.primitives.FilledRectShape;
import org.jmodelica.icons.primitives.FilledShape;
import org.jmodelica.icons.primitives.Text;
import org.jmodelica.icons.primitives.Types;
import org.jmodelica.ide.graphical.graphics.TransformableTextLabel;
import org.jmodelica.ide.graphical.util.Converter;
import org.jmodelica.ide.graphical.util.Transform;

public class TextEditPart extends GraphicEditPart {

	private static int MIN_TEXT_SIZE = 7;
	private static double TEXT_FLIP_ANGLE_POS = Math.PI / 2 - 0.001;
	private static double TEXT_FLIP_ANGLE_NEG = TEXT_FLIP_ANGLE_POS - Math.PI;
	private String overrideTextString = null;

	public TextEditPart(Text model) {
		super(model);
	}

	@Override
	public Text getModel() {
		return (Text) super.getModel();
	}
	
	@Override
	protected IFigure createFigure() {
		return new TransformableTextLabel();
	}
	
	@Override
	public void addNotify() {
		updateFillColor();
		refreshTextLabel();
		super.addNotify();
	}
	
	@Override
	public void update(Observable o, Object flag, Object additionalInfo) {
		if (o == getModel()) {
			if (flag == Text.FONT_NAME_CHANGED)
				updateFontName();
			else if (flag == Text.FONT_SIZE_CHANGED)
				updateFontSize();
			else if (flag == Text.HORIZONTAL_ALIGNMENT_CHANGED)
				updateHorizontalAlignment();
			else if (flag == Text.TEXT_STRING_CHANGED)
				updateText();
			else if (flag == Text.TEXT_STYLE_CHANGED)
				updateStyle();
			else if (flag == FilledRectShape.EXTENT_UPDATED)
				updateExtent();
			else if (flag == FilledShape.FILL_COLOR_UPDATED)
				updateFillColor();
			else if (flag == FilledShape.FILL_PATTERN_CHANGED)
				updateFillPattern();
			else if (flag == FilledShape.LINE_COLOR_UPDATED)
				updateLineColor();
			else if (flag == FilledShape.LINE_PATTERN_CHANGED)
				updateLinePattern();
			else if (flag == FilledShape.LINE_THICKNESS_CHANGED)
				updateLineThickness();
		}
		super.update(o, flag, additionalInfo);
	}
	
	

	private void updateFontName() {
		refreshTextLabel();
	}

	private void updateFontSize() {
		refreshTextLabel();
	}

	private void updateHorizontalAlignment() {
		refreshTextLabel();
	}

	private void updateText() {
		refreshTextLabel();
	}

	private void updateStyle() {
		refreshTextLabel();
	}

	private void updateExtent() {
		refreshTextLabel();
	}

	private void updateFillColor() {
		//TODO: Implement fill color
	}

	private void updateFillPattern() {
		//TODO: Implement fill pattern
	}

	private void updateLineColor() {
		getFigure().setForegroundColor(Converter.convert(getModel().getLineColor()));
	}

	private void updateLinePattern() {
		//TODO: Implement line pattern
	}

	private void updateLineThickness() {
		//TODO: Implement line thickness
	}
	
	private void refreshTextLabel() {
		int fontStyle = SWT.NORMAL;
		for (Types.TextStyle style : getModel().getTextStyle()) {
			switch (style) {
			case BOLD:
				fontStyle |= SWT.BOLD;
				break;
			case ITALIC:
				fontStyle |= SWT.ITALIC;
				break;
			case UNDERLINE:
				//TODO: fix underline, probably have to draw a line manually under the text in TransformableLineTextLabel.
				System.err.println("This is not supported yet");
				break;
			}
		}

		Extent maxExtent = Transform.yInverter.transform(getModel().getExtent());
		double xScale = getTransform().getXScale();
		double yScale = getTransform().getYScale();

		// First calculate fontsize without transformation
		int fontSize = (int) Math.round(getModel().getFontSize());
		if (fontSize == 0) {
			double textWidth = xScale * maxExtent.getWidth();
			double textHeight = yScale * maxExtent.getHeight();
			TextUtilities tu = TextUtilities.INSTANCE;
			fontSize = (int) Math.round(textHeight);
			Font font = new Font(null, getModel().getFontName(), fontSize, fontStyle);
			Dimension textExtent = tu.getStringExtents(getTextString(), font);
			while ((textExtent.height() > textHeight || textExtent.width() > textWidth) && fontSize > 0) {
				font.dispose();
				fontSize -= 1;
				font = new Font(null, getModel().getFontName(), fontSize, fontStyle);
				textExtent = tu.getStringExtents(getTextString(), font);
			}
			font.dispose();
			fontSize++;
		}

		// Check if it's to small to display
		if (fontSize < MIN_TEXT_SIZE) {
			// Too small, hide!
			getFigure().setVisible(false);
			return;
		}

		//  Calculate position
		Font font = new Font(null, getModel().getFontName(), (int) Math.round(fontSize), fontStyle);
		Dimension textDimension = TextUtilities.INSTANCE.getStringExtents(getTextString(), font).scale(1 / xScale, 1 / yScale);
		int xPos = 0;
		switch (getModel().getHorizontalAlignment()) {
		case CENTER:
			xPos = (int) Math.round((maxExtent.getWidth() - textDimension.width()) / 2);
			break;
		case RIGHT:
			xPos = (int) Math.round(maxExtent.getWidth() - textDimension.width());
			break;
		}
		Point location = new Point(xPos, (maxExtent.getHeight() - textDimension.height()) / 2);
		Extent textExtents = new Extent(location, new Point(location.getX() + textDimension.width(), location.getY() + textDimension.height()));

		Transform transform = getTransform();

		// Do we need to flip / mirror?
		double rotation = transform.getRotation();
		boolean mirror = transform.isMirrored();
		boolean flip = (rotation > TEXT_FLIP_ANGLE_POS || rotation < TEXT_FLIP_ANGLE_NEG);
		if (mirror && flip) {
			rotation += Math.PI;
			location = new Point(location.getX() + textDimension.width(), location.getY());
		} else if (mirror) {
			location = new Point(location.getX(), location.getY() + textDimension.height());
		} else if (flip) {
			rotation += Math.PI;
			location = new Point(location.getX() + textDimension.width(), location.getY() + textDimension.height());
		}

		transform.translate(maxExtent.getP1().getX(), maxExtent.getP1().getY());
		getFigure().setBounds(Converter.convert(transform.transform(textExtents)));
		getFigure().setText(getTextString());
		getFigure().setRotation(rotation);
		getFigure().setTextLocation(transform.transform(location));
		getFigure().setFont(font);
		if (getModel().isVisible())
			getFigure().setVisible(true);
	}
	

	public String getTextString() {
		if (overrideTextString != null)
			return overrideTextString;
		else
			return getModel().getTextString();
	}

	public void setOverrideTextString(String overrideTextString) {
		this.overrideTextString = overrideTextString;
		refreshTextLabel();
	}

	@Override
	public TransformableTextLabel getFigure() {
		return (TransformableTextLabel) super.getFigure();
	}

	@Override
	protected void transformInvalid() {
		refreshTextLabel();
	}

}
