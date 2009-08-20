package org.jmodelica.test.junitgenerated;

import org.junit.*;
import static org.junit.Assert.*;
import org.jmodelica.modelica.compiler.*;

public class ConnectTests {

  static TestSuite ts;

  @BeforeClass public static void setUp() {
    ts = new TestSuite("src/test/modelica/ConnectTests.mo","ConnectTests");
  }

  @Test public void ConnectTest2_Err() {
    assertTrue(ts.get(0).testMe());
  }

  @Test public void ConnectTest3() {
    assertTrue(ts.get(1).testMe());
  }

  @Test public void CircuitTest1() {
    assertTrue(ts.get(2).testMe());
  }

  @Test public void CircuitTest2() {
    assertTrue(ts.get(3).testMe());
  }

  @Test public void ConnectorTest() {
    assertTrue(ts.get(4).testMe());
  }

  @AfterClass public static void tearDown() {
    ts = null;
  }

}

