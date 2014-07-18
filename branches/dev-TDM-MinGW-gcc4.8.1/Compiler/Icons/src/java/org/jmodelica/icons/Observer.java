package org.jmodelica.icons;

public interface Observer {
	public void update(Observable o, Object flag, Object additionalInfo);
}
