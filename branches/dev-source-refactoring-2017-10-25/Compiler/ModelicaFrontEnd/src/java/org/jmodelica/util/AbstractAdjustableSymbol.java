package org.jmodelica.util;

import beaver.Symbol;

public abstract class AbstractAdjustableSymbol extends Symbol implements AdjustableSymbol {

    public AbstractAdjustableSymbol() {
    }

    public AbstractAdjustableSymbol(short id, int line, int column, int length, Object value) {
        super(id, line, column, length, value);
    }

    /* NB: This method is duplicated in:
     * ModelicaFrontEnd/src/jastadd/source/Parser.jrag, ASTNode */
    @Override
    public int adjustStartOfEmptySymbols(AdjustableSymbol[] syms, int i) {
        if (start == end && i < syms.length) {
            start = end = syms[i].adjustStartOfEmptySymbols(syms, i + 1);
        }
        return start;
    }
}
