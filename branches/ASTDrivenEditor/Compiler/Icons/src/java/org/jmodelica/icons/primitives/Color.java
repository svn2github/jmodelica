package org.jmodelica.icons.primitives;

/**
 * A class that represents an color given the three base colors red, green and
 * blue. The value of the color is stored as three integers in the range 0
 * through 255.
 */
public class Color {

	/**
	 * A representation of the color black (0, 0, 0).
	 */
	public static final Color BLACK = new Color(0, 0, 0);

	/**
	 * A representation of the color white (255, 255, 255).
	 */
	public static final Color WHITE = new Color(255, 255, 255);

	/**
	 * Constant defining the amount to increase/decrease when doing
	 * brigher/darker.
	 */
	private static final int INCREMENT = 50;

	private int r;
	private int g;
	private int b;

	/**
	 * Constructs an color equal to black.
	 */
	public Color() {
		r = g = b = 0;
	}

	/**
	 * Constructs an color with the color (<code>r</code>, <code>g</code>,
	 * <code>b</code>).
	 * Color amount should be between 0 and 255.
	 * 
	 * @param r amount of red
	 * @param g amount of green
	 * @param b amount of blue
	 */
	public Color(int r, int g, int b) {
		this.r = constrain(r);
		this.g = constrain(g);
		this.b = constrain(b);
	}

	/**
	 * Constrains the color between 0 and 255.
	 * 
	 * @param v value to constrain
	 * @return constrained value
	 */
	private static int constrain(int v) {
		if (v < 0)
			return 0;
		if (v > 255)
			return 255;
		else
			return v;
	}

	/**
	 * Returns the amount of red in this color.
	 * 
	 * @return amount of red
	 */
	public int getR() {
		return r;
	}

	/**
	 * Returns the amount of green in this color.
	 * 
	 * @return amount of green
	 */
	public int getG() {
		return g;
	}

	/**
	 * Returns the amount of blue in this color.
	 * 
	 * @return amount of blue
	 */
	public int getB() {
		return b;
	}

	/**
	 * Returns a color that is brighter than this color.
	 * 
	 * @return a brighter color
	 */
	public Color brighter() {
		return increment(INCREMENT);
	}

	/**
	 * Returns a color that is darker than this color.
	 * 
	 * @return a darker color
	 */
	public Color darker() {
		return increment(-INCREMENT);
	}

	/**
	 * Increments this color with the given incremental <code>inc</code>.
	 * 
	 * @param inc amount to increment
	 * @return incremented color
	 */
	private Color increment(int inc) {
		return new Color(r + inc, g + inc, b + inc);
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see java.lang.Object#toString()
	 */
	public String toString() {
		return String.format("(%d, %d, %d)", r, g, b);
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see java.lang.Object#equals(java.lang.Object)
	 */
	@Override
	public boolean equals(Object obj) {
		if (!(obj instanceof Color))
			return false;
		Color c = (Color) obj;
		return r == c.r && g == c.g && b == c.b;
	}
}
