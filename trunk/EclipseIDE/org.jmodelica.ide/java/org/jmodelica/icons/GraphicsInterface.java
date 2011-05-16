package org.jmodelica.icons;

import org.jmodelica.icons.mls.Component;
import org.jmodelica.icons.mls.Icon;
import org.jmodelica.icons.mls.primitives.Bitmap;
import org.jmodelica.icons.mls.primitives.Color;
import org.jmodelica.icons.mls.primitives.FilledShape;
import org.jmodelica.icons.mls.primitives.Line;
import org.jmodelica.icons.mls.primitives.Text;
import org.jmodelica.icons.mls.primitives.Extent;

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