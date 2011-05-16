package org.jmodelica.icons;

import java.awt.Color;
import java.awt.Font;
import java.awt.FontMetrics;
import java.awt.GradientPaint;
import java.awt.Graphics2D;
import java.awt.Paint;
import java.awt.RadialGradientPaint;
import java.awt.Stroke;
import java.awt.TexturePaint;
import java.awt.MultipleGradientPaint.CycleMethod;
import java.awt.geom.AffineTransform;
import java.awt.geom.GeneralPath;
import java.awt.geom.Point2D;
import java.awt.geom.Rectangle2D;
import java.awt.image.BufferedImage;
import java.util.ArrayList;

import org.eclipse.swt.graphics.Image;
import org.jmodelica.icons.enums.IconContext;
import org.jmodelica.icons.exceptions.CreateShapeFailedException;
import org.jmodelica.icons.exceptions.FailedConstructionException;
import org.jmodelica.icons.mls.Component;
import org.jmodelica.icons.mls.CoordinateSystem;
import org.jmodelica.icons.mls.Icon;
import org.jmodelica.icons.mls.Layer;
import org.jmodelica.icons.mls.Placement;
import org.jmodelica.icons.mls.Types;
import org.jmodelica.icons.mls.Types.FillPattern;
import org.jmodelica.icons.mls.Types.LinePattern;
import org.jmodelica.icons.mls.Types.TextAlignment;
import org.jmodelica.icons.mls.primitives.Extent;
import org.jmodelica.icons.mls.primitives.FilledRectShape;
import org.jmodelica.icons.mls.primitives.FilledShape;
import org.jmodelica.icons.mls.primitives.GraphicItem;
import org.jmodelica.icons.mls.primitives.Line;
import org.jmodelica.icons.mls.primitives.Point;
import org.jmodelica.icons.mls.primitives.Polygon;
import org.jmodelica.icons.mls.primitives.Rectangle;
import org.jmodelica.icons.mls.primitives.Text;

public class IconImage {
	
	private GraphicsInterface gi;
	private Icon icon;
	
//	private int preferredWidth;
//	private int preferredHeight;
//	
//	private Icon icon;
//	private int layer;
//	private boolean outline;
//	private BufferedImage image;
//	
//	private Graphics2D g;
		
