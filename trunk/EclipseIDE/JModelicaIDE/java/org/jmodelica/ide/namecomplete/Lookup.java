package org.jmodelica.ide.namecomplete;

import org.eclipse.jface.text.IDocument;
import org.jmodelica.ide.helpers.Maybe;
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
    /**
     * Finds node in instance tree of the class at offset.
     *  
     * @param offset offset to look up in
     * @return Just(instNode) if node found, o.w. Nothing  
     */
    public Maybe<InstClassDecl> instEnclosingClassAt(IDocument d, int offset) {
        
        //TODO: make getNodeAt faster, or use existing method in JastADD core
        Maybe<ClassDecl> result = root.getClassDeclAt(d, offset);
        if (result.isNothing())
            return Maybe.<InstClassDecl>Nothing();
        
        ClassDecl enclosingClass = result.value();
        
        InstClassDecl instClass = ((SourceRoot)root.root())
            .getProgram()
            .getInstProgramRoot()
            .simpleLookupInstClassDeclRecursive(enclosingClass.qualifiedName());

        return Maybe.Just(instClass);
    }
    
    /**
     * Returns the declaration of the access at <code>offset</code>. 
     * @param d document to do lookup in
     * @param offset offset of access
     * @return declaration of access at <code> offset </code>
     */
    public Maybe<InstNode> declFromAccessAt(IDocument d, int offset) {
        
        Maybe<InstClassDecl> enclosingClass = instEnclosingClassAt(d, offset);
        Maybe<Access> access = root.getAccessAt(d, offset);

        if (enclosingClass.isNothing() || access.isNothing()) 
            return Maybe.<InstNode>Nothing();

        Maybe<InstNode> iNode = lookupQualifiedName(
                enclosingClass.value(),
                access.value());
        
        return iNode;
    }
    
    /**
     * Dynamically add a <code> instAccess </code> to instance tree 
     * as a _Component_.
     */
    public Maybe<InstNode> tryAddComponentDecl(
            InstClassDecl encInst, 
            InstAccess instAccess) {
      
        encInst.addDynamicComponentName(instAccess);
        InstAccess a = encInst.getDynamicComponentName(
                encInst.getNumDynamicComponentName()-1);
        InstComponentDecl node = a.myInstComponentDecl();
        
        return Maybe.<InstNode>fromBool(node, !node.isUnknown()); 
    }

    /**
     * Dynamically add a <code> instAccess </code> to instance tree 
     * as a _Class_.
     */
    public Maybe<InstNode> tryAddClassDecl(
            InstClassDecl encInst, 
            InstAccess instAccess) {
        
        encInst.addDynamicClassName(instAccess);
        InstAccess a = encInst.getDynamicClassName(
                encInst.getNumDynamicClassName()-1);
        InstClassDecl node = a.myInstClassDecl();
        
        return Maybe.<InstNode>fromBool(node, !node.isUnknown()); 
    }

    /**
     * Dynamically add a <code> instAccess </code> to instance tree. If resulting
     * node can be classified as not Unknown, return Just that declaration, o.w.
     * Nothing.
     */
    protected Maybe<InstNode> tryAddDecl(
            InstClassDecl encInst, 
            InstAccess instAccess) {
        
        return tryAddClassDecl(encInst, instAccess)
                .orElse(
               tryAddComponentDecl(encInst, instAccess));
    }

    /**
     * Looks up name and returns an InstClassDecl or an InstComponentDecl if 
     * one is found, or Nothing if lookup fails.
     * @param enclosingClass
     * @param access
     * @return
     */
    public Maybe<InstNode> lookupQualifiedName(
            InstClassDecl enclosingClass,
            Access access) {

        return tryAddDecl(enclosingClass, access.newInstAccess());
    }
    
}