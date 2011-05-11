package org.jmodelica.icons;

import java.awt.image.BufferedImage;
import java.awt.image.DirectColorModel;
import java.awt.image.WritableRaster;

import org.eclipse.jface.resource.ImageDescriptor;
import org.eclipse.swt.graphics.Image;
import org.eclipse.swt.graphics.ImageData;
import org.eclipse.swt.graphics.PaletteData;
import org.eclipse.swt.graphics.RGB;
import org.jmodelica.icons.exceptions.FailedConstructionException;


public class SWTImage {
	
	  
	public static Image getSWTImage(BufferedImage buffimage) throws FailedConstructionException
	{
	    ImageData imagedata = null;
		if(buffimage == null)
		{
			throw new FailedConstructionException("SWTImage");
		}
	    if (buffimage.getColorModel() instanceof DirectColorModel) {
	        DirectColorModel colorModel
	                = (DirectColorModel) buffimage.getColorModel();
	        PaletteData palette = new PaletteData(colorModel.getRedMask(),
	                colorModel.getGreenMask(), colorModel.getBlueMask());
	        imagedata = new ImageData(buffimage.getWidth(),
	        		buffimage.getHeight(), colorModel.getPixelSize(),
	                palette);
	        WritableRaster raster = buffimage.getRaster();
	        int[] pixelArray = new int[3];
	        for (int y = 0; y < imagedata.height; y++) {
	            for (int x = 0; x < imagedata.width; x++) {
	                raster.getPixel(x, y, pixelArray);
	                int pixel = palette.getPixel(new RGB(pixelArray[0],
	                        pixelArray[1], pixelArray[2]));
	                imagedata.setPixel(x, y, pixel);
	            }
	        }
	    }
	    else
	    {	
	    	throw new FailedConstructionException("SWTImage");
	    	
	    }
		ImageDescriptor desc = ImageDescriptor.createFromImageData(imagedata);
		return desc.createImage(); 
	}
 
	 
}
