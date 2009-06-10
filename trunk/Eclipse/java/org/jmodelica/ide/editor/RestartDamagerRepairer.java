package org.jmodelica.ide.editor;

import org.eclipse.jface.text.DocumentEvent;
import org.eclipse.jface.text.IRegion;
import org.eclipse.jface.text.ITypedRegion;
import org.eclipse.jface.text.rules.DefaultDamagerRepairer;
import org.eclipse.jface.text.rules.ITokenScanner;

public class RestartDamagerRepairer extends DefaultDamagerRepairer {

	public RestartDamagerRepairer(ITokenScanner scanner) {
		super(scanner);
	}

	@Override
	public IRegion getDamageRegion(ITypedRegion partition, DocumentEvent e,
			boolean documentPartitioningChanged) {
		return partition;
	}

}
