package org.jmodelica.icons.test;

import java.util.ArrayList;

import org.jmodelica.modelica.compiler.ClassDecl;

public abstract class ClassesWithIconsList {
	private static ArrayList<ClassDecl> list = new ArrayList<ClassDecl>();
	
	public static boolean hasIcon(ClassDecl decl) {
		return list.contains(decl);
	}
	
	public static void add(ClassDecl decl) {
		list.add(decl);
	}
}
