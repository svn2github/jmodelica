package org.jmodelica.util;

public class GetJavaHome {

	public static void main(String[] args) {
		String home = System.getProperty("java.home");
		String sep = System.getProperty("file.separator");
		int pos = home.lastIndexOf(sep) + 1;
		if (home.substring(pos).equals("jre"))
			home = home.substring(0, pos);
		System.out.println(home);
	}

}
