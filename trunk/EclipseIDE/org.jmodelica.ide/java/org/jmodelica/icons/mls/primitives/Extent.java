package org.jmodelica.icons.mls.primitives;


public class Extent {
	private Point p1;
	private Point p2;
	
	public static Extent DEFAULT_EXTENT = new Extent(new Point(-100, -100), new Point(100, 100));

	public static Extent NO_EXTENT = new NO_EXTENT();
	
	public Extent() {
		p1 = Extent.DEFAULT_EXTENT.p1;
		p2 = Extent.DEFAULT_EXTENT.p2;
	}
	
	public Extent(Point p1, Point p2) {
		this.p1 = p1;
		this.p2 = p2;
	}
	public double getHeight()
	{
		return Math.abs(p2.getY()-p1.getY());
		
	}
	public double getWidth()
	{
		return Math.abs(p2.getX()-p1.getX());
	}
	
	public Point getMiddle() {
		Extent ext = fix();
		return new Point(
				ext.getP1().getX()+getWidth()/2,
				ext.getP1().getY()+getHeight()/2
		);
	}
	/**
	 * Returns a version of the given extent where extent.p1 < extent.p2.
	 * 
	 * @param extent
	 * @return
	 */
	public Extent fix() {
		if (p1 == null || p2 == null) {
			return this;
		}
		int minx = (int) (p1.getX());
		int maxx = (int) (p2.getX());
		if (minx > maxx) {
			int temp = minx;
			minx = maxx;
			maxx = temp;
		}
		int miny = (int) (p1.getY());
		int maxy = (int) (p2.getY());
		if (miny > maxy) {
			int temp = miny;
			miny = maxy;
			maxy = temp;
		}

		return new Extent(new Point(minx, miny), new Point(maxx, maxy));
	}
	/**
	 * Returns a copy of this Extent that contains the provided extent,
	 * expanding it symmetric if necessary.
	 */
	public Extent contain(Extent e) {
//		if(this.equals(NO_EXTENT)) {
//			return new Extent(
//					new Point(e.p1.getX(), e.p1.getY()), 
//					new Point(e.p2.getX(), e.p2.getY())
//			);
//		}
		Extent res = new Extent(
				new Point(p1.getX(), p1.getY()), 
				new Point(p2.getX(), p2.getY())
		);
		e = e.fix();
		double diff, prop, newHeight, newWidth;
		
		if (e.p1.getX() < res.p1.getX()) {
			diff = res.p1.getX() - e.p1.getX();
			prop = res.getHeight()/res.getWidth();
			
			res.p1.setX(e.p1.getX());
			res.p2.setX(res.p2.getX() + diff);
			
			 
			//öka y proportionellt
			newHeight = (prop*res.getWidth());
			diff =  (newHeight - res.getHeight())/2;
			res.p1.setY(res.p1.getY() - diff);
			res.p2.setY(res.p2.getY() + diff);
		}
		if (e.p1.getY() < res.p1.getY()) {
			diff = res.p1.getY() - e.p1.getY();
			prop = res.getHeight()/res.getWidth();
			res.p1.setY(e.p1.getY());
			res.p2.setY(res.p2.getY() + diff);
			
			
			//öka x proportionellt
			newWidth = res.getHeight()/prop;
			diff = (newWidth - res.getWidth())/2; 
			res.p1.setX(res.p1.getX() - diff);
			res.p2.setX(res.p2.getX() + diff);
		}
		if (e.p2.getX() > res.p2.getX()) {
			diff = e.p2.getX() - res.p2.getX();
			prop = res.getHeight()/res.getWidth();
			res.p2.setX(e.p2.getX());
			res.p1.setX(res.p1.getX()-diff);
			
						
			//öka y proportionellt
			newHeight = (prop*res.getWidth());
			diff =  (newHeight - res.getHeight())/2;
			res.p1.setY(res.p1.getY() - diff);
			res.p2.setY(res.p2.getY() + diff);
			
			
		}
		if (e.p2.getY() > res.p2.getY()) {
			diff = e.p2.getY() - res.p2.getY();
			prop = res.getHeight()/res.getWidth();
			res.p2.setY(e.p2.getY());
			res.p1.setY(res.p1.getY() - diff);
			
			//öka x proportionellt
			newWidth = res.getHeight()/prop;
			diff = (newWidth - res.getWidth())/2; 
			res.p1.setX(res.p1.getX() - diff);
			res.p2.setX(res.p2.getX() + diff);
		
		}
		return res;
	}
	
	public Extent clone() {
		return new Extent(p1.clone(), p2.clone());
	}
	public void setP2(Point p2) {
		this.p2 = p2;
	}
	public Point getP2() {
		return p2;
	}
	public void setP1(Point p1) {
		this.p1 = p1;
	}
	public Point getP1() {
		return p1;
	}
	public String toString() {
		return "P1 = " + getP1() + ", P2 = " + getP2() + ", width = " + getWidth() + ", height = " + getHeight();
	}
	public static class NO_EXTENT extends Extent {
		public NO_EXTENT() {
			super(null, null);
		}
		public String toString() {
			return "No extent.";
		}
	}
}