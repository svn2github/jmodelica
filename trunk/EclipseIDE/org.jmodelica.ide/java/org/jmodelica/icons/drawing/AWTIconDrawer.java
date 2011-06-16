package org.jmodelica.icons.drawing;

import java.awt.BasicStroke;
import java.awt.Font;
import java.awt.FontMetrics;
import java.awt.GradientPaint;
import java.awt.Graphics2D;
import java.awt.Paint;
import java.awt.RadialGradientPaint;
import java.awt.RenderingHints;
import java.awt.Shape;
import java.awt.Stroke;
import java.awt.TexturePaint;
import java.awt.MultipleGradientPaint.CycleMethod;
import java.awt.font.TextAttribute;
import java.awt.geom.AffineTransform;
import java.awt.geom.Ellipse2D;
import java.awt.geom.GeneralPath;
import java.awt.geom.Path2D;
import java.awt.geom.PathIterator;
import java.awt.geom.Point2D;
import java.awt.geom.Rectangle2D;
import java.awt.image.BufferedImage;
import java.awt.image.DirectColorModel;
import java.awt.image.WritableRaster;
import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.io.ByteArrayInputStream;
import java.net.MalformedURLException;
import java.util.ArrayList;
import java.util.Hashtable;
import java.util.Stack;


import javax.imageio.ImageIO;

import org.eclipse.jface.resource.ImageDescriptor;
import org.eclipse.swt.graphics.Image;
import org.eclipse.swt.graphics.ImageData;
import org.eclipse.swt.graphics.PaletteData;
import org.eclipse.swt.graphics.RGB;
import org.jmodelica.icons.Bitmap;
import org.jmodelica.icons.Color;
import org.jmodelica.icons.Component;
import org.jmodelica.icons.Ellipse;
import org.jmodelica.icons.Extent;
import org.jmodelica.icons.FilledRectShape;
import org.jmodelica.icons.FilledShape;
import org.jmodelica.icons.Icon;
import org.jmodelica.icons.Line;
import org.jmodelica.icons.Point;
import org.jmodelica.icons.Polygon;
import org.jmodelica.icons.Rectangle;
import org.jmodelica.icons.Text;
import org.jmodelica.icons.Transformation;
import org.jmodelica.icons.Types;
import org.jmodelica.icons.Types.FillPattern;
import org.jmodelica.icons.Types.LinePattern;
import org.jmodelica.icons.Types.TextAlignment;
import org.jmodelica.icons.exceptions.CreateShapeFailedException;
import org.jmodelica.icons.exceptions.FailedConstructionException;


public class AWTIconDrawer implements GraphicsInterface {
	
	private static final int BORDER_PATTERN_WIDTH = 2;
	
	public static final double MINIMUM_FONT_SIZE = 9.0;
	
	public static final BasicStroke DEFAULT_LINE_STROKE = 
		new BasicStroke((float)(Line.DEFAULT_THICKNESS*IconConstants.PIXLES_PER_MM),
			BasicStroke.CAP_BUTT, BasicStroke.JOIN_MITER, 10.0f, null, 0.0f);
	
	public static final BasicStroke DEFAULT_SHAPE_STROKE = 
		new BasicStroke((float)(FilledShape.DEFAULT_LINE_THICKNESS*IconConstants.PIXLES_PER_MM), 
			BasicStroke.CAP_BUTT, BasicStroke.JOIN_MITER, 10.0f, null, 0.0f);
	
	private static final int DEFAULT_FONT_STYLE = Font.PLAIN;
	private static final int DEFAULT_FONT_SIZE = 12;
	
	private boolean outline;
	private BufferedImage image;
	
	private Graphics2D g;
	private Stack<AffineTransform> savedTransformations;
	
	private Extent iconExtent;	
	
	public AWTIconDrawer() {
		savedTransformations = new Stack<AffineTransform>();
		outline = true;
	}
	
