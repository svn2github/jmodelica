package org.jmodelica.ide;

import org.jastadd.ed.core.Builder;
import org.jastadd.ed.core.ICompiler;
import org.jastadd.ed.core.model.IGlobalRootRegistry;
import org.jmodelica.ide.compiler.ModelicaEclipseCompiler;
import org.jmodelica.ide.sync.ModelicaASTRegistry;
import org.jmodelica.ide.sync.UniqueIDGenerator;

public class ModelicaBuilder extends Builder {
	public static final String BUILDER_ID = "org.jmodelica.ide.ModelicaBuilder";

	public ModelicaBuilder() {
		super();
	}

	@Override
	protected IGlobalRootRegistry createRegistry() {
		return ModelicaASTRegistry.getInstance();
	}

	@Override
	protected ICompiler createCompiler() {
		return new ModelicaEclipseCompiler();
	}
	
	@Override
	protected boolean shouldWeRecompile(){
		return UniqueIDGenerator.getInstance().needWeRecompile();
	}

}
