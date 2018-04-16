package org.jmodelica.common.evaluation;

import org.jmodelica.common.evaluation.ExternalProcessMultiCache.External;
import org.jmodelica.common.evaluation.ExternalProcessMultiCache.Type;
import org.jmodelica.common.evaluation.ExternalProcessMultiCache.Value;
import org.jmodelica.common.evaluation.ExternalProcessMultiCache.Variable;

public interface ExternalProcessCache<K extends Variable<V, T>, V extends Value, T extends Type<V>, E extends External<K>> {

    /**
     * If there is no executable corresponding to <code>ext</code>, create one.
     */
    public ExternalFunction<K, V> getExternalFunction(E ext);

    /**
     * Remove executables compiled by the constant evaluation framework.
     */
    public void removeExternalFunctions();

    /**
     * Kill cached processes
     */
    public void destroyProcesses(int externalEvaluation);

    public void tearDown(int externalEvaluation);

    public ExternalFunction<K, V> failedEval(External<?> ext, String msg, boolean log);
    

}
