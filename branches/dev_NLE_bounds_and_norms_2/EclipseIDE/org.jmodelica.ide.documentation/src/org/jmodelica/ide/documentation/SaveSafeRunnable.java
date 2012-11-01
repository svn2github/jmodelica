package org.jmodelica.ide.documentation;

import java.io.ByteArrayInputStream;

import org.eclipse.jface.util.SafeRunnable;
import org.jmodelica.modelica.compiler.ClassDecl;
import org.jmodelica.modelica.compiler.StoredDefinition;

public class SaveSafeRunnable extends SafeRunnable{
	private ClassDecl currentClass;
	public SaveSafeRunnable(ClassDecl cd){
		this.currentClass = cd;
	}

	@Override
	public void run() throws Exception {
		StoredDefinition definition = currentClass.getDefinition();	
		if (definition == null || definition.getFile() == null){
			System.err.print("couldn't get the definition of the class, or it's corresponding file. Is it part of the standard library?");
			return;
		}
		definition.getFile().setContents(new ByteArrayInputStream(definition.prettyPrintFormatted().getBytes()), false, true, null);
		
	}

}
