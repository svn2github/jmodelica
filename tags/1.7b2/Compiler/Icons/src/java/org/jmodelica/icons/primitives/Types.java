package org.jmodelica.icons.primitives;
public class Types {
	
	public enum LinePattern {
		
		NONE(null),
		SOLID(null),
		DASH(new float[] {4.0f}),
		DOT(new float[] {2.0f}),
		DASHDOT(new float[] {2.0f, 4.0f}),
		DASHDOTDOT(new float[] {4.0f, 2.0f, 2.0f});
		
		private float[] dash;
		
		LinePattern(float[] dash) {
			this.dash = dash;
		}
		
		public float[] getDash() {
			return dash;
		}
	}

	
	public static enum FillPattern {
		NONE, 
		SOLID,
		HORIZONTAL,
		VERTICAL,
		CROSS,
		FORWARD,
		BACKWARD,
		CROSSDIAG,
		HORIZONTALCYLINDER,
		VERTICALCYLINDER,
		SPHERE
	}
	
	public static enum BorderPattern {
		NONE,
		RAISED,
		SUNKEN,
		ENGRAVED
	}
	
	public static enum Smooth {
		NONE,
		BEZIER
	}
	
	public static enum Arrow {
		NONE,
		OPEN,
		FILLED,
		HALF
	}
	
	public static enum TextStyle {
		BOLD,
		ITALIC,
		UNDERLINE
	}
	
	public static enum TextAlignment {
		LEFT,
		CENTER,
		RIGHT
	}
}