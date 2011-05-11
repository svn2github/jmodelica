package org.jmodelica.icons.enums;

public enum LinePattern {
	
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