	public AWTIconDrawer(Icon icon) {
		savedTransformations = new Stack<AffineTransform>();
		outline = true;
		createBufferedImage(icon);
	}
	public AWTIconDrawer(Icon icon, boolean outline) {
		savedTransformations = new Stack<AffineTransform>();
		this.outline = outline;
		createBufferedImage(icon);
	}
	public void createBufferedImage(Icon icon) {
		
		double imageWidth,imageHeight,iconWidth,iconHeight;
		
		iconExtent = icon.getExtent();
		if(iconExtent == Extent.NO_EXTENT) {			
			return;
		} else {
    		iconExtent = icon.getBounds(iconExtent);
    		iconWidth = iconExtent.getWidth();
    		iconHeight = iconExtent.getHeight();
		}
		if(outline) {
	    		imageWidth=IconConstants.OUTLINE_IMAGE_SIZE-1;
	    		imageHeight=IconConstants.OUTLINE_IMAGE_SIZE-1;	
		}else {
			return;
		}
		double scaleWidth = (imageWidth-1)/iconWidth;
		double scaleHeight = (imageHeight-1)/iconHeight;
		
		image = new BufferedImage(
				(int)imageWidth, 
				(int)imageHeight, 
				BufferedImage.TYPE_INT_ARGB
		);
		
		// Create a graphics context on the buffered image
		g = image.createGraphics();
		g.setBackground(new java.awt.Color(255,255,255,0));
		g.clearRect(0, 0, image.getWidth(), image.getHeight());
        
        AffineTransform transform = new AffineTransform(); 
        
        transform.translate(
        		(imageWidth/2),
        		(imageHeight/2)
        );

		transform.scale(scaleWidth, scaleHeight);
		g.transform(transform); 
		   
		g.setRenderingHint(
				RenderingHints.KEY_ANTIALIASING, 
				RenderingHints.VALUE_ANTIALIAS_ON
		);
		
		icon.draw(this);
    }

	/**	
	 * Creates a BufferedImage representation of this object's ClassIcon.
	 */

	public BufferedImage getBufferedImage() {
		return image;
	}
	
	private double getAvgCurrentScaleFactor() {
		return (
				Math.abs(g.getTransform().getScaleX()) +
				Math.abs(g.getTransform().getScaleY())
		)/2.0;
	}
	
	private double getMinCurrentScaleFactor() {
		return Math.min(
				Math.abs(g.getTransform().getScaleX()), 
				Math.abs(g.getTransform().getScaleY())
		);
	}
	
	private double getMaxCurrentScaleFactor() {
		return Math.max(
				Math.abs(g.getTransform().getScaleX()), 
				Math.abs(g.getTransform().getScaleY())
		);
	}

	
	/**
	 * Draws the specified Text primitive in this object's Graphics2D
	 * context.
	 * @param t
	 */
	public void drawText(Text t, Icon icon) {
		
		boolean debugText = false;
	
		Extent extent = t.getExtent();
		int x = (int)(extent.getP1().getX());
		int y = -(int)(extent.getP2().getY());		
		int extentHeight = (int)t.getExtent().getHeight();
		int extentWidth = (int)t.getExtent().getWidth();
		
		
		g.setFont(this.setFont(t));
		String text = t.getTextString();
			
		// if fontsize is not set the text is scaled to fit its extent
		FontMetrics metrics;
		if(t.getFontSize() == 0)
		{
			// scale text to fit extext horizontally.
			int fontsize = g.getFont().getSize();
			int newSize = fontsize-(fontsize-extentHeight);
			g.setFont(g.getFont().deriveFont((float)newSize));
			
			// scale text to fit extent vertically.
			Font font = g.getFont();
			metrics = g.getFontMetrics(); 
			while (metrics.stringWidth(text) > extentWidth) {
				newSize = g.getFont().getSize()-1;
				font = g.getFont().deriveFont((float)newSize);
				g.setFont(font);
				metrics = g.getFontMetrics();		
			}
		}
		// place text in center 
		metrics = g.getFontMetrics();
		y += (int)((extentHeight+g.getFont().getSize())/2.0);
		if (t.getHorizontalAlignment() == TextAlignment.CENTER) {
			x += (int)((extentWidth-metrics.stringWidth(text))/2.0);
		} else if (t.getHorizontalAlignment() == TextAlignment.RIGHT) {
			x += extentWidth-metrics.stringWidth(text);
		}
		
		// Check if the text is large enough to be drawn.
		double currentScaleFactor = getMinCurrentScaleFactor();
		double actualFontSize = currentScaleFactor*(double)(g.getFont().getSize());
		if (actualFontSize < MINIMUM_FONT_SIZE) {
			return;
		}
		
		// Draw the text string.
		setColor(t.getLineColor());
		if (debugText) {
			try {
				g.draw(createShape(t));
			} catch(Exception e){}
		}
		g.drawString(text, x, y);
	}
	
