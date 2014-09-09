package org.jmodelica.util.munkres;

import java.util.ArrayList;

public class MunkresProblem<T extends MunkresCost<T>> {

    private int n;
    private int m;
    private int k;
    private T cost[][];
    private boolean rowCover[];
    private boolean columnCover[];
    private boolean starred[][];
    private boolean primed[][];

    private final int COVER_MATCHED_COLUMNS = 0;
    private final int PRIME_ZEROS = 1;
    private final int AUGMENT_PATH = 2;
    private final int ADD_SUB_MIN_VALUE = 3;
    
    int rp;
    int cp;
    
    java.util.List<Integer> pathRow;
    java.util.List<Integer> pathColumn;
    
    private int nextStep = COVER_MATCHED_COLUMNS;

    /** 
     * Implementation of the Munkres (Hungarian) algorithm: based on the description at:
     * http://csclab.murraystate.edu/bob.pilgrim/445/munkres.html
     */
    public MunkresProblem(T[][] initialCost) {
        n = initialCost.length;
        m = initialCost[0].length;
        k = n < m ? n : m;
        cost = initialCost.clone();
        rowCover = new boolean[n];
        columnCover = new boolean[m];
        starred = new boolean[n][m];
        primed = new boolean[n][m]; 
        
        for (int i = 0; i < n; i++) {
            cost[i] = initialCost[i].clone();
            for (int j = 0; j < m; j++) {
                starred[i][j] = false;
                primed[i][j] = false;
                cost[i][j] = initialCost[i][j].copy();
            }
        }
        for (int i = 0; i < n; i++) {
            rowCover[i] = false;
        }
        for (int j = 0; j < m; j++) {
            columnCover[j] = false;
        }
    }
    
    public int[][] solve() {
        minimizeRows();
//        System.out.println(this);
        
        match();
//        System.out.println(this);
        
        nextStep = COVER_MATCHED_COLUMNS;
        
        boolean done = false;
        while (!done) {
            
            switch (nextStep) {
                case COVER_MATCHED_COLUMNS:
//                    System.out.println("Step: COVER_MATCHED_COLUMNS");
                    int nbrMatchedColumns = coverMatchedColumns();
//                    System.out.println(this);
                    if (nbrMatchedColumns == k) {
                        done = true;
                    }
                    break;
                case PRIME_ZEROS:
//                    System.out.println("Step: PRIME_ZEROS");
                    primeZeros();
//                    System.out.println(this);
                    break;
                case AUGMENT_PATH:
//                    System.out.println("Step: AUGMENT_PATH");
                    augmentPath(rp, cp);
//                    System.out.println(this);
                    break;
                case ADD_SUB_MIN_VALUE:
//                    System.out.println("Step: ADD_SUB_MIN_VALUE");
                    addSubMinValue();
//                    System.out.println(this);
                    break;
                default:
                    done = true;
                    break;
            }
        }
        
        int[][] result = new int[k][2];
        int ind = 0;
        for (int i = 0; i < n; i++) {
            for (int j = 0; j < m; j++) {
                if (starred[i][j]) {
                    result[ind][0] = i;
                    result[ind][1] = j;
                    ind++;
                }
            }
        }
        return result;
    }
    
    public void minimizeRows() {
        for (int i = 0; i < n; i++) {
            T row_min = null;
            for (int j = 0; j < m; j++)
                if (row_min == null || cost[i][j].compareTo(row_min) < 0)
                    row_min = cost[i][j];
            for (int j = 0; j < m; j++)
                if (cost[i][j] != row_min)
                    cost[i][j].subtract(row_min);
            row_min.subtract(row_min);
        }
    }
    
    public void match() {
        // Greedy matching: Hopcorft Karp would be better
        for (int i = 0; i < n; i++) {
            for (int j = 0; j < m; j++) {
                if (cost[i][j].isZero() && !rowCover[i] && !columnCover[j]) {
                    starred[i][j] = true;
                    rowCover[i] = true;
                    columnCover[j] = true;
                }
            }
        }       
        resetCovers();
    }
    
    public int coverMatchedColumns() {
        int nStarred = 0;
        for (int j = 0; j < m; j++) {
            if (columnContainsStarred(j)) {
                columnCover[j] = true;
                nStarred++;
            }
        }
        nextStep = PRIME_ZEROS;
        return nStarred;
    }
    
    public void primeZeros() {
        boolean done = false;
        while (!done) {
            findUncoveredZero();
            if (rp==-1) {
                break;
            }
            primed[rp][cp] = true;
            if (!rowContainsStarred(rp)) {
                nextStep = AUGMENT_PATH;
                return; 
            } else {
                int si = starIndexInRow(rp);
                rowCover[rp] = true;
                columnCover[si] = false;
            }
        }
        nextStep = ADD_SUB_MIN_VALUE;
        rp = -1;
        cp = -1;
        return;
    }
    
