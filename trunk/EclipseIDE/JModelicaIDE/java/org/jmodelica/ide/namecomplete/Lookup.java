package org.jmodelica.ide.namecomplete;

import org.jmodelica.ide.OffsetDocument;
import org.jmodelica.ide.helpers.Maybe;
import org.jmodelica.ide.helpers.Util;
import org.jmodelica.modelica.compiler.ASTNode;
import org.jmodelica.modelica.compiler.Access;
import org.jmodelica.modelica.compiler.ClassDecl;
import org.jmodelica.modelica.compiler.InstAccess;
import org.jmodelica.modelica.compiler.InstClassDecl;
import org.jmodelica.modelica.compiler.InstComponentDecl;
import org.jmodelica.modelica.compiler.InstNode;
import org.jmodelica.modelica.compiler.SourceRoot;

/**
 * Utility class to perform various lookups in instance tree.
 * 
 * @author philip
 *
 */
public class Lookup {

final ASTNode<?> root;

public Lookup(ASTNode<?> root) {
    this.root = root;
}

public InstClassDecl instClassDeclFromQualifiedName(String qualifiedName) {
    SourceRoot sourceRoot =
        (SourceRoot) root.root();
    return
        sourceRoot
        .getProgram()
        .getInstProgramRoot()
        .simpleLookupInstClassDeclRecursive(qualifiedName); 
}

/**
 * Finds node in instance tree of the class at offset.
 *  
 * @param offset offset to look up in
 * @return Just(instNode) if node found, o.w. Nothing  
 */
public Maybe<InstClassDecl> instEnclosingClassAt(OffsetDocument d) {
    
    Maybe<ClassDecl> result = 
        root.getClassDeclAt(d, d.offset);
    
    return result.isNothing() 
        ? Maybe.<InstClassDecl>Nothing()
        : Maybe.<InstClassDecl>Just(
            instClassDeclFromQualifiedName(
                result.value()
                .qualifiedName()));
}

/**
 * Returns the declaration of the access at <code>offset</code>. 
 * @param d document to do lookup in
 * @param offset offset of access
 * @return declaration of access at <code> offset </code>
 */
public Maybe<InstNode> declarationFromAccessAt(
    OffsetDocument d) 
{
    Maybe<InstClassDecl> enclosingClass = 
        instEnclosingClassAt(d);
    Maybe<Access> access = 
        root.getAccessAt(d, d.offset);

    if (enclosingClass.isNothing() || access.isNothing()) 
        return Maybe.<InstNode>Nothing();

    Maybe<InstNode> iNode = lookupQualifiedName(
            access.value(),
            enclosingClass.value());
    
    return iNode;
}

/**
 * Dynamically add <code> instAccess </code> to instance tree 
 * as a _Component_.
 */
protected Maybe<InstNode> tryAddComponentDecl(
    InstClassDecl enclosingInstance, 
    InstAccess instAccess)
{

    InstComponentDecl node =
        enclosingInstance
        .addComponentDynamic(instAccess)
        .myInstComponentDecl();

    return Maybe.<InstNode>guard(node, node.isKnown()); 
}

/**
 * Dynamically add <code> instAccess </code> to instance tree 
 * as a _Class_.
 */
protected Maybe<InstNode> tryAddClassDecl(
    InstClassDecl enclosingInstClass, 
    InstAccess instAccess)
{
    InstClassDecl node =
        enclosingInstClass
        .addClassDynamic(instAccess)
        .myInstClassDecl();
            
    return Maybe.<InstNode>guard(node, node.isKnown()); 
}

/**
 * Looks up name and returns an InstClassDecl or an InstComponentDecl if 
 * one is found, or Nothing if lookup fails.
 * @param access
 * @param enclosingClass
 * @return
 */
public Maybe<InstNode> lookupQualifiedName(
        Access access,
        InstClassDecl encInst) 
{ 
    System.out.println("----------------------------");
    System.out.println("----------------------------");
    System.out.println("came here");
    System.out.println(access.hashCode());
    access.setParent(encInst.getClassDecl());
    System.out.println("----------------------------");
    System.out.println("----------------------------");
    System.out.println("----------------------------");
    
    return 
        tryAddComponentDecl(encInst, access.newInstAccess())
        .orElse(
        tryAddClassDecl(encInst, access.newInstAccess()));
}

public Maybe<InstNode> lookupQualifiedName(
        String qualifiedPart,
        OffsetDocument doc) 
{
    Maybe<InstClassDecl> mEnclosingClass =
        instEnclosingClassAt(doc);
    
    if (qualifiedPart.equals("") || mEnclosingClass.isNothing()) {
        return mEnclosingClass.subsume(InstNode.class);
    } else {
    
        return lookupQualifiedName(
            Util.createDotAccess(qualifiedPart),
            mEnclosingClass.value());
    }
}
    
}