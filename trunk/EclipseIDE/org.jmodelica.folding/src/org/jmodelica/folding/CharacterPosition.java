/*******************************************************************************
 * Copyright (c) 2009 Modelon AB and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Contributors:
 *     Modelon AB - Initial implementation
 *******************************************************************************/
package org.jmodelica.folding;

import org.eclipse.jface.text.Position;

public class CharacterPosition extends Position {

	public CharacterPosition(int offset, int length) {
		super(offset, length);
	}

}
