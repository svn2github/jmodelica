package org.jmodelica.test.junitgenerated;

import org.junit.*;
import static org.junit.Assert.*;
import org.jmodelica.modelica.compiler.*;

public class CodeGenTests {

  static TestSuite ts;

  @BeforeClass public static void setUp() {
    ts = new TestSuite("src/test/modelica/CodeGenTests.mo","CodeGenTests");
  }

  @Test public void CodeGenTest1() {
    assertTrue(ts.get(0).testMe());
  }

  @Test public void CodeGenTest2() {
    assertTrue(ts.get(1).testMe());
  }

  @AfterClass public static void tearDown() {
    ts = null;
  }

}