	public IconImage(Icon icon, GraphicsInterface gi) {
		this.gi = gi;
		this.icon = icon;
	}
//	
//	public IconImage(Icon icon) {
//		this(icon, IconConstants.ICON_LAYER, true);
//	}
//	
//	/** Creates an object for making BufferedImages from a ClassIcon.
//	 * @param  icon ClassIcon to make a BufferedImage of. 
//	 * @param iconView setting iconView to true generates an icon representation of the component. 
//	 * Setting iconView to false generates a diagram representation of the component.   
//	 * @param outlineIcon setting outlineIcon to true scale the bufferImage object to fit IDE outline size.
//	 */
//	//TODO: EXCEPTION?? VAR OCH HUR?
//	// TODO: InitialScale
//	//layer är beroende på användarens val i editorn diagram eller ikon
//	public IconImage(Icon icon, int layer, boolean outline) {
//		/*throws FailedConstructionException {
//		if(icon == null) {
//			throw new FailedConstructionException("IconImage");
//		}*/
//		if(icon == null) {
//			return;
//		}
//		this.icon = icon;
//		this.outline = outline;
//		this.layer = layer;
//		
//		// Om man inte anger önskad bredd och höjd, använder vi klassens
//		// ursprungliga bredd och höjd:
//		//this.preferredWidth = (int)icon.getExtent(layer).getWidth();
//		//this.preferredHeight = (int)icon.getExtent(layer).getHeight();
//		
//		createBufferedImage();
//		//System.out.println("Skapar ikon för:" + icon);
//	}
//	//context är beroende på användarens val i editorn diagram eller ikon
//	public IconImage(Icon icon, IconContext context, boolean outline) {
//		if(icon == null) {
//		}
//		this.icon = icon;
//		this.outline = outline;
//		createBufferedImage();
//	}
//
//	public IconImage(Icon icon, int layer, boolean outline, 
//			int preferredWidth, int preferredHeight) {
//		this.preferredWidth = preferredWidth;
//		this.preferredHeight = preferredHeight;
//		this.icon = icon;
//		this.outline = outline;
//		this.layer = layer;
//		createBufferedImage();
//	}
//	
//	/**	
//	 * Creates a BufferedImage representation of this object's ClassIcon.
//	 */
//	public void createBufferedImage() {
//		//ej färdigt
////		Extent extent = icon.getExtent(layer);
////		int imageHeight = (int)(extent.getHeight()*IconConstants.IMAGE_SIZE_SCALE);
////		int imageWidth = (int)(extent.getWidth()*IconConstants.IMAGE_SIZE_SCALE);
//	
////		Extent extent = new Extent(new MSLPoint(-50.0, -50.0),new MSLPoint(50.0, 50.0));;
////		if(icon.getLayer(layer).equals(Layer.NO_LAYER))
////		{
////			ArrayList<Icon> superIcons = icon.getSupercomponents();
////			for(Icon s : superIcons) {
////				if(!s.getLayer(layer).equals(Layer.NO_LAYER)) {
////					extent = s.getLayer(layer).getCoordinateSystem().getExtent();
////					break;
////				}
////			}	
////		}
////		System.out.println(extent.toString());
////		int imageHeight = (int)(extent.getHeight()*IconConstants.IMAGE_SIZE_SCALE);
////		int imageWidth = (int)(extent.getWidth()*IconConstants.IMAGE_SIZE_SCALE);
//		
//		int imageHeight = (int)(IconConstants.DEFAULT_IMAGE_SIZE * IconConstants.IMAGE_SIZE_SCALE);
//		int imageWidth = (int)(IconConstants.DEFAULT_IMAGE_SIZE * IconConstants.IMAGE_SIZE_SCALE);
//		
////		Extent iconBounds = icon.getBounds(new Extent(new Point(-1, -1), new Point(1, 1)));
////		double translateX = iconBounds.getMiddle().getX();
////		double translateY = iconBounds.getMiddle().getY();
////		int imageWidth = (int)iconBounds.getWidth()+6;
////		int imageHeight = (int)iconBounds.getHeight()+6;
//		
//		float scaleHeight = 1.0f; 
//	    float scaleWidth = 1.0f; 
//	    if(outline)
//		{
//			scaleHeight = (float)(1.0f * IconConstants.DEFAULT_ICON_SIZE/imageHeight);
//			scaleWidth = (float)(1.0f * IconConstants.DEFAULT_ICON_SIZE/imageWidth);
//		} else {
//			scaleHeight = (float)(1.0f * preferredHeight/imageHeight);
//			scaleWidth = (float)(1.0f * preferredWidth/imageWidth);
//		}
//	    
//		// The size of the image after scaling.
//		imageWidth *= scaleWidth;
//		imageHeight *= scaleHeight;
//	    image = new BufferedImage(
//        		imageWidth, 
//        		imageHeight, 
//        		BufferedImage.TYPE_INT_RGB
//        );
//         
//        // Create a graphics context on the buffered image
//        g = image.createGraphics();
//        
//        g.setBackground(Color.WHITE);
//        
//        // Clear the image.
//        g.clearRect(0, 0, image.getWidth(), image.getHeight());
//        
//        AffineTransform transform = new AffineTransform(); 
//        
//        //transform.translate(-extent.p1.getX(), -extent.p1.getY());
//        transform.translate(
//        		image.getWidth()/2/*+translateX*scaleWidth*/, 
//        		image.getHeight()/2/*+translateY*scaleHeight*/
//        );
//        
//        transform.scale(scaleWidth, scaleHeight);
//        
//        g.transform(transform);
//
//        //drawComponent(icon);
//        drawIcon(icon);
//    }
//	
//	public BufferedImage getBufferedImage() {
//		return image;
//	}
//	
	
	// Image image = new IconImage(icon, new AWTIconDrawer(icon, IconConstants.ICON_LAYER, true));
	
	public Image getImage() {
		drawIcon(icon);
		return ((AWTIconDrawer) gi).getImage();
	}
	
