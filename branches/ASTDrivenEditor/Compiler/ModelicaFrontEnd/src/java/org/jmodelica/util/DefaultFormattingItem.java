package org.jmodelica.util;

import org.jmodelica.util.FormattingItem.Adjacency;

public class DefaultFormattingItem extends FormattingItem {

	public DefaultFormattingItem(Type type, String data) {
		super(type, data, -1, -1, -1, -1);
	}
	
	public Adjacency getAdjacency(FormattingItem otherItem) {
		return Adjacency.NONE;
	}
	
	public FormattingItem mergeItems(Adjacency where, FormattingItem otherItem) {
		return this;
	}
}
