
package org.jmodelica.icons.primitives;

import java.util.ArrayList;

import org.jmodelica.icons.coord.Extent;


public class Text extends FilledRectShape {
	
	public static final Object TEXT_STRING_CHANGED = new Object();
	public static final Object FONT_SIZE_CHANGED = new Object();
	public static final Object FONT_NAME_CHANGED = new Object();
	public static final Object TEXT_STYLE_CHANGED = new Object();
	public static final Object HORIZONTAL_ALIGNMENT_CHANGED = new Object();
	
	private String textString;
	private double fontSize;
	private String fontName;
	private ArrayList<Types.TextStyle> textStyle;  
	private Types.TextAlignment horizontalAlignment;
	
	public static final String DEFAULT_TEXT_STRING = "";
	public static final String DEFAULT_FONT_NAME = "";
	public static final double DEFAULT_FONT_SIZE = 0;
	public static final Types.TextAlignment DEFAULT_HORIZONTAL_ALIGNMENT = Types.TextAlignment.CENTER;
		
	public Text() {
		this(Extent.NO_EXTENT);
	}
	public Text(Extent extent) {
		super(extent);
		setTextString(DEFAULT_TEXT_STRING);
		setFontSize(DEFAULT_FONT_SIZE);
		setFontName(DEFAULT_FONT_NAME);
		setHorizontalAlignment(DEFAULT_HORIZONTAL_ALIGNMENT);
		setTextStyle(new ArrayList<Types.TextStyle>());
	}
	
	public void setTextString(String newTextString) {
		if (textString != null && textString.equals(newTextString))
			return;
		textString = newTextString;
		notifyObservers(TEXT_STRING_CHANGED);
	}

	public String getTextString() {
		return textString;
	}

	public void setFontSize(double newFontSize) {
		if (fontSize == newFontSize)
			return;
		fontSize = newFontSize;
		notifyObservers(FONT_SIZE_CHANGED);
	}

	public double getFontSize() {
		return fontSize;
	}

	public void setFontName(String newFontName) {
		if (fontName != null && fontName.equals(newFontName))
			return;
		fontName = newFontName;
		notifyObservers(FONT_NAME_CHANGED);
	}

	public String getFontName() {
		return fontName;
	}

	public void setTextStyle(ArrayList<Types.TextStyle> newTextStyle) {
		if (textStyle == newTextStyle)
			return;
		textStyle = newTextStyle;
		notifyObservers(TEXT_STYLE_CHANGED);
	}

	public ArrayList<Types.TextStyle> getTextStyle() {
		return textStyle;
	}

	public void setHorizontalAlignment(Types.TextAlignment newHorizontalAlignment) {
		if (horizontalAlignment == newHorizontalAlignment)
			return;
		horizontalAlignment = newHorizontalAlignment;
		notifyObservers(HORIZONTAL_ALIGNMENT_CHANGED);
	}

	public Types.TextAlignment getHorizontalAlignment() {
		return horizontalAlignment;
	}
	
	public String toString() {
		String s = "";
		s += "textString = " + textString;
		s += "\n" + super.toString();
		return s;
	}
} 