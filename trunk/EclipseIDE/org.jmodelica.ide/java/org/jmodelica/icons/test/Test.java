package org.jmodelica.icons.test;

//import java.awt.AlphaComposite;
//import java.awt.BasicStroke;
//import java.awt.Color;
//import java.awt.GradientPaint;
//import java.awt.Graphics2D;
//import java.awt.Rectangle;
//import java.awt.TexturePaint;
//import java.awt.geom.Rectangle2D;
//import java.awt.image.BufferedImage;
//import java.io.File;
//import java.io.IOException;
//import java.util.ArrayList;
//
//import javax.imageio.ImageIO;
//
//import org.jmodelica.icons.IconConstants;
//import org.jmodelica.icons.IconImage2;
//import org.jmodelica.icons.IconLoader;
//import org.jmodelica.icons.SWTImage;
//import org.jmodelica.icons.enums.IconContext;
//import org.jmodelica.icons.exceptions.FailedConstructionException;
//import org.jmodelica.icons.msl.ClassIcon;
//import org.jmodelica.icons.msl.Types;
//import org.jmodelica.icons.msl.Types.FillPattern;
//import org.jmodelica.icons.msl.primitives.Extent;
//import org.jmodelica.icons.msl.primitives.Ellipse;
//import org.jmodelica.icons.msl.primitives.Line;
//import org.jmodelica.icons.msl.primitives.Point;
//import org.jmodelica.icons.msl.primitives.Polygon;
//import org.jmodelica.icons.msl.primitives.Rectangle;
//import org.jmodelica.icons.msl.primitives.Text;
//
//import org.eclipse.swt.SWT;
//import org.eclipse.swt.events.PaintEvent;
//import org.eclipse.swt.events.PaintListener;
//import org.eclipse.swt.graphics.GC;
//import org.eclipse.swt.graphics.Image;
//import org.eclipse.swt.layout.FillLayout;
//import org.eclipse.swt.widgets.Canvas;
//import org.eclipse.swt.widgets.Display;
//import org.eclipse.swt.widgets.Shell;
//
//public class Test {
//	public static void main(String[] args) {
//		
//		final Display display = new Display();
//		final Shell shell = new Shell(display);
//		shell.setLayout(new FillLayout());
//				
//		Canvas canvas = new Canvas(shell, SWT.NONE);
//		
//		// Specify how the canvas should be painted.
//		canvas.addPaintListener(new PaintListener() {
//			public void paintControl(PaintEvent e) {
//				ClassIcon icon = TestComponent.createTestComponent();
//				/*
//				MSLRectangle[] rect = new MSLRectangle[6];
//				for (int i = 0; i < 6; i++) {
//					rect[i] = new MSLRectangle();
//					rect[i].setExtent(new Extent(
//							new MSLPoint(-300+i*60, -60), new MSLPoint(-250+i*60, 0)
//					));
//					rect[i].setLineColor(Color.RED);
//					rect[i].setFillColor(Color.YELLOW);
//					icon.getIconLayer().getGraphics().add(rect[i]);
//				}
//				rect[0].setFillPattern(Types.FillPattern.FORWARD);
//				rect[1].setFillPattern(Types.FillPattern.BACKWARD);
//				rect[2].setFillPattern(Types.FillPattern.CROSSDIAG);
//				rect[3].setFillPattern(Types.FillPattern.VERTICAL);
//				rect[4].setFillPattern(Types.FillPattern.HORIZONTAL);
//				rect[5].setFillPattern(Types.FillPattern.CROSS);
//				*/
//				Text t1 = new Text(
//						new Extent(
//							new Point(-90, -100),
//							new Point(100, 70)
//						),
//						"TEXT"
//					);
//				t1.setFillPattern(FillPattern.SOLID);
//				t1.setFillColor(Color.YELLOW);
//				//t1.setLineColor(Color.YELLOW);
//				//t1.setFontSize(50);
//				ArrayList<Types.TextStyle> textstyle = new ArrayList<Types.TextStyle>();
//				textstyle.add(Types.TextStyle.ITALIC);
//				t1.setTextStyle(textstyle);
//				icon.getIconLayer().getGraphics().add(t1);
//				IconImage2 iconImage = new IconImage2(icon, IconConstants.ICON_LAYER, false);
//				//IconImage2 iconImage = new IconImage2(icon, IconContext.ICON, false);
//				//IconImage iconImage = new IconImage(icon, true, false);
//				BufferedImage buff = iconImage.getBufferedImage();
//				Image image = null;
//				try {
//					image = SWTImage.getSWTImage(buff);
//				} catch (FailedConstructionException e1) {
//					
//				}
//				e.gc.drawImage(image, 0, 0);
//				
//				
//				/////////////////
//				
///*				BufferedImage img = new BufferedImage(200, 200, BufferedImage.TYPE_INT_RGB);
//				
//			    //Graphics2D g2D = (Graphics2D) g;
//				Graphics2D g2D = (Graphics2D)img.createGraphics();
//			    Rectangle2D rec1, rec2, rec3, rec4, rec5;
//			    rec1 = new Rectangle2D.Float(25, 25, 75, 150);
//			    rec2 = new Rectangle2D.Float(125, 25, 10, 75);
//			    rec3 = new Rectangle2D.Float(75, 125, 125, 75);
//			    rec4 = new Rectangle2D.Float(25, 15, 12, 75);
//			    rec5 = new Rectangle2D.Float(15, 50, 15, 15);
//
//			    AlphaComposite ac = AlphaComposite.getInstance(AlphaComposite.SRC_OVER,
//			        1);
//			    g2D.setComposite(ac);
//
//			    g2D.setStroke(new BasicStroke(5.0f));
//			    g2D.draw(rec1);
//			    GradientPaint gp = new GradientPaint(125f, 25f, Color.yellow, 225f, 100f,
//			        Color.blue);
//			    g2D.setPaint(gp);
//			    g2D.fill(rec2);
//			    BufferedImage bi = new BufferedImage(5, 5, BufferedImage.TYPE_INT_RGB);
//			    Graphics2D big = bi.createGraphics();
//			    big.setColor(Color.magenta);
//			    big.fillRect(0, 0, 5, 5);
//			    big.setColor(Color.black);
//			    big.drawLine(0, 0, 5, 5);
//			    Rectangle r = new Rectangle(0, 0, 5, 5);
//			    TexturePaint tp = new TexturePaint(bi, r);
//
//			    g2D.setPaint(tp);
//			    g2D.fill(rec3);
//			    g2D.setColor(Color.green);
//			    g2D.fill(rec4);
//			    g2D.setColor(Color.red);
//			    g2D.fill(rec5);
//				
//			    Image image2 = null;
//				try {
//					image2 = SWTImage.getSWTImage(img);
//				} catch (FailedConstructionException e1) {
//					System.out.println("fel med skapande av swtimage");
//				}
//				e.gc.drawImage(image2, 0, 0);
//*/
//				/////////////////
//				
//			}
//		});
//		
//		shell.open();
//		while (!shell.isDisposed()) {
//			if (!display.readAndDispatch()) {
//				display.sleep();
//			}
//		}
//		display.dispose();
//	}
//}
