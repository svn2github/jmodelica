
package org.jmodelica.debug;

import org.jmodelica.ast.*;
import java.util.HashSet;

public aspect DebugNameLookup {

	before(String name) : call(* Access.lookupClass(String)) 
	                        &&(args(name)) {
		System.out.println("Access.LookupClass: "+name);
	}
	/*
	before(ComponentAccess ca, String name) : target(ca) &&
	                                          call(* ComponentAccess.myComponentDecl()) &&
                                              execution(* ComponentAccess.qualifiedLookupComponent(..)) &&
    						                  args(name) {
		System.out.println("ComponentAccess.qualifiedLookupComponent (" + ca.name() + ") looking for: " + name);
	}
	*/
	
	pointcut Dot_Define_HashSet_lookupComponent(Dot d, String name) : 
		                    target(d) &&
                            withincode(* Dot.Define_HashSet_lookupComponent(..)) &&
                            args(ASTNode,ASTNode,name);
	
	before(Dot d,String name) :  /*call(* Dot.getLeft()) &&*/
	                             Dot_Define_HashSet_lookupComponent(d,name) {
		System.out.println("Dot.getRight().lookupComponent(String name) (" + d.name() + ") looking for: "+name);
	}
	
}