	public void drawBitmap(Bitmap b) {
		try {
			doDrawBitmap(b);
		} catch(MalformedURLException e) {
//			System.out.println("Failed to draw bitmap primitive: " + e.getMessage());
		} catch(IOException e) {
//			System.out.println("Failed to draw bitmap primitive: " + e.getMessage());
		}
	}
		
	private void doDrawBitmap(Bitmap b) 
			throws MalformedURLException, IOException {
		BufferedImage bitmapImage = null;
		if (b.getFileName() != null) {
			bitmapImage = ImageIO.read(new File(b.getFileName()));
		} else if (b.getImageSource() != null) {
			byte decodedBytes[] = 
				new sun.misc.BASE64Decoder().decodeBuffer(b.getImageSource());
			InputStream in = new ByteArrayInputStream(decodedBytes);  
			bitmapImage = ImageIO.read(in);
		} 
		if (bitmapImage != null) {
			Extent extent = b.getExtent().fix();
			g.drawImage(
					bitmapImage, 
					(int)extent.getP1().getX(), 
					(int)extent.getP1().getY(), 
					(int)extent.getP2().getX(), 
					(int)extent.getP2().getY(),
					0,
					0,
					bitmapImage.getWidth(),
					bitmapImage.getHeight(),
					null
			);
		}
	}
	
	/**
	 * Draws the specified MSLLine primitive in this object's Graphics2D
	 * context.
	 * @param t
	 */
	public void drawLine(Line l) {
		if(l.getPoints().size() > 2 && l.getSmooth().equals(Types.Smooth.BEZIER)) {
			this.drawBezier(l);
		} else if (l.getPoints().size() >= 2) {

			// Tranform the points, after inverting their y-coordinate.
			ArrayList<Point> xformedPts = new ArrayList<Point>();
			for (Point p : l.getPoints()) {
				xformedPts.add(transform(new Point(p.getX(), -p.getY())));
			}
			
			// Create a new line from the transformed points.
			java.awt.geom.Path2D.Double xformedLine = new java.awt.geom.Path2D.Double();
			xformedLine.moveTo(xformedPts.get(0).getX(), xformedPts.get(0).getY());
			for (int i = 1; i < xformedPts.size(); i++) {
				Point point = xformedPts.get(i);
				xformedLine.lineTo(point.getX(), point.getY());
			}
			
			// Set up the Graphics object and draw the transformed line.
			setColor(l.getColor());
			Stroke newStroke = getLineStroke(l.getLinePattern(), l.getThickness());
			g.setStroke(newStroke);
			AffineTransform oldTransform = g.getTransform();
			g.setTransform(new AffineTransform());
			g.setRenderingHint(
					RenderingHints.KEY_STROKE_CONTROL, 
					RenderingHints.VALUE_STROKE_PURE
			);
			g.draw(xformedLine);
			g.setTransform(oldTransform);
			g.setRenderingHint(
					RenderingHints.KEY_STROKE_CONTROL, 
					RenderingHints.VALUE_STROKE_DEFAULT
			);
			
			// If the Line has arrows, draw them.
			Polygon[] arrows = l.getArrowPolygons();
			for (int i = 0; i < arrows.length; i++) {
				if (arrows[i] != null) {
					drawShape(arrows[i]);
				}
			}
		}
	}
	
