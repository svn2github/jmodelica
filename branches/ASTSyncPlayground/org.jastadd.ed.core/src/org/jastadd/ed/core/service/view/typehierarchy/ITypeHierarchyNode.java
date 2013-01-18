package org.jastadd.ed.core.service.view.typehierarchy;

import java.util.Collection;
import org.eclipse.swt.graphics.Image;
import org.jastadd.ed.core.model.node.ITextViewNode;

public interface ITypeHierarchyNode extends ITextViewNode {

	public ITypeHierarchyNode typeHierarchyParent();
	public Collection<ITypeHierarchyNode> typeHierarchyChildren();
	
	public String typeHierarchyLabel();
	public Image typeHierarchyImage();
	
	
}
