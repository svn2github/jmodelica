package org.jmodelica.ide.graphical;

import org.jmodelica.ide.graphical.util.ASTResourceProvider;
import org.jmodelica.modelica.compiler.InstNode;

/**
 * An extension of the {@link ASTResourceProvider} class. This class is used
 * when there is no open components in the editor.
 * 
 * @see ASTResourceProvider
 * @author jsten
 * 
 */
public class EditorASTResourceProvider extends ASTResourceProvider {

	private Editor editor;

	/**
	 * Constructs an instance of this class using an {@link Editor}
	 * <code>editor</code>
	 * 
	 * @param the {@link Editor}
	 */
	public EditorASTResourceProvider(Editor editor) {
		this.editor = editor;
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see org.jmodelica.ide.graphical.util.ASTResourceProvider#getRoot()
	 */
	@Override
	protected InstNode getRoot() {
		return editor.getInstClassDecl();
	}
}
