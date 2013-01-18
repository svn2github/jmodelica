package org.jastadd.ed.core.service.view.typehierarchy;

import org.eclipse.jface.text.IRegion;
import org.eclipse.jface.text.ITextViewer;
import org.eclipse.jface.text.Region;
import org.eclipse.jface.text.information.IInformationProvider;
import org.eclipse.jface.text.information.IInformationProviderExtension;
import org.jastadd.ed.core.model.node.ILocalRootHandle;
import org.jastadd.ed.core.model.node.ILocalRootNode;
import org.jastadd.ed.core.model.node.ITextViewNode;

public class QuickTypeHierarchyInformationProvider implements
		IInformationProvider, IInformationProviderExtension {

	private ILocalRootHandle fRootHandle;
	
	public QuickTypeHierarchyInformationProvider(ILocalRootHandle proxy) {
		fRootHandle = proxy;
	}
	
	@Override
	public IRegion getSubject(ITextViewer textViewer, int offset) {
		// This is not really used at this point
		return new Region(offset, 0);
	}

	@Override
	public String getInformation(ITextViewer textViewer, IRegion subject) {
		// This is deprecated in favor for getInformation2(..)
		return null;
	}

	@Override
	public Object getInformation2(ITextViewer textViewer, IRegion subject) {
		
		TypeHierarchyNode result = null;
		int offset = subject.getOffset();
		if (offset >= 0 && fRootHandle.isInCompilableProject()) {
			try {
				fRootHandle.getLock().acquire();
				ILocalRootNode localRoot = fRootHandle.getLocalRoot();
				if (localRoot instanceof ITextViewNode) {
					ITextViewNode node = ((ITextViewNode)localRoot).findNodeForOffset(offset);
					//System.out.println("QuickTypeHierarchyInfoProvider: Found node of type " + (node == null ? "null" : node.getClass().getName()));
					if (node instanceof ITypeHierarchyNode) {
						ITypeHierarchyNode typeNode = (ITypeHierarchyNode)node;
						result = TypeHierarchyNode.convertResult(typeNode);
					}
				}
			} finally {
				fRootHandle.getLock().release();
			}
		}
		
		return result;
	}

}
