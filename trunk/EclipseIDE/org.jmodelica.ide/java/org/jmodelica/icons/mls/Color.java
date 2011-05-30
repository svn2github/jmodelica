package org.jmodelica.icons.mls;

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
		this.r = r;
		this.g = g; 
		this.b = b;
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
		int r = this.r+inc;
		int g = this.g+inc;
		int b = this.b+inc;
		r = r < 0 	? 0 	: r;
		r = r > 255 ? 255 	: r;
		g = g < 0 	? 0 	: g;
		g = g > 255 ? 255 	: g;
		b = b < 0 	? 0 	: b;
		b = b > 255 ? 255 	: b;
		return new Color(r, g, b);
	}
	
	public String toString() {
		return "r = " + r + ", g = " + g + ", b = " + b;
	}
}
