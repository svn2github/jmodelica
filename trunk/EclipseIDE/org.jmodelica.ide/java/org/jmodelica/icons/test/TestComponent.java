package org.jmodelica.icons.test;
//
//import java.awt.Color;
//import java.util.ArrayList;
//
//import org.jmodelica.icons.msl.ClassIcon;
//import org.jmodelica.icons.msl.CoordinateSystem;
//import org.jmodelica.icons.msl.Layer;
//import org.jmodelica.icons.msl.Placement;
//import org.jmodelica.icons.msl.Transformation;
//import org.jmodelica.icons.msl.Types;
//import org.jmodelica.icons.msl.Types.Arrow;
//import org.jmodelica.icons.msl.Types.FillPattern;
//import org.jmodelica.icons.msl.Types.LinePattern;
//import org.jmodelica.icons.msl.primitives.Extent;
//import org.jmodelica.icons.msl.primitives.GraphicItem;
//import org.jmodelica.icons.msl.primitives.Ellipse;
//import org.jmodelica.icons.msl.primitives.Line;
//import org.jmodelica.icons.msl.primitives.Point;
//import org.jmodelica.icons.msl.primitives.Polygon;
//import org.jmodelica.icons.msl.primitives.Rectangle;
//import org.jmodelica.icons.msl.primitives.Text;
//
//
//	
//public abstract class TestComponent {
//	
//	/**
//	 * Creates and returns a Component with default parameters (for testing).
//	 * @return
//	 */
//	public static ClassIcon createTestComponent() {
//		return new ClassIcon(
//        	"Test component",
//        	createTestIconLayer(),
//        	createTestDiagramLayer()
//        );
//	}
//	
//    /**
//     * Sets up the component's diagram layer.
//     * @return
//     */
//    private static Layer createTestDiagramLayer() {
//    	CoordinateSystem coordinateSystem = new CoordinateSystem(
//    		new Extent(
//    			new Point(-100, -100),
//    			new Point(100, 100)
//    		)	
//    	);
//    	
//    	// No graphical components in the diagram layer yet.
//    	ArrayList<GraphicItem> graphics = new ArrayList<GraphicItem>();
//    	
//    	return new Layer(
//			coordinateSystem, 
//			graphics
//		);
//    }
//    
//    /**
//     * Sets up the component's icon layer.
//     * @return
//     */
//    private static Layer createTestIconLayer() {
//    	CoordinateSystem coordinateSystem = new CoordinateSystem(
//    		new Extent(
//    			new Point(-100, -100),
//    			new Point(100, 100)
//    		)	
//    	);
//    	ArrayList<GraphicItem> graphics = createTestIconGraphics();
//    	return new Layer(
//			coordinateSystem, 
//			graphics
//		);
//    }
//    
//    private static ArrayList<GraphicItem> createTestIconGraphics() {
//    	ArrayList<GraphicItem> graphics = new ArrayList<GraphicItem>();
//    	
//    	/*MLSRectangle r = new MLSRectangle(
//			new Extent(
//				new MLSPoint(-60, -20),
//				new MLSPoint(95, 75)
//			)
//		);
//    	r.setFillColor(Color.RED);
//    	r.setLineColor(Color.BLUE);
//    	r.setFillPattern(FillPattern.CROSSDIAG);
//    	graphics.add(r);*/
//    	
// /*   	double arrowSize = 10;
//    	double x1 = -70;
//    	double y1 = -120;
//    	double x2 = -10;
//    	double y2 = 160;
//    	double x3 = -100;
//    	double y3 = 60;
//    	MSLPoint p1 = new MSLPoint(x1, y1);
//    	MSLPoint p2 = new MSLPoint(x2, y2);
//    	MSLPoint p3 = new MSLPoint(x3, y3);
//
//    	ArrayList<MSLPoint> linepoints = new ArrayList<MSLPoint>();
//  
//    	linepoints.add(p1);
//    	linepoints.add(p2);
//    	linepoints.add(p3);
//    	
//    	MSLLine line = new MSLLine(linepoints);
//    	Arrow[] arrow = new Arrow[2];
//    	arrow[0] = Arrow.FILLED;
//    	arrow[1] = Arrow.FILLED;
//    	line.setArrow(arrow);
//    	//graphics.add(line);
//   */ 	
//    	
///*    	MLSPoint p1 = new MLSPoint(x1, y1);
//    	MLSPoint p2 = new MLSPoint(x2, y2);
//    	ArrayList<MLSPoint> points1 = new ArrayList<MLSPoint>();
//    	points1.add(p1);
//    	points1.add(p2);
//    	MLSLine l1 = new MLSLine(points1);
//    	graphics.add(l1);
//    	
//    	// hittar vinkelrät linje...
//    	// deklarerar linjen som en vektor
//    	double vector1x = x2-x1;
//    	double vector1y = y2-y1;
//    	
//    	// hittar vinkelrät vektor
//    	double vector2x = -vector1y;
//    	double vector2y = vector1x;
//    	
//    	// ritar ut vinkelrät vektor
//    	MLSPoint p3 = new MLSPoint(x1+vector2x, y1+vector2y);
//    	ArrayList<MLSPoint> points2 = new ArrayList<MLSPoint>();
//    	points2.add(p1);
//    	points2.add(p3);
//    	MLSLine l2 = new MLSLine(points2);
//    	l2.setColor(Color.RED);
//    	graphics.add(l2);
//    	
//    	MLSPoint p4 = new MLSPoint(x1-vector2x, y1-vector2y);
//    	ArrayList<MLSPoint> points3 = new ArrayList<MLSPoint>();
//    	points3.add(p1);
//    	points3.add(p4);
//    	MLSLine l3 = new MLSLine(points3);
//    	l3.setColor(Color.GREEN);
//    	graphics.add(l3);
//    	
//    	*/
//	/*	
//    	MLSEllipse ellipse = new MLSEllipse(
//			new Extent(
//				new MLSPoint(-50, -50),
//				new MLSPoint(50, 70)
//			),
//			-50, 
//			270
//    	);
//    	ellipse.setFillPattern(FillPattern.NONE);
//    	ellipse.setFillColor(new Color(255, 0, 255));
//    	ellipse.setLineColor(Color.ORANGE);
//    	ellipse.setLinePattern(LinePattern.DASHDOT);
//		graphics.add(ellipse);
//		
//		ArrayList<MLSPoint> points1 = new ArrayList<MLSPoint>();
//		points1.add(new MLSPoint(150, 150));
//		points1.add(new MLSPoint(200, 150));
//		points1.add(new MLSPoint(200, 200));
//		MLSLine line1 = new MLSLine(points1);
//		line1.setLinePattern(Types.LinePattern.SOLID);
//		line1.setThickness(1);
//		graphics.add(line1);
//
//		ArrayList<MLSPoint> points2 = new ArrayList<MLSPoint>();
//		points2.add(new MLSPoint(10, 210));
//		points2.add(new MLSPoint(50, 220));
//		points2.add(new MLSPoint(10, 230));
//		points2.add(new MLSPoint(50, 240));
//		points2.add(new MLSPoint(10, 250));
//		points2.add(new MLSPoint(50, 260));
//		points2.add(new MLSPoint(10, 270));
//		MLSLine line2 = new MLSLine(points2);
//		line2.setLinePattern(Types.LinePattern.DASHDOTDOT);
//		line2.setThickness(2);			
//		graphics.add(line2);
//		
//		ArrayList<MLSPoint> points3 = new ArrayList<MLSPoint>();
//		points3.add(new MLSPoint(10, 310));
//		points3.add(new MLSPoint(50, 320));
//		points3.add(new MLSPoint(10, 330));
//		points3.add(new MLSPoint(50, 340));
//		points3.add(new MLSPoint(10, 350));
//		points3.add(new MLSPoint(50, 360));
//		points3.add(new MLSPoint(10, 370));
//		MLSLine line3 = new MLSLine(points3);
//		line3.setLinePattern(Types.LinePattern.DOT);
//		line3.setThickness(10);
//		graphics.add(line3);
//		
//		ArrayList<MLSPoint> points4 = new ArrayList<MLSPoint>();
//		points4.add(new MLSPoint(110, 10));
//		points4.add(new MLSPoint(90, 20));
//		points4.add(new MLSPoint(110, 30));
//		points4.add(new MLSPoint(100, 40));
//		points4.add(new MLSPoint(140, 50));
//		points4.add(new MLSPoint(70, 60));
//		points4.add(new MLSPoint(110, 70));
//		MLSPolygon polygon1 = new MLSPolygon(points4);
//		polygon1.setFillPattern(FillPattern.FORWARD);
//		polygon1.setFillColor(Color.YELLOW);
//		graphics.add(polygon1);
//
//		ArrayList<MLSPoint> points5 = new ArrayList<MLSPoint>();
//		points5.add(new MLSPoint(200, 200));
//		points5.add(new MLSPoint(200, 210));
//		points5.add(new MLSPoint(220, 230));
//		points5.add(new MLSPoint(230, 220));
//		MLSPolygon polygon2 = new MLSPolygon(points5);
//		polygon2.setFillColor(Color.BLUE);
//		polygon2.setLineColor(new Color(255, 0, 255));
//		polygon2.setFillPattern(FillPattern.SOLID);
//		graphics.add(polygon2);
//		*/
//		
///*		MSLText t1 = new MSLText(
//			new Extent(
//				new MSLPoint(-90, -100),
//				new MSLPoint(150, 70)
//			),
//			"TEXT"
//		);
//		t1.setFillPattern(FillPattern.SOLID);
//		t1.setFillColor(Color.YELLOW);
//		//t1.setLineColor(Color.YELLOW);
//		graphics.add(t1);
//*/
//		/*
//		MLSText t2 = new MLSText(
//			new Extent(
//				new MLSPoint(-90, -10),
//				new MLSPoint(60, 70)
//			),
//			"TEXT2"
//		);
//		t2.setLineColor(Color.BLUE);
//		t2.setLinePattern(LinePattern.SOLID);
//		t2.setFillPattern(FillPattern.SOLID);
//		graphics.add(t2);
//	*/
//    	return graphics;
//    }
//}