	private void drawIcon(Icon icon) {
		
        // Hitta superklasser och rita dem.
    	for (Icon superIcon : icon.getSuperclasses()) {
    		drawIcon(superIcon);
    	}
		
		// Rita den här klassen.
		Layer l = icon.getLayer();
		if (/*l != null && */!l.equals(Layer.NO_LAYER)) {
			ArrayList<GraphicItem> items = l.getGraphics();
			if (items != null) {
		        for (GraphicItem item : items) {
		        	if (item instanceof Line) {
		        		gi.drawLine((Line)item);
		        	} else {
		        		FilledShape filledShape = (FilledShape)item;
		        		if (item instanceof Text) {
		        			gi.drawText((Text)filledShape, icon);
		        		} else {
		        			gi.drawShape(filledShape);
		        		}
		        	}
		        }
			}
		}
  
    	// Hitta komponenter. 
    	// För varje komponent:  
    	// applicera dess placement, och rita ut den.
    	for (Component comp : icon.getSubcomponents()) {
    		Icon compIcon = comp.getIcon();
    		gi.saveTransformation();
    		//AffineTransform oldTransform = g.getTransform();
    		if (!compIcon.getLayer().equals(Layer.NO_LAYER)) {
    			gi.setTransformation(comp, this.icon.getLayer().getCoordinateSystem().getExtent());
    		}
			drawIcon(compIcon);
			gi.resetTransformation();
			//g.setTransform(oldTransform);
    	}
	}
	
