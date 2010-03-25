package org.jmodelica.util;

public class GetJavaHome {

	public static void main(String[] args) {
		String home = System.getProperty("java.home");
		String sep = System.getProperty("file.separator");
		System.out.println(home.substring(0, home.lastIndexOf(sep) + 1));
	}

}
