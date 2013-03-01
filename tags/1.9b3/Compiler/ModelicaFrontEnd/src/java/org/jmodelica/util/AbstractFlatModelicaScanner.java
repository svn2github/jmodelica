package org.jmodelica.util;

import java.io.IOException;
import java.util.Map;

public abstract class AbstractFlatModelicaScanner {

	public abstract String nextToken() throws IOException, RuntimeException;

	public abstract int lastTokenStart();

}
