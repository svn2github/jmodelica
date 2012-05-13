package org.jmodelica.ide.graphical.graphics;

import java.util.ArrayList;
import java.util.List;


import org.eclipse.draw2d.IFigure;
import org.eclipse.draw2d.Locator;
import org.eclipse.draw2d.PositionConstants;
import org.eclipse.draw2d.geometry.PointList;
import org.jmodelica.icons.coord.Extent;
import org.jmodelica.icons.coord.Point;
import org.jmodelica.ide.graphical.util.Converter;
import org.jmodelica.ide.graphical.util.Transform;

public abstract class RotatableLocator implements Locator {
	
	private static final double WIDTH = 1.0;
	private static final double LENGTH = 3.0;
	
	public final static RotatableLocator TOP_LEFT = new RotatableCornerLocator(PositionConstants.NORTH_WEST, false, true) {
		@Override
		protected Point getLocation(Extent e) {
			return e.getTopLeft();
		}
	};
	public final static RotatableLocator TOP_CENTER = new RotatableCenterLocator(PositionConstants.NORTH, true, false) {
		@Override
		protected Point getLocation(Extent e) {
			return e.getTopCenter();
		}
	};
	public final static RotatableLocator TOP_RIGHT = new RotatableCornerLocator(PositionConstants.NORTH_EAST, true, true) {
		@Override
		protected Point getLocation(Extent e) {
			return e.getTopRight();
		}
	};
	public final static RotatableLocator MIDDLE_LEFT = new RotatableCenterLocator(PositionConstants.WEST, false, true) {
		@Override
		protected Point getLocation(Extent e) {
			return e.getMiddleLeft();
		}
	};
	public final static RotatableLocator MIDDLE_RIGHT = new RotatableCenterLocator(PositionConstants.EAST, true, true) {
		@Override
		protected Point getLocation(Extent e) {
			return e.getMiddleRight();
		}
	};
	public final static RotatableLocator BOTTOM_LEFT = new RotatableCornerLocator(PositionConstants.SOUTH_WEST, false, false) {
		@Override
		protected Point getLocation(Extent e) {
			return e.getBottomLeft();
		}
	};
	public final static RotatableLocator BOTTOM_CENTER = new RotatableCenterLocator(PositionConstants.SOUTH, false, false) {
		@Override
		protected Point getLocation(Extent e) {
			return e.getBottomCenter();
		}
	};
	public final static RotatableLocator BOTTOM_RIGHT = new RotatableCornerLocator(PositionConstants.SOUTH_EAST, true, false) {
		@Override
		protected Point getLocation(Extent e) {
			return e.getBottomRight();
		}
	};
	
	private int direction;
	
	private RotatableLocator(int direction) {
		this.direction = direction;
	}
	
	public int getDirection(Transform t) {
		return t.getInverseTransfrom().transformDirection(direction);
	}
	
	protected abstract List<Point> getPoints();
	protected abstract Point getLocation(Extent e);

	@Override
	public void relocate(IFigure target) {
		if (target instanceof RotatableHandle) {
			RotatableHandle handle = (RotatableHandle) target;
			
			Extent e = handle.getOwner().getComponent().getPlacement().getTransformation().getExtent();
			Point p = getLocation(e);
			
			Transform t = handle.getOwner().getComponentTransform();
			t.translate(Transform.yInverter.transform(p));
			List<Point> points = getPoints();
			
			PointList pl = Converter.convert(t.transform(Transform.yInverter.transform(points)));
			handle.setPoints(pl);
			handle.setBounds(pl.getBounds());
		}
	}
	
	private static abstract class RotatableCornerLocator extends RotatableLocator {
		private boolean xNeg;
		private boolean yNeg;
		private RotatableCornerLocator(int direction, boolean xNeg, boolean yNeg) {
			super(direction);
			this.xNeg = xNeg;
			this.yNeg = yNeg;
		}
		
		@Override
		protected List<Point> getPoints() {
			List<Point> points = new ArrayList<Point>();
			points.add(new Point(0,							0));
			points.add(new Point(xNeg ? -LENGTH : LENGTH,	0));
			points.add(new Point(xNeg ? -LENGTH : LENGTH,	yNeg ? -WIDTH : WIDTH));
			points.add(new Point(xNeg ? -WIDTH : WIDTH,		yNeg ? -WIDTH : WIDTH));
			points.add(new Point(xNeg ? -WIDTH : WIDTH,		yNeg ? -LENGTH : LENGTH));
			points.add(new Point(0,							yNeg ? -LENGTH : LENGTH));
			return points;
		}
		
	}

	private static abstract class RotatableCenterLocator extends RotatableLocator {
		private boolean neg;
		private boolean flip;
		private RotatableCenterLocator(int direction, boolean neg, boolean flip) {
			super(direction);
			this.neg = neg;
			this.flip = flip;
		}
		
		@Override
		protected List<Point> getPoints() {
			List<Point> points = new ArrayList<Point>();
			
			double hw = WIDTH / 2;
			double hl = LENGTH - hw;
			
			points.add(createPoint(-hl,	0));
			points.add(createPoint(-hl,	neg ? -WIDTH : WIDTH));
			points.add(createPoint(-hw,	neg ? -WIDTH : WIDTH));
			points.add(createPoint(-hw,	neg ? -LENGTH : LENGTH));
			points.add(createPoint(hw,	neg ? -LENGTH : LENGTH));
			points.add(createPoint(hw,	neg ? -WIDTH : WIDTH));
			points.add(createPoint(hl,	neg ? -WIDTH : WIDTH));
			points.add(createPoint(hl,						0));
			return points;
		}
		
		private Point createPoint(double x, double y) {
			if (flip)
				return new Point(y, x);
			else
				return new Point(x, y);
		}
		
	}

}
