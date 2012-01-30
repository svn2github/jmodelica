package org.jmodelica.icons.parts.primitives;

public class Color {
	
	public static final Color BLACK = new Color(0, 0, 0);
	public static final Color WHITE = new Color(255, 255, 255);
	private static final int INCREMENT = 50;
	
	private int r;
	private int g;
	private int b;

	public Color() {
		r = g = b = 0;
	}
	
	public Color(int r, int g, int b) {
		this.r = constrain(r);
		this.g = constrain(g); 
		this.b = constrain(b);
	}
	
	private static int constrain(int v) {
		return (v >= 0 && v <= 255) ? v : (v < 0 ? 0 : 255);
	}

	public int getR() {
		return r;
	}
	
	public int getG() {
		return g;
	}
	
	public int getB() {
		return b;
	}
	
	public void setR(int r) {
		this.r = r;
	}
	
	public void setG(int g) {
		this.g = g;
	}
	
	public void setB(int b) {
		this.b = b;
	}
	
	public Color brighter() {
		return increment(INCREMENT);
	}

	public Color darker() {
		return increment(-INCREMENT);
	}
	
	private Color increment(int inc) {
		return new Color(r + inc, g + inc, b + inc);
	}
	
	public String toString() {
		return String.format("(%d, %d, %d)", r, g, b);
	}
}
