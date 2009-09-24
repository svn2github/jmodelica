/*
    Copyright (C) 2009 Modelon AB

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, version 3 of the License.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */
package org.jmodelica.ide;

import java.util.Arrays;
import java.util.Collection;

import org.eclipse.core.resources.IContainer;
import org.eclipse.core.resources.IFile;
import org.eclipse.core.resources.IProject;
import org.eclipse.core.resources.IResource;
import org.eclipse.core.runtime.CoreException;
import org.eclipse.core.runtime.IProgressMonitor;
import org.eclipse.jface.text.IDocument;
import org.eclipse.jface.text.IRegion;
import org.eclipse.jface.text.reconciler.DirtyRegion;
import org.jastadd.plugin.compiler.AbstractCompiler;
import org.jastadd.plugin.compiler.ast.IASTNode;
import org.jmodelica.ide.helpers.DocumentReader;
import org.jmodelica.ide.helpers.Maybe;
import org.jmodelica.modelica.compiler.ASTNode;


public class ModelicaCompiler extends AbstractCompiler {

public static final String ERROR_MARKER_ID = IDEConstants.ERROR_MARKER_ID;

@Override
protected IASTNode compileToProjectAST(IProject project,
        IProgressMonitor monitor) {
    return recursiveCompile(new CompilationRoot(), project, monitor).root();
}

private CompilationRoot recursiveCompile(
        CompilationRoot lasr, 
        IContainer parent,
        IProgressMonitor monitor) {

    try {
        
        IResource[] resources = parent.members();
        
        for (IResource resource : resources) {
            
            if (monitor.isCanceled())
                break;
            
            switch (resource.getType()) {
            case IResource.FOLDER:
                /* do nothing right now*/
                break;
            case IResource.FILE:
                IFile file = (IFile)resource;
                if (IDEConstants.FILE_EXT.equals(file.getFileExtension()))
                    lasr = lasr.parseFile(file, null);
                break;
            }
            
            monitor.worked(1);
        }
        
    } catch (CoreException e) {
        
        e.printStackTrace();
        
    }
    
    return lasr;
}

@Override
public IASTNode compileToAST(IDocument document, DirtyRegion dirtyRegion,
        IRegion region, IFile file) {
    
    return new CompilationRoot().parseFile(
            new DocumentReader(document), 
            file,
            file.getRawLocation().toOSString())
        .getStoredDefinition();

}

public Maybe<ASTNode<?>> recompile(IDocument doc, IFile file) {
    return new Maybe<ASTNode<?>>((ASTNode<?>)
            compileToAST(doc, null, null, file));
}

@Override
protected IASTNode compileToAST(IFile file) {
    return compileFile(file, file.getRawLocation().toOSString());
}



public ASTNode<?> compileFile(IFile file, String path) {
    return new CompilationRoot().parseFile(file, path)
            .getStoredDefinition();
}

@Override
protected Collection<String> acceptedFileExtensions() {
    return Arrays.asList(IDEConstants.ALL_FILE_EXTENSIONS);
}

@Override
protected String acceptedNatureID() {
    return IDEConstants.NATURE_ID;
}
}
