package org.jmodelica.ide.outline;

import java.awt.image.BufferedImage;
import java.awt.image.DirectColorModel;

import org.eclipse.jface.resource.ImageDescriptor;
import org.eclipse.swt.graphics.Image;
import org.eclipse.swt.graphics.ImageData;
import org.eclipse.swt.graphics.PaletteData;
import org.eclipse.swt.graphics.RGB;
import org.jmodelica.icons.drawing.IconConstants;

public class SWTIconDrawer {
	
	public static Image convertImage(BufferedImage image) {
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
	   
	        
	        int x = 0, y = 0;
	        for (y = 0; y < imagedata.height; y++) 
	        	imagedata.setAlpha(x, y, 0);
	        
	        y = imagedata.height-1;
        	for (x = 0; x < imagedata.width; x++) 
        		imagedata.setAlpha(x, y, 0);
        	
	        for (y = 0; y < image.getHeight(); y++) {
	            for (x = 0; x < image.getWidth(); x++) {
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

}
