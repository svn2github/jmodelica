package org.jmodelica.icons.primitives;

import org.jmodelica.icons.Observable;

public class Color extends Observable {
	
	public static final Object RED_CHANGED = new Object();
	public static final Object GREEN_CHANGED = new Object();
	public static final Object BLUE_CHANGED = new Object();
	
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
	
	public void setR(int newR) {
		if (r == newR)
			return;
		r = newR;
		notifyObservers(RED_CHANGED);
	}
	
	public void setG(int newG) {
		if (g == newG)
			return;
		g = newG;
		notifyObservers(BLUE_CHANGED);
	}
	
	public void setB(int newB) {
		if (b == newB)
			return;
		b = newB;
		notifyObservers(GREEN_CHANGED);
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
