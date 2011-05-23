package org.jmodelica.icons;

import org.jmodelica.icons.mls.Bitmap;
import org.jmodelica.icons.mls.Color;
import org.jmodelica.icons.mls.Component;
import org.jmodelica.icons.mls.Extent;
import org.jmodelica.icons.mls.FilledShape;
import org.jmodelica.icons.mls.Icon;
import org.jmodelica.icons.mls.Line;
import org.jmodelica.icons.mls.Text;

public interface GraphicsInterface {
	public abstract void drawLine(Line l);
	public abstract void drawText(Text t, Icon icon);
	public abstract void drawShape(FilledShape s);
	public abstract void drawBitmap(Bitmap b);
	public abstract void setTransformation(Component comp, Extent extent);
	public abstract void saveTransformation();
	public abstract void resetTransformation();
	public abstract void setColor(Color color);
	public abstract void setBackgroundColor(Color color);
}