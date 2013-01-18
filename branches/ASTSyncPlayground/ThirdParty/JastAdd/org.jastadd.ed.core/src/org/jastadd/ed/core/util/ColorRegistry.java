package org.jastadd.ed.core.util;

import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;

//import org.eclipse.jdt.ui.text.IColorManager;
//import org.eclipse.jdt.ui.text.IColorManagerExtension;
import org.eclipse.swt.graphics.Color;
import org.eclipse.swt.graphics.RGB;
import org.eclipse.swt.widgets.Display;

public class ColorRegistry { //implements IColorManager, IColorManagerExtension {
	
	public static final RGB COLOR_LIGHT_GREEN = new RGB(0x9f,0xb8,0x73);
	public static final RGB COLOR_FORREST_GREEN = new RGB(0xb, 0x5f, 0x4);
	public static final RGB COLOR_LIGHT_BLUE = new RGB(0xc5,0xdb,0xed);
	public static final RGB COLOR_PURPLE = new RGB(0x7f,0x00,0x55);
	public static final RGB COLOR_LIGHT_PURPLE = new RGB(0xa6,0x72,0xe0);
	public static final RGB COLOR_MIDDLE_BLUE = new RGB(0x5c, 0x78, 0xbf);
	public static final RGB COLOR_LIGHT_ORANGE = new RGB(0xc8, 0x8b, 0x1f);
	public static final RGB COLOR_GREY = new RGB(0x85, 0x82, 0x82);
	public static final RGB COLOR_LIGHT_YELLOW = new RGB(0xfb, 0xf9, 0xb9);
	
	private Map<RGB,Color> fColors = new HashMap<RGB,Color>();
	private Map<String,RGB> fKeys = new HashMap<String,RGB>();
	
	
	private static ColorRegistry instance;
	
	private ColorRegistry() {
	}
	
	public static ColorRegistry instance() {
		if (instance == null) {
			instance = new ColorRegistry();
		}
		return instance;
	}
	
	
	//@Override
	public void dispose() {
		Iterator<Color> iter = fColors.values().iterator();
		while(iter.hasNext()) {
			Color color = (Color)iter.next();
			color.dispose();
		}
		
	}
	
	//@Override
	public Color getColor(RGB rgb) {
		Color color = (Color)fColors.get(rgb);
		if(color == null) {
			color = new Color(Display.getCurrent(), rgb);
			fColors.put(rgb, color);
		}
		return color;
	}

	//@Override
	public Color getColor(String key) {
		if (key == null)
			return null;
		RGB rgb = (RGB) fKeys.get(key);
		return getColor(rgb);
		
	}

	//@Override
	public void bindColor(String key, RGB rgb) {
		Object value = fKeys.get(key);
		if (value != null)
			throw new UnsupportedOperationException();
		fKeys.put(key, rgb);
	}
	
	//@Override
	public void unbindColor(String key) {
		fKeys.remove(key);
	}
}
