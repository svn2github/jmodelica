package org.jmodelica.ide.graphical.graphics;

import org.eclipse.draw2d.Figure;
import org.eclipse.draw2d.FigureListener;
import org.eclipse.draw2d.Graphics;
import org.eclipse.draw2d.IFigure;
import org.eclipse.draw2d.Layer;
import org.eclipse.draw2d.TreeSearch;
import org.eclipse.draw2d.geometry.Rectangle;
import org.eclipse.gef.handles.HandleBounds;

public class IconLayer extends Layer implements FigureListener, HandleBounds {
	private Rectangle realBounds = null;
	private Rectangle declaredBounds = new Rectangle();

	@Override
	public IFigure findFigureAt(int x, int y, TreeSearch search) {
		IFigure fig = super.findFigureAt(x, y, search);
		if (fig == null)
			return null;
		else if (fig instanceof IconLayer)//TODO: make sure this is a connector...
			return fig;
		else
			return this;
	}

	@Override
	public Rectangle getBounds() {
		if (realBounds == null) {
			realBounds = calculateBounds();
			fireFigureMoved();
		}
		return realBounds;
	}

	@Override
	public void setBounds(Rectangle rect) {
		// Should not be possible to set the bounds!
	}

	private Rectangle calculateBounds() {
		Rectangle bounds = null;
		for (Object o : getChildren()) {
			if (!(o instanceof Figure)) {
				continue;
			}
			Figure f = (Figure) o;
			if (!f.isVisible()) {
				continue;
			}
			Rectangle r;
			r = f.getBounds();
			if (bounds == null) {
				bounds = r;
			} else {
				bounds.union(r);
			}
		}
		if (bounds == null) {
			bounds = new Rectangle(0, 0, 0, 0);
		}
		return bounds;
	}

	@Override
	public void add(IFigure figure, Object constraint, int index) {
		super.add(figure, constraint, index);
		figure.addFigureListener(this);
		childChanged();
	}

	@Override
	public void remove(IFigure figure) {
		super.remove(figure);
		figure.removeFigureListener(this);
		childChanged();
	}

	@Override
	public void figureMoved(IFigure source) {
		childChanged();
	}

	private void childChanged() {
		if (realBounds != null)
			getUpdateManager().addDirtyRegion(getParent(), realBounds);
		realBounds = null;
		revalidate();
	}

	@Override
	protected void paintFigure(Graphics graphics) {
		// Left empty to prevent super implementation.
	}

	public void setDeclaredBounds(Rectangle rect) {
		declaredBounds = rect;
	}

	@Override
	public Rectangle getHandleBounds() {
		return declaredBounds;
	}
}
