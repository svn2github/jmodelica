package org.jmodelica.ide.graphical.graphics;

import org.eclipse.draw2d.PolylineConnection;
import org.eclipse.draw2d.PositionConstants;

public class TemporaryConnectionFigure extends PolylineConnection {
	private int sourceDirection = PositionConstants.NONE;
	private int targetDirection = PositionConstants.NONE;
	
	public int getSourceDirection() {
		return sourceDirection;
	}
	
	public void setSourceDirection(int sourceDirection) {
		this.sourceDirection = sourceDirection;
	}
	
	public int getTargetDirection() {
		return targetDirection;
	}
	
	public void setTargetDirection(int targetDirection) {
		this.targetDirection = targetDirection;
	}
}
