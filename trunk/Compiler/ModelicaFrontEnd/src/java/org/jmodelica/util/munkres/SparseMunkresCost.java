package org.jmodelica.util.munkres;

/**
 * Interface that must be implemented for the cost of each incidence used in
 * sparse Munkres problems. Costs that implements this interface can also be
 * used in dense Munkres problems.
 */
public interface SparseMunkresCost<T> extends MunkresCost<T> {

    /**
     * Checks if the provided incidence cost is matchable or should be ignored
     * during solving of the Munkres problem
     * 
     * @return true if the incidence should be considered during Munkres,
     *         otherwise false
     */
    public boolean isUnmatched();
}
