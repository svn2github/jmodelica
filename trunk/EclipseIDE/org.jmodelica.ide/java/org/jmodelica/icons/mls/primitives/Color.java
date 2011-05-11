package org.jmodelica.icons.mls.primitives;

public class Color {
	
	public static final Color BLACK = new Color(0, 0, 0);
	public static final Color WHITE = new Color(255, 255, 255);
	
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
	
	public String toString() {
		return "r = " + r + ", g = " + g + ", b = " + b;
	}
}