	/**
	 * Draws the specified shape in this object's Graphics2D context.
	 * @param t
	 */
	public void drawShape(FilledShape s) {
		Shape shape;
		try {
			shape = createShape(s);
		} catch (CreateShapeFailedException e) {
//			System.out.println(e.getMessage());
			return;
		}
		
		// Transform each of the points in the shape using the current
		// AffineTransform of the Graphics2D object. 
		ArrayList<Point> xformedPts = new ArrayList<Point>();
		double[] coords = new double[6];
		PathIterator pathIterator = shape.getPathIterator(g.getTransform(), 0.05);
		while (!pathIterator.isDone()) {
			int segmentType = pathIterator.currentSegment(coords);
			if (segmentType == PathIterator.SEG_LINETO) {
				xformedPts.add(new Point(coords[0], coords[1]));
			}
			pathIterator.next();
		}

		// Create a new shape from the transformed coordinates. 		
		java.awt.geom.Path2D.Double xformedShape = new java.awt.geom.Path2D.Double();
		xformedShape.moveTo(xformedPts.get(0).getX(), xformedPts.get(0).getY());
		for (int i = 1; i < xformedPts.size(); i++) {
			Point point = xformedPts.get(i);
			xformedShape.lineTo(point.getX(), point.getY());
		}
		xformedShape.lineTo(xformedPts.get(0).getX(), xformedPts.get(0).getY());
		
		// Fill the shape.
		Types.FillPattern fillPattern = s.getFillPattern();
		if (!fillPattern.equals(FillPattern.NONE)) {
			Paint oldPaint = g.getPaint();
			if (fillPattern.equals(FillPattern.SOLID)) {
				setColor(s.getFillColor());
			} else {
				try {
					Paint p = getFillPaint(s);
					g.setPaint(p);
				} catch(IllegalArgumentException e) {
//					System.out.println(e);
				}
			}
			AffineTransform oldTransform = g.getTransform();
			g.setTransform(new AffineTransform());
			g.fill(xformedShape);
			g.setTransform(oldTransform);
			g.setPaint(oldPaint);
		}

		// Draw the shape.
		boolean gradient = (s.getFillPattern() == FillPattern.HORIZONTALCYLINDER ||
							s.getFillPattern() == FillPattern.VERTICALCYLINDER ||
							s.getFillPattern() == FillPattern.SPHERE);
		if (s.getLinePattern() != LinePattern.NONE && !gradient) {
			Stroke newStroke = getShapeStroke(s.getLinePattern(), s.getLineThickness()); 
			g.setStroke(newStroke);
			setColor(s.getLineColor());
			AffineTransform oldTransform = g.getTransform();
			g.setTransform(new AffineTransform());
			g.draw(xformedShape);
			g.setTransform(oldTransform);
		}
		
		if(s instanceof Rectangle) {
			Rectangle r = (Rectangle) s;
			Types.BorderPattern borderPattern = r.getBorderPattern(); 
			if(borderPattern != Types.BorderPattern.NONE) {
				drawBorderPattern(r);
			}
		}
	}
	
	private void drawBorderPattern(Rectangle r) {
		Types.BorderPattern borderPattern = r.getBorderPattern();
		Extent outerExtent = r.getExtent().fix();
		if (outerExtent.getWidth() > 2*BORDER_PATTERN_WIDTH+1 && outerExtent.getHeight() > 2*BORDER_PATTERN_WIDTH+1 ) {
			
			Point2D untransformedOuterP1 = new Point2D.Double(
					outerExtent.getP1().getX(), 
					outerExtent.getP1().getY()
			);
			Point2D untransformedOuterP2 = new Point2D.Double(
					outerExtent.getP2().getX(), 
					outerExtent.getP2().getY()
			);
			Point2D outerP1 = new Point2D.Double();
			Point2D outerP2 = new Point2D.Double();
			g.getTransform().transform(untransformedOuterP1, outerP1);
			g.getTransform().transform(untransformedOuterP2, outerP2);
			java.awt.Polygon upLeft = new java.awt.Polygon(
					new int[]{
							(int)outerP1.getX()+1, 
							(int)outerP1.getX()+1, 
							(int)outerP2.getX(), 
							(int)outerP2.getX()-BORDER_PATTERN_WIDTH, 
							(int)outerP1.getX()+1+BORDER_PATTERN_WIDTH, 
							(int)outerP1.getX()+1+BORDER_PATTERN_WIDTH, 
							(int)outerP1.getX()+1
					}, 
					new int[]{
							(int)outerP2.getY(), 
							(int)outerP1.getY()+1, 
							(int)outerP1.getY()+1, 
							(int)outerP1.getY()+1+BORDER_PATTERN_WIDTH, 
							(int)outerP1.getY()+1+BORDER_PATTERN_WIDTH, 
							(int)outerP2.getY()-BORDER_PATTERN_WIDTH, 
							(int)outerP2.getY()
					}, 
					7
			);
			java.awt.Polygon downRight = new java.awt.Polygon(
					new int[]{
							(int)outerP1.getX()+1, 
							(int)outerP2.getX(), 
							(int)outerP2.getX(), 
							(int)outerP2.getX()-BORDER_PATTERN_WIDTH, 
							(int)outerP2.getX()-BORDER_PATTERN_WIDTH, 
							(int)outerP1.getX()+1+BORDER_PATTERN_WIDTH, 
							(int)outerP1.getX()+1
					}, 
					new int[]{
							(int)outerP2.getY(), 
							(int)outerP2.getY(), 
							(int)outerP1.getY()+1, 
							(int)outerP1.getY()+1+BORDER_PATTERN_WIDTH, 
							(int)outerP2.getY()-BORDER_PATTERN_WIDTH, 
							(int)outerP2.getY()-BORDER_PATTERN_WIDTH, 
							(int)outerP2.getY()
					}, 
					7
			);
			java.awt.Color upLeftColor = null;
			java.awt.Color downRightColor = null;
			java.awt.Color brighterColor = translateColor(r.getFillColor().brighter());
			java.awt.Color darkerColor = translateColor(r.getFillColor()).darker();
			if (borderPattern == Types.BorderPattern.RAISED) {
				upLeftColor = brighterColor;
				downRightColor = darkerColor;
			} else if (borderPattern == Types.BorderPattern.SUNKEN) {
				upLeftColor = darkerColor;
				downRightColor = brighterColor;
			}
			AffineTransform oldTransform = g.getTransform();
			g.setTransform(new AffineTransform());
			g.setColor(upLeftColor);
			g.fill(upLeft);
			g.setColor(downRightColor);
			g.fill(downRight);
			g.setTransform(oldTransform);
		}
	}
	
