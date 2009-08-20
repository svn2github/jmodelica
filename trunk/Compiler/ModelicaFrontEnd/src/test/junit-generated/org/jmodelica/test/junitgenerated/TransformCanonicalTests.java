package org.jmodelica.test.junitgenerated;

import org.junit.*;
import static org.junit.Assert.*;
import org.jmodelica.modelica.compiler.*;

public class TransformCanonicalTests {

  static TestSuite ts;

  @BeforeClass public static void setUp() {
    ts = new TestSuite("src/test/modelica/TransformCanonicalTests.mo","TransformCanonicalTests");
  }

  @Test public void TransformCanonicalTest1() {
    assertTrue(ts.get(0).testMe());
  }

  @Test public void TransformCanonicalTest2() {
    assertTrue(ts.get(1).testMe());
  }

  @Test public void TransformCanonical3_Err() {
    assertTrue(ts.get(2).testMe());
  }

  @Test public void TransformCanonical4_Err() {
    assertTrue(ts.get(3).testMe());
  }

  @Test public void TransformCanonicalTest5() {
    assertTrue(ts.get(4).testMe());
  }

  @Test public void TransformCanonicalTest6() {
    assertTrue(ts.get(5).testMe());
  }

  @Test public void EvalTest1() {
    assertTrue(ts.get(6).testMe());
  }

  @Test public void LinearityTest1() {
    assertTrue(ts.get(7).testMe());
  }

  @Test public void AliasTest1() {
    assertTrue(ts.get(8).testMe());
  }

  @Test public void AliasTest2() {
    assertTrue(ts.get(9).testMe());
  }

  @Test public void AliasTest3() {
    assertTrue(ts.get(10).testMe());
  }

  @Test public void AliasTest4() {
    assertTrue(ts.get(11).testMe());
  }

  @Test public void AliasTest5() {
    assertTrue(ts.get(12).testMe());
  }

  @Test public void AliasTest6() {
    assertTrue(ts.get(13).testMe());
  }

  @Test public void AliasTest7() {
    assertTrue(ts.get(14).testMe());
  }

  @Test public void AliasTest8() {
    assertTrue(ts.get(15).testMe());
  }

  @Test public void AliasTest9() {
    assertTrue(ts.get(16).testMe());
  }

  @Test public void AliasTest10() {
    assertTrue(ts.get(17).testMe());
  }

  @Test public void AliasTest11() {
    assertTrue(ts.get(18).testMe());
  }

  @Test public void AliasTest12() {
    assertTrue(ts.get(19).testMe());
  }

  @Test public void AliasTest13() {
    assertTrue(ts.get(20).testMe());
  }

  @Test public void AliasTest14() {
    assertTrue(ts.get(21).testMe());
  }

  @Test public void AliasTest15() {
    assertTrue(ts.get(22).testMe());
  }

  @Test public void AliasTest16_Err() {
    assertTrue(ts.get(23).testMe());
  }

  @Test public void AliasTest17_Err() {
    assertTrue(ts.get(24).testMe());
  }

  @Test public void AliasTest18_Err() {
    assertTrue(ts.get(25).testMe());
  }

  @Test public void AliasTest19_Err() {
    assertTrue(ts.get(26).testMe());
  }

  @Test public void ParameterBindingExpTest1_Err() {
    assertTrue(ts.get(27).testMe());
  }

  @Test public void ParameterBindingExpTest2_Err() {
    assertTrue(ts.get(28).testMe());
  }

  @AfterClass public static void tearDown() {
    ts = null;
  }

}

