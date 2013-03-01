package org.jmodelica.util;

public enum Solvability {
	ANALYTICALLY_SOLVABLE ,
	NUMERICALLY_SOLVABLE {
		@Override
		public boolean isAnalyticallySolvable() {
			return false;
		}
	},
	UNSOLVABLE {
		@Override
		public boolean isSolvable() {
			return false;
		}
	};
	
	
	public boolean isSolvable() {
		return true;
	}
	
	public boolean isAnalyticallySolvable() {
		return isSolvable();
	}
	
}