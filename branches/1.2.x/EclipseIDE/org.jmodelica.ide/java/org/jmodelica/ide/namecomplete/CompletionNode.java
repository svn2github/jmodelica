package org.jmodelica.ide.namecomplete;

import org.eclipse.swt.graphics.Image;

/**
 * Defines the info to display for a node/import in completion 
 * suggestion list.
 */
public interface CompletionNode {
    public String            completionName();
    public CompletionComment completionDoc();
    public Image             completionImage();
}