	private void drawBezier(Line l) 
	{	
		ArrayList<Point> linePoints = l.getPoints();
		for(Point lp : linePoints)
		{
			/* invert y to compensate java */
			lp.setY(-(lp.getY()));
		}
		ArrayList<Point> bezierPoints = new ArrayList<Point>();
		for(int i = 0; i < linePoints.size()-1; i++)
		{
			double x = (linePoints.get(i).getX() + linePoints.get(i+1).getX()) / 2;
			double y = (linePoints.get(i).getY() + linePoints.get(i+1).getY()) / 2;
			bezierPoints.add(new Point(x, y));
		}
		GeneralPath gp = new GeneralPath();
		gp.moveTo(linePoints.get(0).getX(), linePoints.get(0).getY());
		gp.lineTo(bezierPoints.get(0).getX(), bezierPoints.get(0).getY());
		for(int i = 1; i < bezierPoints.size(); i++)
		{
			gp.quadTo(linePoints.get(i).getX(), linePoints.get(i).getY(), 
					bezierPoints.get(i).getX(), bezierPoints.get(i).getY());
		}
		gp.lineTo(linePoints.get(linePoints.size()-1).getX(), 
				linePoints.get(linePoints.size()-1).getY());
		
		setColor(l.getColor());
		Stroke newStroke = getLineStroke(l.getLinePattern(), l.getThickness()); 
		if (newStroke != null) {
			g.setStroke(newStroke);
		}
		g.draw(gp);
	}
	/**
	 * Applies the transformation of the specified component's icon layer 
	 * specification.
	 * @param component
	 */
	public void setTransformation(Component comp, Extent enclosingClassExtent) {	
		
		AffineTransform transform = g.getTransform();
		
		Transformation compTransformation = comp.getPlacement().getTransformation();
		Extent transformationExtent = compTransformation.getExtent();
		Extent componentExtent = comp.getIcon().getLayer().getCoordinateSystem().getExtent();
		
		double originX = 
						compTransformation.getOrigin().getX() + 
						transformationExtent.getMiddle().getX() +
						enclosingClassExtent.getMiddle().getX(); 
						
		
		double originY = 
						compTransformation.getOrigin().getY() + 
						transformationExtent.getMiddle().getY() +
						enclosingClassExtent.getMiddle().getY(); 
		
		transform.translate(originX, -originY);
		
		if(transformationExtent.getP2().getX() < transformationExtent.getP1().getX()) {
			transform.scale(-1.0, 1.0);
		}
		if(transformationExtent.getP2().getY() < transformationExtent.getP1().getY()) {
			transform.scale(1.0, -1.0);
		}
		transform.scale(transformationExtent.getWidth()/componentExtent.getWidth(), 
				transformationExtent.getHeight()/componentExtent.getHeight());
		
		transform.rotate(-compTransformation.getRotation() * Math.PI/180);
		g.setTransform(transform);
	}
	public void saveTransformation() {
		savedTransformations.push(g.getTransform());
	}
	
