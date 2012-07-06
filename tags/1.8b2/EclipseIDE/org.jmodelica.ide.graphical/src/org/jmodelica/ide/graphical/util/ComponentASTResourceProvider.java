package org.jmodelica.ide.graphical.util;

import org.jmodelica.modelica.compiler.InstNode;

/**
 * An extension of the {@link ASTResourceProvider} class. This class is used
 * when there is open components in the editor.
 * 
 * @see ASTResourceProvider
 * @author jsten
 * 
 */
public class ComponentASTResourceProvider extends ASTResourceProvider {

	private ASTResourceProvider parent;
	private String componentName;

	/**
	 * Constructs an instance of this class using a parent
	 * {@link ASTResourceProvider} <code>parent</code> and the name
	 * <code>componentName</code> of this component.
	 * 
	 * @param parent The parent {@link ASTResourceProvider}
	 * @param componentName The name of the component that this instance should
	 *            represent
	 */
	public ComponentASTResourceProvider(ASTResourceProvider parent, String componentName) {
		this.parent = parent;
		this.componentName = componentName;
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see org.jmodelica.ide.graphical.util.ASTResourceProvider#getRoot()
	 */
	@Override
	protected InstNode getRoot() {
		return parent.getInstComponentDeclByName(componentName);
	}

}
