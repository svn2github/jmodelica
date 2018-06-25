package org.jmodelica.util.problemHandling;

import org.jmodelica.util.OptionRegistry;

public interface ProblemOptionsProvider {
    public OptionRegistry getOptionRegistry();
    public boolean filterThisWarning(String identifier);
}
