package org.jmodelica.util;

public interface AdjustableSymbol {
    /**
     * Adjusts the position of empty terminals at the beginning of a composite terminal to 
     * be positioned at the start of the first non-empty one rather than at the end of the 
     * previous one.
     * 
     * @param syms  the symbols to operate on
     * @param i     the index of the next symbol (<code>this</code> should be at syms[i - 1])
     * @return      the start value of this symbol after adjusting
     */
    public int adjustStartOfEmptySymbols(AdjustableSymbol[] syms, int i);
}