	public void resetTransformation() {
		g.setTransform(savedTransformations.pop());
	}
	
	/**
	 * Creates a Paint object that matches the shape's colors and fill pattern.
	 * 
	 * @param shape
	 * @return
	 */
	private Paint getFillPaint(FilledShape shape) {
		if (shape.getFillPattern() == FillPattern.HORIZONTAL
				|| shape.getFillPattern() == FillPattern.VERTICAL
				|| shape.getFillPattern() == FillPattern.FORWARD
				|| shape.getFillPattern() == FillPattern.BACKWARD
				|| shape.getFillPattern() == FillPattern.CROSS
				|| shape.getFillPattern() == FillPattern.CROSSDIAG) {
			return getTextureFillPaint(shape);
		}
		Paint paint;
		Extent extent; 		
		
		// Fetch the extent.
		if (shape instanceof FilledRectShape) {
			extent = ((FilledRectShape) shape).getExtent();
		} else if (shape instanceof Polygon) {
			extent = ((Polygon) shape).getBounds();
		} else {
			throw new IllegalArgumentException("getFillPaint");
		}
		
		// Transform the extent with the current transformation.
		extent = transform(extent);
		
		// Create the Paint object.
		double width = extent.getWidth();
		double height = extent.getHeight();
		if (shape.getFillPattern() == FillPattern.VERTICALCYLINDER
				|| shape.getFillPattern() == FillPattern.HORIZONTALCYLINDER) {
			Point2D p1 = new Point2D.Double(extent.getP1().getX(), extent.getP1()
					.getY());
			Point2D p2 = new Point2D.Double(extent.getP2().getX(), extent.getP2()
					.getY());
			if (shape.getFillPattern() == FillPattern.VERTICALCYLINDER) {
				p1.setLocation(p1.getX(), p1.getY() + 0.5 * height);
				p2.setLocation(p2.getX() - 0.5 * width, p2.getY() - 0.5
						* height);
			} else if (shape.getFillPattern() == FillPattern.HORIZONTALCYLINDER) {
				p1.setLocation(p1.getX() + 0.5 * width, p1.getY());
				p2.setLocation(p2.getX() - 0.5 * width, p2.getY() - 0.5
						* height);
			}
			// Flip the y-axis of the points.
			p1.setLocation(p1.getX(), -p1.getY());
			p2.setLocation(p2.getX(), -p2.getY());
			paint = new GradientPaint(
					p1, 
					translateColor(shape.getLineColor()), 
					p2,
					translateColor(shape.getFillColor()), 
					true
			);
		} else if (shape.getFillPattern() == FillPattern.SPHERE) {
			float[] fractions = { 0.0f, 1.0f };
			java.awt.Color[] colors = {
					translateColor(shape.getFillColor()), 
					translateColor(shape.getLineColor()) 
			};
			double midx = extent.getMiddle().getX();
			double midy = extent.getMiddle().getY();
			double x = midx-width;
			double y = midy-height;
			paint = new RadialGradientPaint(
					new Rectangle2D.Double(
							x, 
							y, 
							2*width, 
							2*height
					),
					fractions, 
					colors, 
					CycleMethod.NO_CYCLE
			);
		} else {
			throw new IllegalArgumentException("getFillPaint");
		}
		return paint;
	}
	/**
	 * Creates a TexturePaint object that matches the shape's colors and fill
	 * pattern.
	 * 
	 * @param s
	 * @return
	 */
	private Paint getTextureFillPaint(FilledShape s) {
        
		int textureSize = 7;
		float lineThickness = 1.0f;
		int anchorWidth = 7;
		int anchorHeight = 7;
		
		BufferedImage img = new BufferedImage(
				textureSize, 
				textureSize, 
				BufferedImage.TYPE_INT_RGB
		);

		Graphics2D graphics = img.createGraphics();
		
		graphics.setColor(translateColor(s.getFillColor()));
		graphics.fillRect(0, 0, textureSize, textureSize);
		
		graphics.setColor(translateColor(s.getLineColor()));
		
		graphics.setStroke(
				new BasicStroke(
						lineThickness,
						BasicStroke.CAP_BUTT, 
						BasicStroke.JOIN_MITER, 
						10.0f, 
						null, 
						0.0f
				)
		);
		if (s.getFillPattern().equals(FillPattern.BACKWARD)) {
			graphics.drawLine(0, 0, textureSize, textureSize);
		} else if (s.getFillPattern().equals(FillPattern.FORWARD)) {
			graphics.drawLine(textureSize, 0, 0, textureSize);
		} else if (s.getFillPattern().equals(FillPattern.CROSSDIAG)) {
			graphics.drawLine(0, 0, textureSize, textureSize);
			graphics.drawLine(textureSize, 0, 0, textureSize);
		} else if (s.getFillPattern().equals(FillPattern.HORIZONTAL)) {
			graphics.drawLine(0, textureSize/2, textureSize, textureSize/2);
		} else if (s.getFillPattern().equals(FillPattern.VERTICAL)) {
			graphics.drawLine(textureSize/2, 0, textureSize/2, textureSize);		
		} else if (s.getFillPattern().equals(FillPattern.CROSS)) {
			graphics.drawLine(0, textureSize/2, textureSize, textureSize/2);
			graphics.drawLine(textureSize/2, 0, textureSize/2, textureSize);
		}
		
		return new TexturePaint(
				img, 
				new java.awt.Rectangle(
						0, 
						0,
						anchorWidth, 
						anchorHeight
				)
		);
	}
	public Image getImage() {
		ImageData imagedata = null;
		if(image == null){
			return null; 
		}
	    if(image.getColorModel() instanceof DirectColorModel) {
	    	DirectColorModel colorModel
	                = (DirectColorModel) image.getColorModel();
	        PaletteData palette = new PaletteData(colorModel.getRedMask(),
	                colorModel.getGreenMask(), colorModel.getBlueMask());
	        	        
	        imagedata = new ImageData(IconConstants.OUTLINE_IMAGE_SIZE,
	        		IconConstants.OUTLINE_IMAGE_SIZE, colorModel.getPixelSize(),
	                palette);
	   
	        
	        for (int y = 0; y < imagedata.height; y++) {
	        	int x = 0;
	        	imagedata.setAlpha(x, y, 0);

	        }
        	for (int x = 0; x < imagedata.width; x++) {
        		int y = imagedata.height-1;
        		imagedata.setAlpha(x, y, 0);
        	}
	        for (int y = 0; y < image.getHeight(); y++) {
	            for (int x = 0; x < image.getWidth(); x++) {
	            	int rgb = image.getRGB(x, y);
	            	int pixel = palette.getPixel(new RGB((rgb >> 16) & 0xFF, (rgb >> 8) & 0xFF, rgb & 0xFF));
	            	imagedata.setPixel(x+1, y, pixel);
	            	imagedata.setAlpha(x+1, y, (rgb >> 24) & 0xFF);
	            }
	        }
	    }
	    else {	
	    	return null;
	    }
		ImageDescriptor desc = ImageDescriptor.createFromImageData(imagedata);
		return desc.createImage(); 
	}	

