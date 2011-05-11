package org.jmodelica.icons;

import java.awt.BasicStroke;
import java.awt.Color;
import java.awt.GradientPaint;
import java.awt.Graphics2D;
import java.awt.MultipleGradientPaint.CycleMethod;
import java.awt.Paint;
import java.awt.RadialGradientPaint;
import java.awt.Stroke;
import java.awt.TexturePaint;
import java.awt.geom.Point2D;
import java.awt.geom.Rectangle2D;
import java.awt.image.BufferedImage;

import java.io.File;
import java.io.IOException;
import java.net.URL;
import java.util.ArrayList;

import javax.imageio.ImageIO;

import org.eclipse.core.runtime.FileLocator;
import org.jmodelica.icons.exceptions.FailedConstructionException;
import org.jmodelica.icons.mls.Types;
import org.jmodelica.icons.mls.Types.FillPattern;
import org.jmodelica.icons.mls.Types.LinePattern;
import org.jmodelica.icons.mls.primitives.Extent;
import org.jmodelica.icons.mls.primitives.FilledRectShape;
import org.jmodelica.icons.mls.primitives.FilledShape;
import org.jmodelica.icons.mls.primitives.Line;
import org.jmodelica.icons.mls.primitives.Point;
import org.jmodelica.icons.mls.primitives.Polygon;
import org.jmodelica.icons.mls.primitives.Rectangle;
import org.jmodelica.icons.mls.primitives.Text;
import org.jmodelica.ide.Activator;
//import org.jmodelica.icons.enums.LinePattern;

public class GraphicsUtil {

//	public static final double PIXLES_PER_MM = 2.0;
	public static final String IMAGE_FILE_PATH = "./Resources/";
	public static final double TEXTURE_PATTERN_DISTANCE = 10.0;


	/**
	 * Creates a Paint object that matches the shape's colors and fill pattern.
	 * 
	 * @param shape
	 * @return
	 */

	/**
	 * Creates and returns a Stroke object that matches the specified line
	 * pattern and thickness.
	 * 
	 * @param pattern
	 * @param thickness
	 * @return
	 */
	
	
	/**
	 * Changes the specified Font object to match the font of the provided Text
	 * primitive. The changed Font object is then returned.
	 * 
	 * @param font
	 * @param text
	 * @return
	 */
	
	/**
	 * Returns a list of points that can be used for drawing the border pattern
	 * of the specified MSLRectangle.
	 */
	public static ArrayList<Point> getBorderPatternPoints(Rectangle rect,
			Types.BorderPattern borderPatternType)
			throws FailedConstructionException {
		ArrayList<Point> points = new ArrayList<Point>();
		Extent extent = rect.getExtent();
		double x1 = 0, x2 = 0, x3 = 0, y1 = 0, y2 = 0, y3 = 0;
		if (borderPatternType.equals(Types.BorderPattern.RAISED)) {
			x1 = extent.getP1().getX();
			y1 = extent.getP1().getY();
			x2 = extent.getP2().getX();
			y2 = extent.getP1().getY();
			x3 = extent.getP2().getX();
			y3 = extent.getP2().getY();
		} else if (borderPatternType.equals(Types.BorderPattern.SUNKEN)) {
			x1 = extent.getP1().getX();
			y1 = extent.getP1().getY();
			x2 = extent.getP1().getX();
			y2 = extent.getP2().getY();
			x3 = extent.getP2().getX();
			y3 = extent.getP2().getY();
		} else {
			throw new FailedConstructionException();
		}
		points.add(new Point(x1, y1));
		points.add(new Point(x2, y2));
		points.add(new Point(x3, y3));
		return points;
	}

	/**
	 * Returns an array containing the x values of all of the specified MLSPoint
	 * objects.
	 * 
	 * @param points
	 * @return
	 */
	public static int[] getXLinePoints(ArrayList<Point> points) {
		int[] xPoints = new int[points.size()];
		for (int i = 0; i < points.size(); i++) {
			xPoints[i] = (int) (points.get(i).getX());
		}
		return xPoints;
	}

	/**
	 * Returns an array containing the y values of all of the specified MLSPoint
	 * objects.
	 * 
	 * @param points
	 * @return
	 */
	public static int[] getYLinePoints(ArrayList<Point> points) {
		int[] yPoints = new int[points.size()];
		for (int i = 0; i < points.size(); i++) {
			/* invert y to compensate java */
			yPoints[i] = -(int) (points.get(i).getY());
		}
		return yPoints;
	}
}