package org.jmodelica.icons.test;
/*
import java.awt.Color;
import java.awt.image.BufferedImage;
import java.io.IOException;
import java.net.URL;
import java.util.ArrayList;

import javax.xml.parsers.ParserConfigurationException;
import javax.xml.xpath.XPathExpressionException;

import org.eclipse.core.runtime.FileLocator;
import org.eclipse.swt.SWT;
import org.eclipse.swt.events.PaintEvent;
import org.eclipse.swt.events.PaintListener;
import org.eclipse.swt.graphics.Image;
import org.eclipse.swt.layout.FillLayout;
import org.eclipse.swt.widgets.Canvas;
import org.eclipse.swt.widgets.Display;
import org.eclipse.swt.widgets.Shell;
import org.jmodelica.icons.IconConstants;
import org.jmodelica.icons.IconLoader;
import org.jmodelica.icons.SWTImage;
import org.jmodelica.icons.exceptions.FailedConstructionException;
import org.jmodelica.icons.msl.Types;
import org.jmodelica.icons.msl.Types.FillPattern;
import org.jmodelica.icons.msl.primitives.Extent;
import org.jmodelica.icons.msl.primitives.Point;
import org.jmodelica.icons.msl.primitives.Text;
import org.jmodelica.ide.Activator;
import org.jmodelica.modelica.compiler.ClassDecl;
import org.jmodelica.modelica.compiler.InstClassDecl;
import org.jmodelica.util.OptionRegistry;
import org.xml.sax.SAXException;

public class CompileAllModelsTest {
	
	
	
	public static void main(String[] args) {
		
		
		
		
		final Display display = new Display();
		final Shell shell = new Shell(display);
		shell.setLayout(new FillLayout());
		
		Canvas canvas = new Canvas(shell, SWT.NONE);
		
		// Specify how the canvas should be painted.
		canvas.addPaintListener(new PaintListener() {
			public void paintControl(PaintEvent e) {
				//ClassIcon icon = TestComponent.createTestComponent();
				IconCompiler compiler = IconLoader.createCompiler(); 
				String fileName = "../JModelica/ThirdParty/MSL/Modelica/Electrical/Analog/Basic.mo";
				String className	= "Modelica.Electrical.Analog.Basic.HeatingResistor";
			
				InstClassDecl inst = compiler.compileNoErrorCheck(fileName, className);
				ClassIcon icon = IconLoader.getIcon(inst);
				IconImage2 im = new IconImage2(
						icon, 
						IconConstants.DIAGRAM_LAYER, 
						false,
						600, 
						600
				);
				Image image = null;
				BufferedImage buff = null;
				buff = im.getBufferedImage(); 
				try {
					 image = SWTImage.getSWTImage(buff);
				} catch (FailedConstructionException exception) {}
			
				e.gc.drawImage(image, 0, 0);
				
		
			}
		});
		
		shell.open();
		while (!shell.isDisposed()) {
			if (!display.readAndDispatch()) {
				display.sleep();
			}
		}
		display.dispose();
	}
		
}







*/





