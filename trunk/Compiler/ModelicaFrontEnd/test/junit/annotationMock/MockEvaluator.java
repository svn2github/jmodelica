package annotationMock;

import org.jmodelica.modelica.compiler.CValueInteger;
import org.jmodelica.modelica.compiler.SrcExp;
import org.jmodelica.util.values.ConstValue;
import org.jmodelica.util.values.Evaluator;

public class MockEvaluator extends SrcExp implements Evaluator<SrcExp> {

    @Override
    public ConstValue evaluate(SrcExp t) {
        if (t==null)
            return null;
        return new CValueInteger(1);
    }

    @Override
    public SrcExp fullCopy() {
        // TODO Auto-generated method stub
        return null;
    }

    @Override
    public SrcExp treeCopyNoTransform() {
        // TODO Auto-generated method stub
        return null;
    }

    @Override
    public SrcExp treeCopy() {
        // TODO Auto-generated method stub
        return null;
    }

}