	/** 
	 * Draws the specified ClassIcon, including superclasses and
	 * subcomponents (recursively), on this object's Graphics2D context.  
	 */
/*	private void drawComponent(Icon icon) {
		AffineTransform oldTransform = g.getTransform();
		ArrayList<GraphicItem> items = new ArrayList<GraphicItem>();
       	
		if(!icon.getLayer(layer).equals(Layer.NO_LAYER)) {
			//System.out.println("komponent har layer " + icon.getClassName());
			if (layer == IconConstants.ICON_LAYER) {
	       		if(icon instanceof SubIcon) {
	       			SubIcon subicon = (SubIcon)icon;
	       			if(!subicon.isProt() && subicon.isConnector()) {	
	       				items = icon.getLayer(layer).getGraphics();
	       			}
	       		}
	       		else {
	       			items.addAll(icon.getLayer(layer).getGraphics());
	       		}
	     
	    	} else {
	        	items = icon.getDiagramLayer().getGraphics();
	    	}
	       	if(icon instanceof SubIcon)	
	    	{
	       		SubIcon subicon = (SubIcon) icon;
				setIconTransformation(subicon, layer);
	    	}
	        for (GraphicItem item : items) {
	        	if (item instanceof MSLLine) {
	        		drawLine((MSLLine)item);
	        	} else {
	        		FilledShape filledShape = (FilledShape)item;
	        		if (filledShape.getShape() == null) {
	        			try {
	        				filledShape.createShape();
	        			} catch (CreateShapeFailedException e) {
	        				System.out.println(e.getMessage());
	        			}
	        		}
	        		if (item instanceof MSLText) {
	        			drawText((MSLText)filledShape, icon);
	        		} else {
	        			drawShape(filledShape);
	        		}
	        	}
	        }
		}
	
    	for (Icon superComp : icon.getSupercomponents()) {
    		drawComponent(superComp);
    	}
    
    	for (Component comp : icon.getSubcomponents()) {
    		drawComponent(comp.getIcon());
    	}
        
    	g.setTransform(oldTransform);
	}*/
	
//	/**
//	 * Draws the specified MSLText primitive in this object's Graphics2D
//	 * context.
//	 * @param t
//	 */
//	private void drawText(Text t, Icon icon) {
//		
//		boolean debugText = false;
//		
//		// Ritar outline-ikon -> ingen text.
//		if (outline) {
//			return;
//		}
//		
//		Extent extent = GraphicsUtil.fixExtent(t.getExtent());
//		int x = (int)(extent.getP1().getX());
//		int y = -(int)(extent.getP2().getY());		
//		int extentHeight = (int)t.getExtent().getHeight();
//		int extentWidth = (int)t.getExtent().getWidth();
//		
//		// Borde egentligen alltid RITA ut rutan såvida inte linePattern är NONE.
//		// Men det görs aldrig i Dymola. (pga blir fult?) Vi ritar bara om vi ska fylla.
//		if (t.getFillPattern() != FillPattern.NONE) {
//			drawShape(t);
//		}
//		
//		g.setFont(GraphicsUtil.setFont(t));
//		String text = t.getTextString();	
//			
//		// if fontsize is not set the text is scaled to fit its extent
//		FontMetrics metrics;
//		if(t.getFontSize() == 0)
//		{
//			// scale text to fit extext horizontally.
//			int fontsize = g.getFont().getSize();
//			int newSize = fontsize-(fontsize-extentHeight);
//			g.setFont(g.getFont().deriveFont((float)newSize));
//			//System.out.println(t.getTextString() + " Fontsize = " + g.getFont().getSize());
//			
//			// scale text to fit extent vertically.
//			Font font = g.getFont();
//			//FontMetrics metrics = g.getFontMetrics();
//			metrics = g.getFontMetrics(); 
//			while (metrics.stringWidth(text) > extentWidth) {
//				newSize = g.getFont().getSize()-1;
//				font = g.getFont().deriveFont((float)newSize);
//				g.setFont(font);
//				metrics = g.getFontMetrics();		
//			}
//		}
//		// place text in center 
//		metrics = g.getFontMetrics();
//		y += (int)((extentHeight+g.getFont().getSize())/2.0);
//		if (t.getHorizontalAlignment() == TextAlignment.CENTER) {
//			x += (int)((extentWidth-metrics.stringWidth(text))/2.0);
//		} else if (t.getHorizontalAlignment() == TextAlignment.RIGHT) {
//			x += extentWidth-metrics.stringWidth(text);
//		}
//		
//		g.setColor(t.getLineColor());
//		
//		// Texten ska varken roteras eller spegelvändas.
//		double rotation = 0.0;
//		double scaleX = 1.0;
//		double scaleY = 1.0;
//		// TODO fixa så att placement finns tillgänglig här
///*		if (icon instanceof SubIcon) {
//			Placement placement = ((SubIcon)icon).getPlacement(); 
//			rotation = 
//				placement.getTransformation(layer).getRotation();
//			Extent e = placement.getTransformation(layer).getExtent();
//			if(e.getP2().getX() < e.getP1().getX()) {
//				scaleX = -1.0;
//			} 
//			if(e.getP2().getY() < e.getP1().getY()) {
//				scaleY = -1.0;
//			}
//		}
//*/
//		g.rotate(rotation*(Math.PI/180.0));
//		g.scale(scaleX, scaleY);
//		
//		if (debugText) {
//			g.drawRect(
//					x, 
//					y-(int)extent.getHeight(), 
//					(int)extent.getWidth(), 
//					(int)extent.getHeight()
//			);
//		}
//		g.drawString(t.getTextString(), x, y);
//		
//		g.rotate(-rotation);
//	}
//		
//	/**
//	 * Draws the specified MSLLine primitive in this object's Graphics2D
//	 * context.
//	 * @param t
//	 */
//	private void drawLine(Line l) {
//		ArrayList<Point> points = l.getPoints();
//		if(points.size() > 2 && l.getSmooth().toString() == "BEZIER")
//		{
//			this.drawBezier(l);
//		}
//		else
//		{	
//			g.setColor(l.getColor());
//			double thickness = l.getThickness();
//			if (outline) {
//				thickness = 0.0;
//			}
//			//Stroke newStroke = GraphicsUtil.getLineStroke(l.getLinePattern(), thickness);
//			Stroke newStroke = GraphicsUtil.getLineStroke(l.getLinePattern(), thickness);
//
//			if (newStroke != null) {
//				g.setStroke(newStroke);
//				g.drawPolyline(GraphicsUtil.getXLinePoints(points),
//						GraphicsUtil.getYLinePoints(points), points.size());
//			}
//			
//			Polygon[] arrows = l.getArrowPolygons();
//			if(arrows != null)
//			{
//				for (int i = 0; i < arrows.length; i++) {
//					if (arrows[i] != null) {
//						drawShape(arrows[i]);
//					}
//				}
//			}
//		}
//	}
//
//	/**
//	 * Draws the specified shape in this object's Graphics2D context.
//	 * @param t
//	 */
//	private void drawShape(FilledShape s) {
//		if (s.getFillPattern() != FillPattern.NONE) {
//
//			Paint oldPaint = g.getPaint();
//			Paint newPaint = getFillPaint(s); 
//			if (newPaint != null) {
//				g.setPaint(newPaint);
//			} else {
//				g.setColor(s.getFillColor());
//			}
//			
//			g.fill(s.getShape());
//			g.setPaint(oldPaint);
//		} 
//		boolean gradient = (s.getFillPattern() == FillPattern.HORIZONTALCYLINDER ||
//							s.getFillPattern() == FillPattern.VERTICALCYLINDER ||
//							s.getFillPattern() == FillPattern.SPHERE);
//		if (s.getLinePattern() != LinePattern.NONE && !gradient) {
//			double thickness = s.getLineThickness();
//			if (outline) {
//				thickness = 0.0;
//			}
//			Stroke newStroke = GraphicsUtil.getLineStroke(s.getLinePattern(), thickness); 
//			g.setStroke(newStroke);
//			g.setColor(s.getLineColor());
//			g.draw(s.getShape());
//		}
//		
//		//TODO testa stroke till borderPattern
//		// + skapa en ny rektangel utanför orginalrektangeln
//		if(s instanceof Rectangle)
//		{
//			Rectangle r = (Rectangle) s;
//			Types.BorderPattern borderPattern = r.getBorderPattern(); 
//			if(borderPattern != Types.BorderPattern.NONE)
//			{
//				ArrayList<Point> points = null; 
//				try
//				{
//					points = GraphicsUtil.getBorderPatternPoints(r, borderPattern);
//				}catch(FailedConstructionException e)
//				{
//					System.out.println("BorderPattern " + borderPattern + " is not implemented yet" );
//					return;
//				}
//				//g.setColor(r.getLineColor());
//				g.setColor(Color.BLACK);
//				//returnerar default linestroke
//				Stroke newStroke = GraphicsUtil.getLineStroke(Types.LinePattern.SOLID, IconConstants.BORDER_PATTERN_THICKNESS); 
//				g.setStroke(newStroke);
//				g.drawPolyline(GraphicsUtil.getXLinePoints(points),
//							GraphicsUtil.getYLinePoints(points), points.size());
//				
//			}
//		}
//	}
//	
//	/**
//	 * Draws the specified MLSLine primitive in this object's Graphics2D
//	 * context, treating the line's points as points in a Bezier function.
//	 * @param t
//	 */
//	
//	private void drawBezier(Line l) 
//	{	
//		ArrayList<Point> linePoints = l.getPoints();
//		for(Point lp : linePoints)
//		{
//			/* invert y to compensate java */
//			lp.setY(-(lp.getY()));
//		}
//		ArrayList<Point> bezierPoints = new ArrayList<Point>();
//		for(int i = 0; i < linePoints.size()-1; i++)
//		{
//			double x = (linePoints.get(i).getX() + linePoints.get(i+1).getX()) / 2;
//			double y = (linePoints.get(i).getY() + linePoints.get(i+1).getY()) / 2;
//			bezierPoints.add(new Point(x, y));
//		}
//		GeneralPath gp = new GeneralPath();
//		gp.moveTo(linePoints.get(0).getX(), linePoints.get(0).getY());
//		gp.lineTo(bezierPoints.get(0).getX(), bezierPoints.get(0).getY());
//		for(int i = 1; i < bezierPoints.size(); i++)
//		{
//			gp.quadTo(linePoints.get(i).getX(), linePoints.get(i).getY(), 
//					bezierPoints.get(i).getX(), bezierPoints.get(i).getY());
//		}
//		gp.lineTo(linePoints.get(linePoints.size()-1).getX(), 
//				linePoints.get(linePoints.size()-1).getY());
//		
//		g.setColor(l.getColor());
//		Stroke newStroke = GraphicsUtil.getLineStroke(l.getLinePattern(), l.getThickness()); 
//		if (newStroke != null) {
//			g.setStroke(newStroke);
//		}
//		g.draw(gp);
//	}
//	/**
//	 * Applies the transformation of the specified component's icon layer 
//	 * specification.
//	 * @param component
//	 */
//	private void setIconTransformation(Component comp, int layer)
//	{	
//		Placement placement = comp.getPlacement();
//		Icon icon = comp.getIcon();
//		AffineTransform transform = g.getTransform();
//		
//		Extent iconTransExtent = placement.getTransformation(layer).getExtent();
//		Extent iconCordExtent = icon.getLayer().getCoordinateSystem().getExtent();
//		
//		//System.out.println("Sätter transformation för " + icon.getClassName());
//		//System.out.println("iconTransExtent = " + iconTransExtent);
//		//System.out.println("iconCordExtent = " + iconCordExtent);
//		
//		double iconTransExtHeight = iconTransExtent.getHeight();
//		double iconTransExtWidth = iconTransExtent.getWidth();
//			
//		double iconCordExtHeight = iconCordExtent.getHeight();	
//		double iconCordExtWidth = iconCordExtent.getWidth();
//	
//		//System.out.println("Skalar bredd med faktor = " + iconTransExtWidth/iconCordExtWidth);
//		//System.out.println("Skalar höjd med faktor = " + iconTransExtHeight/iconCordExtHeight);
//		
//		double originX = placement.getTransformation(layer).getOrigin().getX() + iconTransExtent.getMiddle().getX(); 
//		double originY = placement.getTransformation(layer).getOrigin().getY() + iconTransExtent.getMiddle().getY();	
//		
//		// invert y to compensate java 
//		transform.translate(originX, -originY);
//		// transform flipping
//		if(iconTransExtent.getP2().getX() < iconTransExtent.getP1().getX())
//		{
//			//flip horizontally
//			transform.scale(-1.0, 1.0);
//			
//		}
//		if(iconTransExtent.getP2().getY() < iconTransExtent.getP1().getY())
//		{
//			//flip vertically
//			transform.scale(1.0, -1.0);
//		}
//		
//		transform.scale(iconTransExtWidth/iconCordExtWidth, iconTransExtHeight/iconCordExtHeight);
//		// invert rotation to compensate java 
//		transform.rotate(-placement.getTransformation(layer).getRotation() * Math.PI/180);
//		g.setTransform(transform);
//	}
//	
//	/**
//	 * Creates a Paint object that matches the shape's colors and fill pattern.
//	 * 
//	 * @param shape
//	 * @return
//	 */
//	private Paint getFillPaint(FilledShape shape) {
//		if (shape.getFillPattern() == FillPattern.HORIZONTAL
//				|| shape.getFillPattern() == FillPattern.VERTICAL
//				|| shape.getFillPattern() == FillPattern.FORWARD
//				|| shape.getFillPattern() == FillPattern.BACKWARD
//				|| shape.getFillPattern() == FillPattern.CROSS
//				|| shape.getFillPattern() == FillPattern.CROSSDIAG) {
//			return getTextureFillPaint(shape);
//		}
//		if (shape.getFillPattern() == FillPattern.SOLID) {
//			return null;
//		}
//		
//		Paint paint = null;
//
//		Extent extent = null;
//		double width;
//		double height;
//		if (shape instanceof FilledRectShape) {
//			extent = ((FilledRectShape) shape).getExtent();
//		} else if (shape instanceof Polygon) {
//			extent = ((Polygon) shape).getBounds();
//		}
//		extent = GraphicsUtil.fixExtent(extent);
//		width = extent.getP2().getX() - extent.getP1().getX();
//		height = extent.getP2().getY() - extent.getP1().getY();
//		if (shape.getFillPattern() == FillPattern.VERTICALCYLINDER
//				|| shape.getFillPattern() == FillPattern.HORIZONTALCYLINDER) {
//			Point2D p1 = null;
//			Point2D p2 = null;
//			p1 = new Point2D.Double(extent.getP1().getX(), extent.getP1()
//					.getY());
//			p2 = new Point2D.Double(extent.getP2().getX(), extent.getP2()
//					.getY());
//			if (shape.getFillPattern() == FillPattern.VERTICALCYLINDER) {
//				p1.setLocation(p1.getX(), p1.getY() + 0.5 * height);
//				p2.setLocation(p2.getX() - 0.5 * width, p2.getY() - 0.5
//						* height);
//			} else if (shape.getFillPattern() == FillPattern.HORIZONTALCYLINDER) {
//				p1.setLocation(p1.getX() + 0.5 * width, p1.getY());
//				p2.setLocation(p2.getX() - 0.5 * width, p2.getY() - 0.5
//						* height);
//			}
//			// Flip the y-axis of the points.
//			p1.setLocation(p1.getX(), -p1.getY());
//			p2.setLocation(p2.getX(), -p2.getY());
//			return new GradientPaint(p1, shape.getLineColor(), p2,
//					shape.getFillColor(), true);
//		} else if (shape.getFillPattern() == FillPattern.SPHERE) {
//			float[] fractions = { 0.0f, 1.0f };
//			Color[] colors = { shape.getFillColor(), shape.getLineColor() };
//			/*
//			 * return new RadialGradientPaint(
//			 * (float)(extent.p1.getX()+0.5*width),
//			 * -(float)(extent.p1.getY()+0.5*height),
//			 * (float)Math.sqrt((width/2)*(width/2)+(height/2)*(height/2)),
//			 * fractions, colors );
//			 */
//			return new RadialGradientPaint(new Rectangle2D.Double(extent
//					.getP1().getX(), extent.getP1().getY(), width, height),
//					fractions, colors, CycleMethod.NO_CYCLE);
//		}
//		return paint;
//	}
//	
//	/**
//	 * Creates a TexturePaint object that matches the shape's colors and fill
//	 * pattern.
//	 * 
//	 * @param s
//	 * @return
//	 */
//	private Paint getTextureFillPaint(FilledShape s) {
//        
//        Extent shapeExtent = null;
//        if (s instanceof FilledRectShape) {
//        	shapeExtent = ((FilledRectShape) s).getExtent();
//        } else if (s instanceof Polygon){
//        	shapeExtent = ((Polygon) s).getBounds();
//        }
//        //int textureWidth = (int)(shapeExtent.getWidth()*scaleWidth);
//        //int textureHeight = (int)(shapeExtent.getWidth()*scaleWidth);
//        //int textureSize = Math.min(textureWidth, textureHeight);
//        int textureSize = 20;
//		BufferedImage image = new BufferedImage(
//				textureSize, textureSize, BufferedImage.TYPE_INT_RGB
//		);
//
//		Graphics2D g = image.createGraphics();
//		
//		g.setColor(s.getFillColor());
//		g.fillRect(0, 0, textureSize, textureSize);
//		
//		g.setColor(s.getLineColor());
//		
//		if (s.getFillPattern().equals(FillPattern.FORWARD)) {
//			g.drawLine(0, 0, textureSize, textureSize);
//			
//		} else if (s.getFillPattern().equals(FillPattern.BACKWARD)) {
//			g.drawLine(textureSize, 0, 0, textureSize); // <-------- ?????
//			
//		} else if (s.getFillPattern().equals(FillPattern.CROSSDIAG)) {
//			g.drawLine(0, 0, textureSize, textureSize);
//			g.drawLine(textureSize, 0, 0, textureSize);
//		
//		} else if (s.getFillPattern().equals(FillPattern.HORIZONTAL)) {
//			g.drawLine(0, textureSize/2, textureSize, textureSize/2);
//		
//		} else if (s.getFillPattern().equals(FillPattern.VERTICAL)) {
//			g.drawLine(textureSize/2, 0, textureSize/2, textureSize);
//		
//		} else if (s.getFillPattern().equals(FillPattern.CROSS)) {
//			g.drawLine(0, textureSize/2, textureSize, textureSize/2);
//			g.drawLine(textureSize/2, 0, textureSize/2, textureSize);
//		}
//		
//		return new TexturePaint(
//				image, 
//				new java.awt.Rectangle(
//						//(int)(shapeExtent.getP1().getX()), 
//						//(int)(shapeExtent.getP1().getY()),
//						0, 
//						0,
//						textureSize, 
//						textureSize
//				)
//		);
//	}
}
