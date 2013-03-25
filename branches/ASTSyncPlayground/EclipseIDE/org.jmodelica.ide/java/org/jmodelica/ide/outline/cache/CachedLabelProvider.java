package org.jmodelica.ide.outline.cache;

import org.eclipse.jface.viewers.LabelProvider;
import org.eclipse.swt.graphics.Image;

public class CachedLabelProvider extends LabelProvider {

	@Override
	public Image getImage(Object element) {
		if (element instanceof ICachedOutlineNode){
			//System.out.println("CachedLabelProvider: getImage() node:"+((ICachedOutlineNode
			//		)element).getText());
			return((ICachedOutlineNode)element).getImage();
		}
		return null;
	}

	@Override
	public String getText(Object element) {
		if (element instanceof ICachedOutlineNode){
		//	System.out.println("CachedLabelProvider: getText() node:"+((ICachedOutlineNode
		//			)element).getText());
			return((ICachedOutlineNode)element).getText();
		}
		return null;
	}
}
