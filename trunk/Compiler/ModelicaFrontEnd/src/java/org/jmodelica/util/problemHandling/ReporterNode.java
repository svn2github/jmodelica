package org.jmodelica.util.problemHandling;

import org.jmodelica.util.OptionRegistry;

public interface ReporterNode {
    public int beginLine();
    public int endLine();
    public int beginColumn();
    public int endColumn();
    public String fileName();
    public String errorComponentName();
    public void reportProblem(Problem problem);
    public OptionRegistry myOptions();
    public boolean inDisabledComponent();
}