    public void augmentPath(int primedRow, int primedCol) {
        pathRow = new ArrayList<Integer>();
        pathColumn = new ArrayList<Integer>();
        pathRow.add(new Integer(primedRow));
        pathColumn.add(new Integer(primedCol));
        boolean done = false;
        while (!done) {
            int rs = starIndexInColumn(pathColumn.get(pathColumn.size()-1).intValue());
            if (rs>=0) {
                pathRow.add(new Integer(rs));
                pathColumn.add(new Integer(pathColumn.get(pathColumn.size()-1).intValue()));
            } else {
                break;
            }
            int cp = primedIndexInRow(pathRow.get(pathRow.size()-1).intValue());
            pathRow.add(new Integer(pathRow.get(pathRow.size()-1).intValue()));
            pathColumn.add(new Integer(cp));
        }
        // Flip stars
        for (int k = 0; k < pathColumn.size(); k++) {
            if (starred[pathRow.get(k).intValue()][pathColumn.get(k).intValue()]) {
                starred[pathRow.get(k).intValue()][pathColumn.get(k).intValue()] = false;
            } else {
                starred[pathRow.get(k).intValue()][pathColumn.get(k).intValue()] = true;
            }
        }
        resetCovers();
        resetPrimed();
        nextStep = COVER_MATCHED_COLUMNS;
    }
    
    public void addSubMinValue() {
        T minValue = findMinUncoveredValue();
        for (int i = 0; i < n; i++) {
            for (int j = 0; j < m; j++) {
                if (rowCover[i]) {
                    cost[i][j].add(minValue);
                }
                if (!columnCover[j]) {
                    cost[i][j].subtract(minValue);
                }
            }
        }
        nextStep = PRIME_ZEROS;
    }
    
    public void findUncoveredZero() {
        for (int j = 0; j < m; j++) {
            if (!columnCover[j]) {
                for (int i = 0; i < n; i++) {
                    if (!rowCover[i]) {
                        if (cost[i][j].isZero()) {
                            rp = i;
                            cp = j;
                            return;
                        }
                    }
                }
            }
        }
        rp = -1;
        cp  =-1;
        return;
    }
    
    public T findMinUncoveredValue() {
        T minValue = null;
        for (int j = 0; j < m; j++)
            if (!columnCover[j])
                for (int i = 0; i < n; i++)
                    if (!rowCover[i] && (minValue == null || cost[i][j].compareTo(minValue) < 0))
                        minValue = cost[i][j];
        return minValue.copy();
    }
    
    public boolean rowContainsStarred(int row) {
        for (int j = 0; j < m; j++)
            if (starred[row][j])
                return true;
        return false;
    }

    public boolean rowContainsPrimed(int row) {
        for (int j = 0; j < m; j++)
            if (primed[row][j])
                return true;
        return false;
    }

    public boolean columnContainsStarred(int col) {
        for (int i = 0; i < n; i++)
            if (starred[i][col])
                return true;
        return false;
    }

    public boolean columnContainsPrimed(int col) {
        for (int i = 0; i < n; i++)
            if (primed[i][col])
                return true;
        return false;
    }
    
    public int starIndexInRow(int row) {
        for (int j = 0; j < m; j++)
            if (starred[row][j])
                return j;
        return -1;
    }

    public int starIndexInColumn(int col) {
        for (int i = 0; i < n; i++)
            if (starred[i][col])
                return i;
        return -1;  
    }

    public int primedIndexInRow(int row) {
        for (int j = 0; j < m; j++)
            if (primed[row][j])
                return j;
        return -1;
    }
    
    public void resetCovers() {
        for (int i = 0; i < n; i++)
            rowCover[i] = false;
        for (int j = 0; j < m; j++)
            columnCover[j] = false;
    }

    public void resetStarred() {
        for (int i = 0; i < n; i++)
            for (int j = 0; j < m; j++)
                starred[i][j] = false;
    }

    public void resetPrimed() {
        for (int i = 0; i < n; i++)
            for (int j = 0; j < m; j++)
                primed[i][j] = false;
    }
    
    public String toString() {
        StringBuffer str = new StringBuffer();
        for (int j = 0; j < m; j++) {
            if (columnCover[j])
                str.append(String.format("%8s", "x"));
            else
                str.append(String.format("%8s", " "));
        }
        str.append("\n");
        for (int i = 0; i < n; i++) {
            if (rowCover[i])
                str.append("x");
            else
                str.append(" ");
            for (int j = 0; j < m; j++) {
                str.append(String.format("%6s", cost[i][j]));
                if (starred[i][j])
                    str.append("*");
                else
                    str.append(" ");
                if (primed[i][j])
                    str.append("'");
                else
                    str.append(" ");
            }
            str.append("\n");
        }
        return str.toString();
    }
    
}
