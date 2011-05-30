package org.jmodelica.icons;

import java.awt.BasicStroke;
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
import org.jmodelica.icons.mls.Color;
import org.jmodelica.icons.mls.Extent;
import org.jmodelica.icons.mls.FilledRectShape;
import org.jmodelica.icons.mls.FilledShape;
import org.jmodelica.icons.mls.Line;
import org.jmodelica.icons.mls.Point;
import org.jmodelica.icons.mls.Polygon;
import org.jmodelica.icons.mls.Rectangle;
import org.jmodelica.icons.mls.Text;
import org.jmodelica.icons.mls.Types;
import org.jmodelica.icons.mls.Types.FillPattern;
import org.jmodelica.icons.mls.Types.LinePattern;
import org.jmodelica.ide.Activator;
//import org.jmodelica.icons.enums.LinePattern;

public class GraphicsUtil {

	public static final String IMAGE_FILE_PATH = "./Resources/";
	public static final double TEXTURE_PATTERN_DISTANCE = 10.0;
	private static final int COLOR_INCREMENT = 50;
	
	public static Color getBrighter(Color c) {
		int r = c.getR()+COLOR_INCREMENT;
		int g = c.getG()+COLOR_INCREMENT;
		int b = c.getB()+COLOR_INCREMENT;
		if (r > 255) {
			r = 255;
		}
		if (g > 255) {
			g = 255;
		}
		if (b > 255) {
			b = 255;
		}
		return new Color(r, g, b);
	}

	public static Color getDarker(Color c) {
		int r = c.getR()-COLOR_INCREMENT;
		int g = c.getG()-COLOR_INCREMENT;
		int b = c.getB()-COLOR_INCREMENT;
		if (r < 0) {
			r = 0;
		}
		if (g < 0) {
			g = 0;
		}
		if (b < 0) {
			b = 0;
		}
		return new Color(r, g, b);
	}
	
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