	public Font setFont(Text text) {
		
		Font font = new Font(text.getFontName(), DEFAULT_FONT_STYLE, DEFAULT_FONT_SIZE);
		double textFontSize = text.getFontSize();
		if (textFontSize != 0) {
		font = font.deriveFont((float) textFontSize);
		}
		Hashtable<TextAttribute, Object> map = new Hashtable<TextAttribute, Object>();
		boolean bold = false;
		boolean italic = false;
		if (text.getTextStyle() != null) {
			for (Types.TextStyle ts : text.getTextStyle())
			{
				if (ts == Types.TextStyle.UNDERLINE) {
					map.put(TextAttribute.UNDERLINE, TextAttribute.UNDERLINE_ON);
				}
				if (ts == Types.TextStyle.BOLD) {
					bold = true;
				}
				if (ts == Types.TextStyle.ITALIC) {
					italic = true;
				}
			}
			if (bold && italic) {
				font = font.deriveFont(Font.ITALIC | Font.BOLD);
			} else if (bold) {
				font = font.deriveFont(Font.BOLD);
			} else if (italic) {
				font = font.deriveFont(Font.ITALIC);
			}
		}
		font = font.deriveFont(map);
		return font;
	}
	
	private Shape createShape(Text t) throws CreateShapeFailedException {
		return createRectShape(t.getExtent());
	}

