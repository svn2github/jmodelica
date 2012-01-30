
package org.jmodelica.icons.parts.primitives;

import java.util.ArrayList;

import org.jmodelica.icons.parts.coord.Extent;
import org.jmodelica.icons.parts.primitives.Types.TextAlignment;
import org.jmodelica.icons.parts.primitives.Types.TextStyle;


public class Text extends FilledRectShape {
	
	private String textString;
	private double fontSize;
	private String fontName;
	private ArrayList<Types.TextStyle> textStyle;  
	private Types.TextAlignment horizontalAlignment;
	
	private static final String DEFAULT_TEXT_STRING = "";
	private static final String DEFAULT_FONT_NAME = "";
	private static final double DEFAULT_FONT_SIZE = 0;
	private static final Types.TextAlignment DEFAULT_HORIZONTAL_ALIGNMENT = Types.TextAlignment.CENTER;
		
	public Text() {
		super(Extent.NO_EXTENT);
		textString = DEFAULT_TEXT_STRING;
		fontSize = DEFAULT_FONT_SIZE;
		fontName = DEFAULT_FONT_NAME;
		horizontalAlignment = DEFAULT_HORIZONTAL_ALIGNMENT;
		textStyle = new ArrayList<Types.TextStyle>();
	}
	public Text(Extent extent) {
		super(extent);
		textString = DEFAULT_TEXT_STRING;
		fontSize = DEFAULT_FONT_SIZE;
		fontName = DEFAULT_FONT_NAME;
		horizontalAlignment = DEFAULT_HORIZONTAL_ALIGNMENT;
		textStyle = new ArrayList<Types.TextStyle>();
	}
	
	public void setTextString(String textString) {
		this.textString = textString;
	}

	public String getTextString() {
		return textString;
	}

	public void setFontSize(double fontSize) {
		this.fontSize = fontSize;
	}

	public double getFontSize() {
		return fontSize;
	}

	public void setFontName(String fontName) {
		this.fontName = fontName;
	}

	public String getFontName() {
		return fontName;
	}

	public void setTextStyle(ArrayList<Types.TextStyle> textStyle) {
		this.textStyle = textStyle;
	}

	public ArrayList<Types.TextStyle> getTextStyle() {
		return textStyle;
	}

	public void setHorizontalAlignment(Types.TextAlignment horizontalAlignment) {
		this.horizontalAlignment = horizontalAlignment;
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