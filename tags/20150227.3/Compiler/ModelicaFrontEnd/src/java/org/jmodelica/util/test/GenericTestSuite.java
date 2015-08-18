package org.jmodelica.util.test;

import java.util.List;

public interface GenericTestSuite {

    public List<? extends GenericTestCase> getAll();

}
