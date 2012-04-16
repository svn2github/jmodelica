package org.jmodelica.ide.graphical.graphics;

import org.eclipse.draw2d.Figure;
import org.eclipse.draw2d.FigureListener;
import org.eclipse.draw2d.Graphics;
import org.eclipse.draw2d.IFigure;
import org.eclipse.draw2d.Layer;
import org.eclipse.draw2d.TreeSearch;
import org.eclipse.draw2d.geometry.Rectangle;

public class IconLayer extends Layer implements FigureListener {
	public IFigure findFigureAt(int x, int y, TreeSearch search) {
		IFigure fig = super.findFigureAt(x, y, search);
		if (fig == null)
			return null;
		else if (fig instanceof IconLayer)//FIXME: make sure this is a connector...
			return fig;
		else
			return this;
	}

//	private Rectangle bounds = null;

	public Rectangle getBounds() {
		if (bounds == null) {
			bounds = calculateBounds();
			fireFigureMoved();
		}
		return bounds;
	}
	
	@Override
	public void setBounds(Rectangle rect) {
		// Can't set bounds since it's calculated.
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

	public void add(IFigure figure, Object constraint, int index) {
		super.add(figure, constraint, index);
		figure.addFigureListener(this);
		childChanged();
	}

	public void remove(IFigure figure) {
		super.remove(figure);
		figure.removeFigureListener(this);
		childChanged();
	}

	public void figureMoved(IFigure source) {
		childChanged();
	}

	private void childChanged() {
		if (bounds != null)
			getUpdateManager().addDirtyRegion(getParent(), bounds);
		bounds = null;
		revalidate();
	}
	
	@Override
	protected void paintFigure(Graphics graphics) {
		// Left empty to prevent super implementation.
	}
}