	private Shape createShape(Rectangle r) throws CreateShapeFailedException {
		return createRectShape(r.getExtent());
	}
	
	private Shape createRectShape(Extent extent) throws CreateShapeFailedException {
		if (extent == Extent.NO_EXTENT) {
			throw new CreateShapeFailedException("MLSRectangle");
		}
		return new java.awt.geom.Rectangle2D.Double(
			(extent.getP1().getX()),
			-(extent.getP2().getY()),
			(extent.getP2().getX()-extent.getP1().getX()),
			(extent.getP2().getY()-extent.getP1().getY())
		);		
	}
	
	private Shape createShape(Polygon p) throws CreateShapeFailedException {
		ArrayList<Point> points = p.getPoints();
		Path2D.Double path = new Path2D.Double();
		path.moveTo(points.get(0).getX(), -points.get(0).getY());
		for (int i = 1; i < points.size(); i++) {
			Point point = points.get(i);
			path.lineTo(point.getX(), -point.getY());
		}
		path.lineTo(points.get(0).getX(), -points.get(0).getY());
		return path;
	}
	
	private Shape createShape(Ellipse e) throws CreateShapeFailedException {
		Extent extent = e.getExtent();
		if (extent == Extent.NO_EXTENT) {
			throw new CreateShapeFailedException("Ellipse");
		}
		return new Ellipse2D.Double(
				extent.getP1().getX(),
				-(extent.getP2().getY()),
				extent.getP2().getX()-extent.getP1().getX(),
				extent.getP2().getY()-extent.getP1().getY()
		);
	}
	
	private Shape createShape(FilledShape s) throws CreateShapeFailedException {
		if (s instanceof Ellipse) {
			return createShape((Ellipse)s);
		} else if (s instanceof Rectangle) {
			return createShape((Rectangle)s);
		} else if (s instanceof Polygon) {
			return createShape((Polygon)s);
		} else {
			return createShape((Text)s);
		}
	}
	
	public Stroke getShapeStroke(LinePattern linepattern, double thicknessInMM) {
		if (thicknessInMM > IconConstants.MAX_SHAPE_THICKNESS) {
			thicknessInMM = IconConstants.MAX_SHAPE_THICKNESS;
		}
		float thicknessInPixles = (float)(thicknessInMM*IconConstants.PIXLES_PER_MM*IconConstants.DEFAULT_LINE_THICKNESS_IN_PIXLES);
		return new BasicStroke(thicknessInPixles, BasicStroke.CAP_BUTT,
				BasicStroke.JOIN_MITER, 10.0f, linepattern.getDash(), 0.0f);
	}
	
	public Stroke getLineStroke(LinePattern linepattern, double thicknessInMM) {
		if (thicknessInMM > IconConstants.MAX_LINE_THICKNESS) {
			thicknessInMM = IconConstants.MAX_LINE_THICKNESS;
		}
		float thicknessInPixles = (float)(thicknessInMM*IconConstants.PIXLES_PER_MM*IconConstants.DEFAULT_LINE_THICKNESS_IN_PIXLES);
		return new BasicStroke((float)(thicknessInPixles), BasicStroke.CAP_BUTT,
				BasicStroke.JOIN_MITER, 10.0f, linepattern.getDash(), 0.0f);
	}
	
	public void setColor(Color color) {
		g.setColor(translateColor(color));
	}
	
	public void setBackgroundColor(Color color) {
		g.setBackground(translateColor(color));
	}	

	private java.awt.Color translateColor(Color color) {
		java.awt.Color c = new java.awt.Color(color.getR(), color.getG(), color.getB());
		return c;
	}
	
	/**
	 * Returns the given point transformed by this object's current 
	 * transformation.
	 * @param p The Point to transform.
	 * @return The transformed Point.
	 */
	private Point transform(Point p) {
		Point2D.Double p2d = new Point2D.Double(p.getX(), p.getY());
		g.getTransform().transform(p2d, p2d);
		return new Point(p2d.getX(), p2d.getY());
	}
	
	/**
	 * Returns the given extent transformed by this object's current 
	 * transformation.
	 * @param e The Extent to transform.
	 * @return The transformed Extent.
	 */
	private Extent transform(Extent e) {
		return new Extent(
			transform(e.getP1()),
			transform(e.getP2())
		);
	}
}
