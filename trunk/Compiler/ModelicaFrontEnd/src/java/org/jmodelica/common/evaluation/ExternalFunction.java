package org.jmodelica.common.evaluation;

import java.io.IOException;
import java.util.Map;

import org.jmodelica.common.evaluation.ExternalProcessMultiCache.External;

/**
 * Represents an external function that can be evaluated using
 * {@link ExternalFunction.evaluate}.
 */
public abstract class ExternalFunction<K, V> {

    public ExternalFunction() {
    }

    public abstract int evaluate(External<K> ext, Map<K, V> values, int timeout) throws IOException;

    public abstract void destroyProcess();

    public abstract void remove();

    public abstract String getMessage();
}