package annotationMock;

import org.jmodelica.util.values.ConstValue;
import org.jmodelica.util.values.Evaluable;
import org.jmodelica.util.values.Evaluator;

public class DummyEvaluator implements Evaluator<DummyEvaluator>, Cloneable,Evaluable {

    DummyCValueInteger myValue;
    public DummyEvaluator(String value) {
        // TODO Auto-generated constructor stub
        myValue = new DummyCValueInteger(Integer.parseInt(value));
    }

    @Override
    public ConstValue evaluateValue() {
        // TODO Auto-generated method stub
        return null;
    }

    @Override
    public ConstValue evaluate(DummyEvaluator t) {
        if (t==null)
            return null;
        return new DummyCValueInteger(1);
    }
    
    public class DummyCValueInteger extends ConstValue{
        int t;
        public DummyCValueInteger(int i) {
           t=i;
        }

        public int intValue() { 
            return t; 
        }
        
        public String stringValue() { 
            return String.valueOf(t); 
        }
        
        public boolean isInteger() {
            return true;
        }

        
    }
    
    public String toString() {
        return myValue.stringValue();
    }

}
