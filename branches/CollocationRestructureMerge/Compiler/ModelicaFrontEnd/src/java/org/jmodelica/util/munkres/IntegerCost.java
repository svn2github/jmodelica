package org.jmodelica.util.munkres;

public class IntegerCost implements MunkresCost<IntegerCost> {
    
    private int value;
    
    private IntegerCost(int value) {
        this.value = value;
    }
    
    @Override
    public int compareTo(IntegerCost other) {
        return new Integer(value).compareTo(other.value);
    }

    @Override
    public void subtract(IntegerCost other) {
        value -= other.value;
    }

    @Override
    public void add(IntegerCost other) {
        value += other.value;
    }

    @Override
    public boolean isZero() {
        return value == 0;
    }
    
    @Override
    public IntegerCost copy() {
        return new IntegerCost(value);
    }
    
    public static IntegerCost[][] create(int[][] values) {
        IntegerCost[][] costs = new IntegerCost[values.length][];
        for (int j = 0; j < values.length; j++) {
            costs[j] = new IntegerCost[values[j].length];
            for (int i = 0; i < values.length; i++)
                costs[j][i] = new IntegerCost(values[j][i]);
        }
        return costs;
    }
    
    @Override
    public String toString() {
        return Integer.toString(value);
    }
}
