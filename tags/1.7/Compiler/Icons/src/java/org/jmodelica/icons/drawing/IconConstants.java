package org.jmodelica.icons.drawing;

import org.jmodelica.icons.primitives.FilledShape;
import org.jmodelica.icons.primitives.Line;



public class IconConstants {
		
	public static final int OUTLINE_IMAGE_SIZE = 22;
	public static final float BORDER_PATTERN_THICKNESS = 3.0f;
	
	public static final double DEFAULT_LINE_THICKNESS_IN_PIXLES = 0.9;
	public static final double PIXLES_PER_MM = 4;
	
	public static final double MAX_LINE_THICKNESS = Line.DEFAULT_THICKNESS;
	public static final double MAX_SHAPE_THICKNESS = FilledShape.DEFAULT_LINE_THICKNESS;
	
	public static final String IMAGE_FILE_PATH = "./Resources/";
	public static final double TEXTURE_PATTERN_DISTANCE = 10.0;
	
	public static enum Context {
		ICON,
		DIAGRAM
	}
}
