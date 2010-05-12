/*
    Copyright (C) 2009 Modelon AB

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, version 3 of the License.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/


package RedeclareTests


model RedeclareTestOx1 "Basic redeclare test"
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.FlatteningTestCase(name="RedeclareTestOx1",
                                               description="Basic redeclares.",
                                               flatModel=
"fclass RedeclareTests.RedeclareTestOx1
 Real c.a.x = 2 /*(2)*/;
 Real c.a.y = 3 /*(3)*/;
end RedeclareTests.RedeclareTestOx1;
")})));
 
 // This is perfectly ok.
 
  model A
    Real x=1;
  end A;
 
  model B
   Real x=2;
   Real y=3;
  end B;
 
   model C
     replaceable A a;
   end C;
 
   C c(redeclare B a);
 
end RedeclareTestOx1;
 
model RedeclareTestOx2_Err "Basic redeclare test, errounous"
 
      annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.ErrorTestCase(name="RedeclareTestOx2_Err",
        description="Test basic redeclares. Error caused by failed subtype test in component redeclaration.",
                                               errorMessage=
"
1 error(s) found...
In file 'src/test/modelica/RedeclareTests.mo':
Semantic error at line 71, column 8:
  'redeclare A b' is not a subtype of 'replaceable B b'

  "
  )})));
 
/*
  Should give an error message like
  Error in redeclaration in component:
    C c(redeclare A b)
   component 'A b' is not a subtype of component 'B a'.
   
   
   
 
*/
 
  model A
    Real x=1;
  end A;
 
  model B
   Real x=2;
   Real y=3;
  end B;
 
   model C
     replaceable B b;
   end C;
   // Here is the error
   C c(redeclare A b);
 
end RedeclareTestOx2_Err;
 
model RedeclareTestOx3 "Redeclare deeper into instance hierarchy."

  annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.FlatteningTestCase(name="RedeclareTestOx3",
        description="Basic test of redeclares.",
                                               flatModel=
"fclass RedeclareTests.RedeclareTestOx3
 Real d.c.a.x = 2 /*(2)*/;
 Real d.c.a.y = 3 /*(3)*/;
end RedeclareTests.RedeclareTestOx3;
")})));


 
  // Perfectly ok.
 
  model A
    Real x=1;
  end A;
 
  model B
   Real x=2;
   Real y=3;
  end B;
 
   model C
     replaceable A a;
   end C;
 
   model D
     C c;
   end D;
 
   D d(c(redeclare B a));
 
end RedeclareTestOx3;
 
model RedeclareTestOx4_Err 
    "Redeclare deeper into instance hierarchy."
 
  
      annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.ErrorTestCase(name="RedeclareTestOx4_Err",
        description="Test basic redeclares. Error caused by failed subtype test in component redeclaration.",
                                               errorMessage=
"
1 error(s) found...
In file 'src/test/modelica/RedeclareTests.mo':
Semantic error at line 159, column 10:
  'redeclare A b' is not a subtype of 'replaceable B b'

  "
  )})));
 
/*
  Should give an error message like
  Error in redeclaration in component:
    D d(c(redeclare A b)) in class RedeclareTestOx4_Err
   component 'A b' is not a subtype of component 'B b'.
   Original declaration located in class C. 
   Instance name of original declaration: d.c.b   
 
 
 
*/
 
  model A
    Real x=1;
  end A;
 
  model B
   Real x=2;
   Real y=3;
  end B;
 
   model C
     replaceable B b;
   end C;
 
   model D
     C c;
   end D;
 
   D d(c(redeclare A b));
 
end RedeclareTestOx4_Err;
 
model RedeclareTestOx5 
    "Redeclare deeper into instance hierarchy and redeclaration of a replacing component."
 
  annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.FlatteningTestCase(name="RedeclareTestOx5",
        description="Basic test of redeclares.",
                                               flatModel=
"fclass RedeclareTests.RedeclareTestOx5
 Real e.d.a.x = 2 /*(2)*/;
 Real e.d.a.y = 3 /*(3)*/;
 Real e.d.a.z = 4 /*(4)*/;
end RedeclareTests.RedeclareTestOx5;
")})));
 
 
  model A
    Real x=1;
  end A;
 
  model B
   Real x=2;
   Real y=3;
  end B;
 
  model C
   Real x=2;
   Real y=3;
   Real z=4;
  end C;
 
   model D
     replaceable A a;
   end D;
 
   model E
     D d(redeclare B a);
   end E;
 
   E e(d(redeclare C a));
 
end RedeclareTestOx5;
 
model RedeclareTestOx6_Err 
    "Redeclare deeper into instance hierarchy and redeclaration of a replacing component, Errouneous?"
 
  
/*
  This test case test tests lookup in a redeclared component and is currently
  not supported.   
 
*/
 
  model A
    Real x=1;
  end A;
 
  model B
   Real x=2;
   Real y=3;
  end B;
 
  model C
   Real x=2;
   Real y=3;
   Real z=4;
  end C;
 
   model D
     replaceable A a;
   end D;
 
   model E
     D d(redeclare replaceable C a);
     Real q = d.a.z; // This should not be ok since the constraining class of component a is A.
   end E;
 
   E e(d(redeclare B a)); // This redeclaration should be ok since B is a subtype of A!
 
end RedeclareTestOx6_Err;
 
 model RedeclareTestOx65_Err 
    "Redeclare deeper into instance hierarchy and redeclaration of a replacing component, Errouneous?"
 
 
      annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.ErrorTestCase(name="RedeclareTestOx65_Err",
        description="Test basic redeclares. Error caused by failed subtype test in component redeclaration.",
                                               errorMessage=
"
1 error(s) found...
In file 'src/test/modelica/RedeclareTests.mo':
Semantic error at line 276, column 10:
  'redeclare replaceable A a' is not a subtype of 'replaceable B a'

  "
  )})));
 
/*
  Should give an error message like
   
 
*/
 
  model A
    Real x=1;
  end A;
 
  model B
   Real x=2;
   Real y=3;
  end B;
 
  model C
   Real x=2;
   Real y=3;
   Real z=4;
  end C;
 
   model D
     replaceable B a;
   end D;
 
   model E
     D d(redeclare replaceable A a);
   end E;
 
   E e(d(redeclare C a)); 
 
end RedeclareTestOx65_Err;
 
 
model RedeclareTestOx7_Err 
    "Redeclare deeper into instance hierarchy and redeclaration of a replacing component, Errouneous?"
  // This is based on replaceable types and is not tested here.
 
  model A
    Real x=1;
  end A;
 
  model B
   Real x=2;
   Real y=3;
  end B;
 
  model C
   Real x=2;
   Real y=3;
   Real z=4;
  end C;
 
   model D
     replaceable model AA = A;
     AA a;
   end D;
 
   model E
     D d(redeclare replaceable model AA=C);
     Real q = d.a.z; // This should not be ok!
   end E;
 
   E e(d(redeclare model AA=B)); // This redeclaration should be ok since B is a subtype of A!
 
end RedeclareTestOx7_Err;
 
model RedeclareTestOx8 "Constraining clause example"
 
   annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.FlatteningTestCase(name="RedeclareTestOx8",
        description="Basic test of redeclares.",
                                               flatModel=
"fclass RedeclareTests.RedeclareTestOx8
 Real d.c.x = 2 /*(2)*/;
 Real d.c.y = 3 /*(3)*/;
end RedeclareTests.RedeclareTestOx8;
")})));
 
 
  model A
    Real x=1;
  end A;
 
  model B
   Real x=2;
   Real y=3;
  end B;
 
  model C
   Real x=2;
   Real y=3;
   Real z=4;
  end C;
 
   model D
     replaceable C c constrainedby B;
   end D;
   // Ok, since the constraining clause of C c is B.
   D d(redeclare B c);
 
end RedeclareTestOx8;
 
model RedeclareTestOx9_Err "Constraining clause example, errouneous"
 
 
      annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.ErrorTestCase(name="RedeclareTestOx9_Err",
        description="Test basic redeclares. Error caused by failed subtype test in component redeclaration.",
                                               errorMessage=
"1 error(s) found...
In file 'src/test/modelica/RedeclareTests.mo':
Semantic error at line 399, column 8:
  'redeclare A c' is not a subtype of 'replaceable C c constrainedby B '

  "
  )})));
 
 
 
 
 /*
  Should give an error message like
  Error in redeclaration in component:
   D d(redeclare A c); in class RedeclareTestOx9_Err
   component 'A c' is not a subtype of constraining type B.
   Redeclared declaration located in class D.
   replaceable C c constrainedby B;
   Instance name of redeclared original declaration: d.c   
   TODO: the check is correct, but the error message is not correct.
*/
 
  model A
    Real x=1;
  end A;
 
  model B
   Real x=2;
   Real y=3;
  end B;
 
  model C
   Real x=2;
   Real y=3;
   Real z=4;
  end C;
 
   model D
     replaceable C c constrainedby B;
   end D;
 
   D d(redeclare A c);
 
end RedeclareTestOx9_Err;

model RedeclareTestOx95_Err "Constraining clause example, errouneous"
 
      annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.ErrorTestCase(name="RedeclareTestOx95_Err",
        description="Check that the declaration is a subtype of the constraining clause",
                                               errorMessage=
"1 error(s) found...
In file 'src/test/modelica/RedeclareTests.mo':
Semantic error at line 450, column 10:
  In the declaration 'replaceable B b constrainedby C ', the declared class is not a subtype of the constraining class
"
  )})));
 
 
 
 
  model A
    Real x=1;
  end A;
 
  model B
   Real x=2;
   Real y=3;
  end B;
 
  model C
   Real x=2;
   Real y=3;
   Real z=4;
  end C;
 
   model D
     replaceable B b constrainedby C;
   end D;
 
   D d;
 
end RedeclareTestOx95_Err;
 /*
model RedeclareTestOx10 "Constraining clause example."
 
    annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.FlatteningTestCase(name="RedeclareTestOx10",
        description="Basic test of redeclares.",
                                               flatModel=
"fclass RedeclareTests.RedeclareTestOx10
 Real e.d.c.x = 2;
 Real e.d.c.y = 3;
end RedeclareTests.RedeclareTestOx10;
")})));
 
 
 
  model A
    Real x=1;
  end A;
 
  model B
   Real x=2;
   Real y=3;
  end B;
 
  model C
   Real x=2;
   Real y=3;
   Real z=4;
  end C;
 
   model D
     replaceable B c constrainedby B;
   end D;
 
   model E
     // This is actually ok since the replacing component does not have an
     // explicit constraining clause, in which case the constraining clause
     // of the original declaration is used.
     replaceable D d constrainedby D(redeclare replaceable C c);
   end E;
 
   E e(redeclare D d(redeclare B c));
 
end RedeclareTestOx10;
 */
/*
model RedeclareTestOx11_Err "Constraining clause example."
      annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.ErrorTestCase(name="RedeclareTestOx11_Err",
        description="Check that the declaration is a subtype of the constraining clause",
                                               errorMessage=
"
  2 error(s) found...
In file 'src/test/modelica/RedeclareTests.mo':
Semantic error at line 549, column 32:
  'redeclare replaceable B c constrainedby A ' is not a subtype of 'replaceable B c'
Semantic error at line 553, column 32:
  'redeclare A c' is not a subtype of 'replaceable B c'

  "
  )})));

//  Should give an error message like
//  Error in redeclaration in component:
//   D d(redeclare A c); in class RedeclareTestOx9_Err
//   component 'A c' is not a subtype of constraining type B.
//   Redeclared declaration located in class D.
//   replaceable C c constrainedby B;
//   Instance name of redeclared original declaration: d.c   
 
  model A
    Real x=1;
  end A;
 
  model B
   Real x=2;
   Real y=3;
  end B;
 
  model C
   Real x=2;
   Real y=3;
   Real z=4;
  end C;
 
   model D
     replaceable B c;
   end D;
 
   model E
     // This is an error
     replaceable D d constrainedby D(redeclare replaceable B c constrainedby A);
   end E;
   
   // This is another error
   E e(redeclare D d(redeclare A c));
 
end RedeclareTestOx11_Err;
 */

 model RedeclareTestOx115_Err "Constraining clause example."
      annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.ErrorTestCase(name="RedeclareTestOx115_Err",
        description="Check that the declaration is a subtype of the constraining clause",
                                               errorMessage=
"1 error(s) found...
In file 'src/test/modelica/RedeclareTests.mo':
Semantic error at line 601, column 69:
  In the declaration 'redeclare replaceable B c constrainedby C ', the declared class is not a subtype of the constraining class
"
  )})));
/*
  Should give an error message like
  In file 'src/test/modelica/RedeclareTests.mo':
Semantic error at line 431, column 32:
  'B' is not a subtype of 'C'
*/
 
  model A
    Real x=1;
  end A;
 
  model B
   Real x=2;
   Real y=3;
  end B;
 
  model C
   Real x=2;
   Real y=3;
   Real z=4;
  end C;
 
   model D
     replaceable B c;
   end D;
 
   model E
     replaceable D d(redeclare replaceable C c constrainedby C) constrainedby D(redeclare replaceable B c constrainedby C);
   end E;
  
 
   E e;
 
end RedeclareTestOx115_Err;

 model RedeclareTestOx116_Err "Constraining clause example."
      annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.ErrorTestCase(name="RedeclareTestOx116_Err",
        description="Check that the declaration is a subtype of the constraining clause",
                                               errorMessage=
"1 error(s) found...
In file 'src/test/modelica/RedeclareTests.mo':
Semantic error at line 651, column 32:
  'redeclare replaceable C c constrainedby A ' is not a subtype of 'replaceable B c'
"
  )})));
/*
  Should give an error message like
  In file 'src\test\modelica\RedeclareTests.mo':
Semantic error at line 470, column 58:
  'A' is not a subtype of 'B'
  
 
 
 */
 
  model A
    Real x=1;
  end A;
 
  model B
   Real x=2;
   Real y=3;
  end B;
 
  model C
   Real x=2;
   Real y=3;
   Real z=4;
  end C;
 
   model D
     replaceable B c;
   end D;
 
   model E 
     // This is an error because the constraining clause of C c constrainedby A is not a subtype of B c
     replaceable D d constrainedby D(redeclare replaceable C c constrainedby A);
   end E;
  
 
   E e;
 
end RedeclareTestOx116_Err;
 /*
model RedeclareTestOx12 "Constraining clause example."
 
      annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.FlatteningTestCase(name="RedeclareTestOx12",
        description="Check that the declaration is a subtype of the constraining clause",
                                               flatModel=
"fclass RedeclareTests.RedeclareTestOx12
 Real d.c.x = 5;
end RedeclareTests.RedeclareTestOx12;
"
  )})));
  
  model A
    Real x=1;
  end A;
 
  model B
   Real x=2;
   Real y=3;
  end B;
 
   model D
     //Here the modifiers (x=3,y=3) are not used when the component is redeclared.
     replaceable B c(x=3,y=5) constrainedby A(x=5);
   end D;
 
   D d(redeclare A c);
 
end RedeclareTestOx12;
*/ 
model RedeclareTestOx13 "Constraining clause example."
 
      annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.FlatteningTestCase(name="RedeclareTestOx13",
        description="Check that the declaration is a subtype of the constraining clause",
                                               flatModel=
"fclass RedeclareTests.RedeclareTestOx13
 Real e.d.c.x = 4 /*(4)*/;
 Real e.d.c.y = 3 /*(3)*/;
 Real e.d.c.z = 5 /*(5)*/;
end RedeclareTests.RedeclareTestOx13;
"
  )})));
  
  model A
    Real x=1;
  end A;
 
  model B
   Real x=2;
   Real y=3;
  end B;
 
  model C
   Real x=2;
   Real y=3;
   Real z=4;
  end C;
 
   model D
     replaceable A c;
   end D;
 
   model E
     D d( redeclare replaceable B c(y=10) constrainedby A(x=4));
   end E;
 
   E e(d(redeclare C c(z=5)));
 
end RedeclareTestOx13;


model RedeclareTest_Constr_14_Err "Constraining clause example."
 
 
      annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.ErrorTestCase(name="RedeclareTest_Constr_14_Err",
        description="Check that the declaration is a subtype of the constraining clause",
                                               errorMessage=
"1 error(s) found...
In file 'src/test/modelica/RedeclareTests.mo':
Semantic error at line 752, column 10:
  In the declaration 'redeclare replaceable B c constrainedby C ', the declared class is not a subtype of the constraining class
"
  )})));
  
  
  model A
    Real x=1;
  end A;
 
  model B
   Real x=2;
   Real y=3;
  end B;
 
  model C
   Real x=2;
   Real y=3;
   Real z=4;
  end C;
 
   model D
     replaceable A c;
   end D;
 
   model E
     // Here is the error: A is not a subtype of C
     D d(redeclare replaceable B c constrainedby C);
   end E;
 
   E e(d(redeclare C c));
 
end RedeclareTest_Constr_14_Err;

model RedeclareTest_Constr_15_Err "Constraining clause example."
 
      annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.ErrorTestCase(name="RedeclareTest_Constr_15_Err",
        description="Check that the declaration is a subtype of the constraining clause",
                                               errorMessage=
"1 error(s) found...
In file 'src/test/modelica/RedeclareTests.mo':
Semantic error at line 790, column 10:
  In the declaration 'redeclare replaceable B c constrainedby C ', the declared class is not a subtype of the constraining class
"
  )})));
  
  model A
    Real x=1;
  end A;
 
  model B
   Real x=2;
   Real y=3;
  end B;
 
  model C
   Real x=2;
   Real y=3;
   Real z=4;
  end C;
 
   model D
     replaceable A c;
   end D;
 
   model E
     // Here is the error: B is not a subtype of C
     D d(redeclare replaceable B c constrainedby C);
   end E;
 
   E e(d(redeclare replaceable C c));
 
end RedeclareTest_Constr_15_Err;

model RedeclareTest_Constr_16_Err "Constraining clause example."
 
      annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.ErrorTestCase(name="RedeclareTest_Constr_16_Err",
        description="Check that the declaration is a subtype of the constraining clause",
                                               errorMessage=
"1 error(s) found...
In file 'src/test/modelica/RedeclareTests.mo':
Semantic error at line 837, column 10:
  'redeclare replaceable A c' is not a subtype of 'redeclare replaceable B c constrainedby B '
"
  )})));
  
  model A
    Real x=1;
  end A;
 
  model B
   Real x=2;
   Real y=3;
  end B;
 
  model C
   Real x=2;
   Real y=3;
   Real z=4;
  end C;
 
   model D
     replaceable A c;
   end D;
 
   model E
     // Here is the error: B is not a subtype of C
     D d(redeclare replaceable B c constrainedby B);
   end E;
 
   E e(d(redeclare replaceable A c));
 
end RedeclareTest_Constr_16_Err;

model RedeclareTest_Constr_17_Err "Constraining clause example."
 
      annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.ErrorTestCase(name="RedeclareTest_Constr_17_Err",
        description="Check that the declaration is a subtype of the constraining clause",
                                               errorMessage=
"1 error(s) found...
In file 'src/test/modelica/RedeclareTests.mo':
Semantic error at line 884, column 34:
  'redeclare replaceable B c' is not a subtype of 'redeclare replaceable C c constrainedby C '
"
  )})));
  
  model A
    Real x=1;
  end A;
 
  model B
   Real x=2;
   Real y=3;
  end B;
 
  model C
   Real x=2;
   Real y=3;
   Real z=4;
  end C;
 
   model D
     replaceable A c;
   end D;
 
   model E
     // Here is the error: B is not a subtype of C
     replaceable D d(redeclare replaceable B c constrainedby B);
   end E;
 
   E e(redeclare replaceable D d(redeclare replaceable B c) constrainedby D(redeclare replaceable C c constrainedby C));
 
end RedeclareTest_Constr_17_Err;

model RedeclareTest_Constr_18_Err "Constraining clause example."
 
      annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.ErrorTestCase(name="RedeclareTest_Constr_18_Err",
        description="Check that the declaration is a subtype of the constraining clause",
                                               errorMessage=
"1 error(s) found...
In file 'src/test/modelica/RedeclareTests.mo':
Semantic error at line 918, column 32:
  'redeclare replaceable B c' is not a subtype of 'replaceable C c constrainedby C '
"
  )})));
  
  model A
    Real x=1;
  end A;
 
  model B
   Real x=2;
   Real y=3;
  end B;
 
  model C
   Real x=2;
   Real y=3;
   Real z=4;
  end C;
 
   model D
     replaceable C c constrainedby C;
   end D;
 
   model E
     // Notice that the modifier in the constraining clause is applied to the declaration itself
     // and is therefore type checked.
     replaceable D d constrainedby D(redeclare replaceable B c);
   end E;
 
   E e;
 
end RedeclareTest_Constr_18_Err;

model RedeclareTest_Classes_1 "Redeclaration of classes example."
 
      annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.FlatteningTestCase(name="RedeclareTest_Classes_1",
        description="Test of parametrized classes.",
                                               flatModel=
"fclass RedeclareTests.RedeclareTest_Classes_1
 Real e.d.a.x = 4 /*(4)*/;
 Real e.d.a.y = 3 /*(3)*/;
 Real e.d.a.z = 4 /*(4)*/;
end RedeclareTests.RedeclareTest_Classes_1;
"
  )})));
 
 
 
  model A
    Real x=1;
  end A;
 
  model B
   Real x=2;
   Real y=3;
  end B;
 
  model C
   Real x=2;
   Real y=3;
   Real z=4;
  end C;
 
   model D
   
     replaceable model myA = A;
     myA a(x=4);
   end D;
 
   model E
   
   
      D d(redeclare replaceable model myA = C);
   end E;
 
   E e;
 
end RedeclareTest_Classes_1;


model RedeclareTestOx6b_Err
 model A
    Real x=1;
 end A;
 
  model B
   Real x=2;
   Real y=3;
  end B;
 
   model D
     replaceable A a;
   end D;
 
   model E
     D d(redeclare replaceable B a constrainedby B);
     Real q = d.a.y; // This access should not be ok since y is not part of
                     // the constraining interface of the replacing
                     // component B b. The constraining interface of the
                     // replacing component B b is rather defined by the
                     // original declaration A a.
   end E;
 
   // This is a perfectly legal redeclare, since the constraining class of 
   // the replacing declaration B a is A a
   E e(d(redeclare A a));
 
end RedeclareTestOx6b_Err;


model RedeclareTest0
  model A
    Real x;
  end A;
  
  model B
   Real x;
   Real y;
  end B;
  
  model B2
   Real x;
   Real y;
   Real z;
  end B2;

  
   model C
     replaceable A a;
   end C;
   
   model D
     C c(redeclare B a);
   end D;
   
   D d(c(redeclare B2 a));
   
 

end RedeclareTest0;



model RedeclareTest1
  
     annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.FlatteningTestCase(name="RedeclareTest1",
                                               description="Basic redeclares.",
                                               flatModel=
"
 fclass RedeclareTests.RedeclareTest1
 Real a.c2.x = 3 /*(3)*/;
 Real a.c2.y = 4 /*(4)*/;
 Real b.a.c2.x = 5 /*(5)*/;
 Real b.a.c2.y = 4 /*(4)*/;
 Real b.a.c2.z = 9 /*(9)*/;
 Real b.aa.c2.x = 2 /*(2)*/;
end RedeclareTests.RedeclareTest1;
")})));

  
  model C2
    Real x=2;
  end C2;
  
  model C22
    Real x=3;
    Real y=4;
  end C22;
  
  model C222
    Real x=5;
    Real y=6;
    Real z=7;
  end C222;
  
  model A
    replaceable C2 c2;
  end A;
  
  model B
    // Notice that the modifier 'x=8' is not merged since
    // it redeclared and since there is no constraining clause  
    A a(redeclare replaceable C22 c2(x=8));
    A aa;
  end B;
  
  A a(redeclare C22 c2);
  B b(a(redeclare C222 c2(z=9,y=4)));
end RedeclareTest1;


model RedeclareTest2
  
       annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.FlatteningTestCase(name="RedeclareTest2",
                                               description="Basic redeclares.",
                                               flatModel=
"
/*
fclass RedeclareTests.RedeclareTest2;
  Real p.c1.r = 1;
  Real p.c1.g = 0.1;
  Real p.c1.b = 0.1;
  Real p.c2.r = 0;
  Real p.c2.g = 0;
  Real p.c2.b = 1;
  Real p.c3.r = 0;
  Real p.c3.g = 1;
  Real p.c3.b = 0;
end RedeclareTests.RedeclareTest2;
*/
fclass RedeclareTests.RedeclareTest2
 Real p.c1.r = 1 /*(1)*/;
 Real p.c1.g = 0.1 /*(0.1)*/;
 Real p.c1.b = 0.1 /*(0.1)*/;
 Real p.c2.r = 0 /*(0)*/;
 Real p.c2.g = 0 /*(0)*/;
 Real p.c2.b = 1 /*(1)*/;
 Real p.c3.r = 0 /*(0)*/;
 Real p.c3.g = 1 /*(1)*/;
 Real p.c3.b = 0 /*(0)*/;
end RedeclareTests.RedeclareTest2;
")})));
  
  
  model Color 
    Real r=0;
    Real g=0;
    Real b=0;
  end Color;
  
  model Red 
    extends Color(r=1);
  end Red;
  
  model Green 
    extends Color(g=1);
  end Green;
  
  model Blue 
    extends Color(b=1);
  end Blue;
  
  model Palette 
     replaceable Color c1;
     replaceable Color c2;
     replaceable Color c3;
  end Palette;
  
  Palette p(redeclare Red c1(r=1,g=0.1,b=0.1),redeclare Blue c2,redeclare Green c3);
  
end RedeclareTest2;

model RedeclareTest3 
  
        annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.FlatteningTestCase(name="RedeclareTest3",
                                               description="Basic redeclares.",
                                               flatModel=
"
fclass RedeclareTests.RedeclareTest3
 Real r = 0.1 /*(0.1)*/;
 Real palette.q = 0.3 /*(0.3)*/;
 Real palette.p.b = 0.001 /*(0.0010)*/;
 Real palette.p.c1.rr = 0 /*(0)*/;
 Real palette.p.c1.r = 1 /*(1)*/;
 Real palette.p.c1.g = 0.2 /*(0.2)*/;
 Real palette.p.c1.b = 0 /*(0)*/;
 Real palette.p.c2.rr = 0 /*(0)*/;
 Real palette.p.c2.r = palette.p.c2.rr;
 Real palette.p.c2.g = 0 /*(0)*/;
 Real palette.p.c2.b = 1 /*(1)*/;
 Real palette.p.c3.gg = 1 /*(1)*/;
 Real palette.p.c3.rr = 0 /*(0)*/;
 Real palette.p.c3.r = r;
 Real palette.p.c3.g = palette.p.c3.gg;
 Real palette.p.c3.b = 0.002 /*(0.0020)*/;
 Real palette.p.q = 0.4 /*(0.4)*/;
 Real q = 0.3 /*(0.3)*/;
 Real p.b = 0.001 /*(0.0010)*/;
 Real p.c1.rr = 0 /*(0)*/;
 Real p.c1.r = 1 /*(1)*/;
 Real p.c1.g = 0.1 /*(0.1)*/;
 Real p.c1.b = 0.23 /*(0.23)*/;
 Real p.c2.rr = 0 /*(0)*/;
 Real p.c2.r = p.c2.rr;
 Real p.c2.g = 0 /*(0)*/;
 Real p.c2.b = 1 /*(1)*/;
 Real p.c3.gg = 1 /*(1)*/;
 Real p.c3.rr = 0 /*(0)*/;
 Real p.c3.r = 0.56 /*(0.56)*/;
 Real p.c3.g = 0.85 /*(0.85)*/;
 Real p.c3.b = 0.24 /*(0.24)*/;
 Real p.q = 0.4 /*(0.4)*/;
end RedeclareTests.RedeclareTest3;
")})));
  
  
  
  extends C0.Colors.MyPalette(p(redeclare C0.Colors.Green c3(r=0.56,g=0.85,b=0.24),c1(b=0.23)));
model C0 
    
  model Colors 
  model Color 
    Real rr = 0;
    Real r=rr;
    Real g=0;
    Real b=0;
  end Color;
      
  model Red 
    extends Color(r=1);
  end Red;
      
  model Green
    extends Color(g=gg);
    Real gg = 1; 
  end Green;
      
  model Blue 
    extends Color(b=1);
  end Blue;
      
  model Palette 
     Real b = 0.001;
     replaceable Color c1;
     replaceable Color c2;
     replaceable Color c3(b=b);
     Real q = 0.4;
  end Palette;
      
  model MyPalette 
        
  Real q = 0.3;
        
  Palette p(redeclare replaceable Red c1(g=0.1,b=q),redeclare replaceable Blue c2,
            redeclare replaceable Green c3(b=0.002));
        
  end MyPalette;
      
  end Colors;
    
end C0;
  
  Real r = 0.1;
 C0.Colors.MyPalette palette(p(c3(r=r),redeclare C0.Colors.Red c1(g=0.2)));
  
end RedeclareTest3;


model RedeclareTest4
   
         annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.FlatteningTestCase(name="RedeclareTest4",
                                               description="Basic redeclares.",
                                               flatModel=
"
fclass RedeclareTests.RedeclareTest4
 Real c0.q = 0.3 /*(0.3)*/;
 Real c0.p.c1.r = 1 /*(1)*/;
 Real c0.p.c1.g = 0.2 /*(0.2)*/;
 Real c0.p.c1.b = 0 /*(0)*/;
 Real c0.p.c2.r = 0 /*(0)*/;
 Real c0.p.c2.g = 0 /*(0)*/;
 Real c0.p.c2.b = 1 /*(1)*/;
 Real c0.p.c3.r = 0.1 /*(0.1)*/;
 Real c0.p.c3.g = 1 /*(1)*/;
 Real c0.p.c3.b = 0.001 /*(0.0010)*/;
 Real q = 0.3 /*(0.3)*/;
 Real p.c1.r = 1 /*(1)*/;
 Real p.c1.g = 0.1 /*(0.1)*/;
 Real p.c1.b = 0.23 /*(0.23)*/;
 Real p.c2.r = 0 /*(0)*/;
 Real p.c2.g = 0 /*(0)*/;
 Real p.c2.b = 1 /*(1)*/;
 Real p.c3.r = 0.56 /*(0.56)*/;
 Real p.c3.g = 0.85 /*(0.85)*/;
 Real p.c3.b = 0.24 /*(0.24)*/;
end RedeclareTests.RedeclareTest4;
")})));
  
 
  extends C0(p(redeclare C0.Green c3(r=0.56,g=0.85,b=0.24),c1(b=0.23)));
model C0 
  
  
  model Color 
    Real r=0;
    Real g=0;
    Real b=0;
  end Color;
  
  model Red 
    extends Color(r=1);
  end Red;
  
  model Green 
    extends Color(g=1);
  end Green;
  
  model Blue 
    extends Color(b=1);
  end Blue;
  
  model Palette 
     replaceable Color c1;
     replaceable Color c2;
     replaceable Color c3(b=0.001);
  end Palette;
  
  Real q = 0.3;
  
  Palette p(redeclare replaceable Red c1(g=0.1,b=q),redeclare replaceable Blue c2,redeclare replaceable Green c3);
  
end C0;

 C0 c0(p(c3(r=0.1),redeclare C0.Red c1(g=0.2)));

  

end RedeclareTest4;


model RedeclareTest5
  
  
    annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.FlatteningTestCase(name="RedeclareTest5",
                                               description="Basic redeclares.",
                                               flatModel=
"
fclass RedeclareTests.RedeclareTest5
 Real u.c1.c2.x = 55 /*(55)*/;
 Real u.c1.c2.y = 4 /*(4)*/;
 Real u.c1.c2.z = 66 /*(66)*/;
end RedeclareTests.RedeclareTest5;
")})));



model Unnamed 
  model C1 
    model C2 
      Real x=2;
    end C2;
    replaceable C2 c2(x=4);
  end C1;
    
  model C22 
     Real x=1;
     Real y=3;
  end C22;
    
  model C222 
    Real x=11;
     Real y=33;
  end C222;
    
  C1 c1(redeclare replaceable C222 c2(y=44,x=2));
    
end Unnamed;
  
model C222
     Real x=2;
     Real y=4;
     Real z=6;
end C222;
 Unnamed u(c1(redeclare C222 c2(x=55,z=66)));

end RedeclareTest5;

model RedeclareTest6
      annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.FlatteningTestCase(name="RedeclareTest6",
                                               description="Basic redeclares.",
                                               flatModel=
"
fclass RedeclareTests.RedeclareTest6
 Real b.a.c2.x = 6 /*(6)*/;
 Real b.a.c2.y = 4 /*(4)*/;
 Real b.a.c2.z = 9 /*(9)*/;
 Real bb.a.c2.x = 55 /*(55)*/;
 Real bb.a.c2.y = 8 /*(8)*/;
end RedeclareTests.RedeclareTest6;
")})));
  model C2
    Real x=2;
  end C2;
  
  model C22
    Real x=3;
    Real y=4;
  end C22;
  
  model C222
    Real x=5;
    Real y=6;
    Real z=7;
  end C222;
  
  model A
    replaceable C2 c2(x=55); 
  end A;
  
  model B
    A a(redeclare replaceable C22 c2(y=8));
  end B;
  
  B b(a(redeclare C222 c2(z=9,y=4,x=6)));
  B bb;

end RedeclareTest6;

model RedeclareTest65_Err
      annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.ErrorTestCase(name="RedeclareTest65_Err",
                                               description="Basic redeclare error.",
                                               errorMessage=
"
1 error(s) found...
In file 'src/test/modelica/ModificationTests.mo':
Semantic error at line 404, column 7:
  The component w is undeclared

")})));
  model C2
    Real x=2;
  end C2;
  
  model C22
    Real x=3;
    Real y=4;
  end C22;
  
  model C222
    Real x=5;
    Real y=6;
    Real z=7;
  end C222;
  
  model A
    replaceable C2 c2(x=55); 
  end A;
  
  model B
    A a(redeclare replaceable C22 c2(w=8));
  end B;
  
  B b(a(redeclare C222 c2(z=9,y=4,x=6)));

end RedeclareTest65_Err;



model RedeclareTest7
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.FlatteningTestCase(name="RedeclareTest7",
                                               description="Basic redeclares.",
                                               flatModel=
"
fclass RedeclareTests.RedeclareTest7
 Real p = 4 /*(4)*/;
 Real a.d.b.x = p;
 Real a.d.b.y = 5 /*(5)*/;
end RedeclareTests.RedeclareTest7;
")})));


  model A
  	model B
    	Real x=3;
 	 	end B;
  	model C
    	Real x=4;
    	Real y=5;
  	end C;
  	model D
  	  replaceable B b(x=0);
  	end D;
  	D d(b(x=7));
  end A;
  Real p=4;
  A a(d(redeclare A.C b(x=p)));
end RedeclareTest7;

model RedeclareTest8
  
  model C2
    Real x=2;
    
    
  end C2;
  
  model C22
    Real x=3;
    Real y=4;
    Real w=5;
  end C22;
  
  model C222
    Real x=5;
    Real y=6;
		Real w=4;
    Real z=7;
  end C222;
  
  model A
    Real q = 1;
    replaceable C2 c2;
  end A;
  
  model B
    Real p =1;
    A a(redeclare replaceable C22 c2(x=8,y=10),q=2);
    A a1(redeclare replaceable C22 c2(x=p));
    A aa;
  end B;
  
  A a(redeclare C22 c2);
  B b(a(redeclare C222 c2(z=9,y=4)));
end RedeclareTest8;

model RedeclareTest9
  
     annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.FlatteningTestCase(name="RedeclareTest9",
                                               description="Basic redeclares.",
                                               flatModel=
"
 fclass RedeclareTests.RedeclareTest9
 Real a.c2.x = 3 /*(3)*/;
 Real a.c2.y = 4 /*(4)*/;
 Real b.a.c2.x = 8 /*(8)*/;
 Real b.a.c2.y = 4 /*(4)*/;
 Real b.a.c2.z = 9 /*(9)*/;
 Real b.aa.c2.x = 2 /*(2)*/;
end RedeclareTests.RedeclareTest9;
")})));

  
  model C2
    Real x=2;
  end C2;
  
  model C22
    Real x=3;
    Real y=4;
  end C22;
  
  model C222
    Real x=5;
    Real y=6;
    Real z=7;
  end C222;
  
  model A
    replaceable C2 c2;
  end A;
  
  model B
    // Notice that the modifier 'x=8' is  merged since
    // it appears in a constraining clause  
    A a(redeclare replaceable C22 c2 constrainedby C22(x=8));
    A aa;
  end B;
  
  A a(redeclare C22 c2);
  B b(a(redeclare C222 c2(z=9,y=4)));
end RedeclareTest9;

model RedeclareTest95_Err
  
     annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.ErrorTestCase(name="RedeclareTest95_Err",
                                               description="Basic redeclares.",
                                               errorMessage=
"
1 error(s) found...
In file 'src/test/modelica/ModificationTests.mo':
Semantic error at line 1609, column 7:
  The component w is undeclared

")})));

  
  model C2
    Real x=2;
  end C2;
  
  model C22
    Real x=3;
    Real y=4;
  end C22;
  
  model C222
    Real x=5;
    Real y=6;
    Real z=7;
  end C222;
  
  model A
    replaceable C2 c2;
  end A;
  
  model B
    // Notice that the modifier 'x=8' is  merged since
    // it appears in a constraining clause  
    A a(redeclare replaceable C22 c2 constrainedby C22(w=8));
    A aa;
  end B;
  
  A a(redeclare C22 c2);
  B b(a(redeclare C222 c2(z=9,y=4)));
end RedeclareTest95_Err;

model RedeclareTest96_Err
  
     annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.ErrorTestCase(name="RedeclareTest96_Err",
                                               description="Basic redeclares.",
                                               errorMessage=
"
1 error(s) found...
In file 'src/test/modelica/ModificationTests.mo':
Semantic error at line 1659, column 7:
  The component w is undeclared

")})));

  
  model C2
    Real x=2;
  end C2;
  
  model C22
    Real x=3;
    Real y=4;
  end C22;
  
  model C222
    Real x=5;
    Real y=6;
    Real z=7;
  end C222;
  
  model A
    replaceable C2 c2;
  end A;
  
  model B
    // Notice that the modifier 'x=8' is  merged since
    // it appears in a constraining clause  
    extends A(redeclare replaceable C22 c2(w=8));
    A aa;
  end B;
  
  A a(redeclare C22 c2);
  B b(redeclare C222 c2(z=9,y=4));
end RedeclareTest96_Err;

model RedeclareTest97_Err
  
     annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.ErrorTestCase(name="RedeclareTest97_Err",
                                               description="Basic redeclares.",
                                               errorMessage=
"
1 error(s) found...
In file 'src/test/modelica/ModificationTests.mo':
Semantic error at line 1659, column 7:
  The component w is undeclared

")})));

  
  model C2
    Real x=2;
  end C2;
  
  model C22
    Real x=3;
    Real y=4;
  end C22;
  
  model C222
    Real x=5;
    Real y=6;
    Real z=7;
  end C222;
  
  model A
    replaceable C2 c2;
  end A;
  
  model B
    // Notice that the modifier 'x=8' is  merged since
    // it appears in a constraining clause  
    extends A(redeclare replaceable C22 c2 constrainedby C22(w=8));
    A aa;
  end B;
  
  A a(redeclare C22 c2);
  B b(redeclare C222 c2(z=9,y=4));
end RedeclareTest97_Err;

model RedeclareTest10 
  
        annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.FlatteningTestCase(name="RedeclareTest10",
                                               description="Basic redeclares.",
                                               flatModel=

"
fclass RedeclareTests.RedeclareTest10
 Real r = 0.1 /*(0.1)*/;
 Real palette.q = 0.3 /*(0.3)*/;
 Real palette.p.b = 0.001 /*(0.0010)*/;
 Real palette.p.c1.rr = 0 /*(0)*/;
 Real palette.p.c1.r = 1 /*(1)*/;
 Real palette.p.c1.g = 0.2 /*(0.2)*/;
 Real palette.p.c1.b = palette.q;
 Real palette.p.c2.rr = 0 /*(0)*/;
 Real palette.p.c2.r = palette.p.c2.rr;
 Real palette.p.c2.g = 0 /*(0)*/;
 Real palette.p.c2.b = 1 /*(1)*/;
 Real palette.p.c3.gg = 1 /*(1)*/;
 Real palette.p.c3.rr = 0 /*(0)*/;
 Real palette.p.c3.r = r;
 Real palette.p.c3.g = palette.p.c3.gg;
 Real palette.p.c3.b = 0.002 /*(0.0020)*/;
 Real palette.p.q = 0.4 /*(0.4)*/;
 Real q = 0.3 /*(0.3)*/;
 Real p.b = 0.001 /*(0.0010)*/;
 Real p.c1.rr = 0 /*(0)*/;
 Real p.c1.r = 1 /*(1)*/;
 Real p.c1.g = 0.1 /*(0.1)*/;
 Real p.c1.b = 0.23 /*(0.23)*/;
 Real p.c2.rr = 0 /*(0)*/;
 Real p.c2.r = p.c2.rr;
 Real p.c2.g = 0 /*(0)*/;
 Real p.c2.b = 1 /*(1)*/;
 Real p.c3.gg = 1 /*(1)*/;
 Real p.c3.rr = 0 /*(0)*/;
 Real p.c3.r = 0.56 /*(0.56)*/;
 Real p.c3.g = 0.85 /*(0.85)*/;
 Real p.c3.b = 0.24 /*(0.24)*/;
 Real p.q = 0.4 /*(0.4)*/;
end RedeclareTests.RedeclareTest10;
")})));
    
  extends C0.Colors.MyPalette(p(redeclare C0.Colors.Green c3(r=0.56,g=0.85,b=0.24),c1(b=0.23)));
model C0 
    
  model Colors 
  model Color 
    Real rr = 0;
    Real r=rr;
    Real g=0;
    Real b=0;
  end Color;
      
  model Red 
    extends Color(r=1);
  end Red;
      
  model Green
    extends Color(g=gg);
    Real gg = 1; 
  end Green;
      
  model Blue 
    extends Color(b=1);
  end Blue;
      
  model Palette 
     Real b = 0.001;
     replaceable Color c1;
     replaceable Color c2;
     replaceable Color c3(b=b);
     Real q = 0.4;
  end Palette;
      
  model MyPalette 
        
  Real q = 0.3;
        
  Palette p(redeclare replaceable Red c1 constrainedby Red(g=0.1,b=q),redeclare replaceable Blue c2,
            redeclare replaceable Green c3 constrainedby Green(b=0.002));
        
  end MyPalette;
      
  end Colors;
    
end C0;
  
  Real r = 0.1;
 C0.Colors.MyPalette palette(p(c3(r=r),redeclare C0.Colors.Red c1(g=0.2)));
  
end RedeclareTest10;

model RedeclareTest11
   
         annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.FlatteningTestCase(name="RedeclareTest11",
                                               description="Basic redeclares.",
                                               flatModel=
"
fclass RedeclareTests.RedeclareTest11
 Real c0.q = 0.3 /*(0.3)*/;
 Real c0.p.c1.r = 1 /*(1)*/;
 Real c0.p.c1.g = 0.2 /*(0.2)*/;
 Real c0.p.c1.b = c0.q;
 Real c0.p.c2.r = 0 /*(0)*/;
 Real c0.p.c2.g = 0 /*(0)*/;
 Real c0.p.c2.b = 1 /*(1)*/;
 Real c0.p.c3.r = 0.1 /*(0.1)*/;
 Real c0.p.c3.g = 1 /*(1)*/;
 Real c0.p.c3.b = 0.001 /*(0.0010)*/;
 Real q = 0.3 /*(0.3)*/;
 Real p.c1.r = 1 /*(1)*/;
 Real p.c1.g = 0.1 /*(0.1)*/;
 Real p.c1.b = 0.23 /*(0.23)*/;
 Real p.c2.r = 0 /*(0)*/;
 Real p.c2.g = 0 /*(0)*/;
 Real p.c2.b = 1 /*(1)*/;
 Real p.c3.r = 0.56 /*(0.56)*/;
 Real p.c3.g = 0.85 /*(0.85)*/;
 Real p.c3.b = 0.24 /*(0.24)*/;
end RedeclareTests.RedeclareTest11;
")})));
  
 
  extends C0(p(redeclare replaceable C0.Green c3 constrainedby C0.Green(r=0.56,g=0.85,b=0.24),c1(b=0.23)));
model C0 
  
  
  model Color 
    Real r=0;
    Real g=0;
    Real b=0;
  end Color;
  
  model Red 
    extends Color(r=1);
  end Red;
  
  model Green 
    extends Color(g=1);
  end Green;
  
  model Blue 
    extends Color(b=1);
  end Blue;
  
  model Palette 
     replaceable Color c1;
     replaceable Color c2;
     replaceable Color c3(b=0.001);
  end Palette;
  
  Real q = 0.3;
  
  Palette p(redeclare replaceable Red c1 constrainedby Red(g=0.1,b=q),
            redeclare replaceable Blue c2,redeclare replaceable Green c3);
  
end C0;

 C0 c0(p(c3(r=0.1),redeclare C0.Red c1(g=0.2)));

  

end RedeclareTest11;

model RedeclareTest12
  
  
    annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.FlatteningTestCase(name="RedeclareTest12",
                                               description="Basic redeclares.",
                                               flatModel=
"
fclass RedeclareTests.RedeclareTest12
 Real u.c1.c2.x = 55 /*(55)*/;
 Real u.c1.c2.y = 44 /*(44)*/;
 Real u.c1.c2.z = 66 /*(66)*/;
end RedeclareTests.RedeclareTest12;
")})));



model Unnamed 
  model C1 
    model C2 
      Real x=2;
    end C2;
    replaceable C2 c2(x=4);
  end C1;
    
  model C22 
     Real x=1;
     Real y=3;
  end C22;
    
  model C222 
    Real x=11;
     Real y=33;
  end C222;
    
  C1 c1(redeclare replaceable C222 c2 constrainedby C222(y=44,x=2));
    
end Unnamed;
  
model C222
     Real x=2;
     Real y=4;
     Real z=6;
end C222;
 Unnamed u(c1(redeclare C222 c2(x=55,z=66)));

end RedeclareTest12;

model RedeclareTest13
    annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.FlatteningTestCase(name="RedeclareTest13",
                                               description="Basic redeclares.",
                                               flatModel=
"
fclass RedeclareTests.RedeclareTest13
 Real c.b1.z = 3 /*(3)*/;
 Real c.b1.x = 5 /*(5)*/;
 Real c.b1.y = 4 /*(4)*/;
 Real c.b2.z = 3 /*(3)*/;
 Real c.b2.x = 5 /*(5)*/;
 Real c.b2.y = 3 /*(3)*/;
end RedeclareTests.RedeclareTest13;
")})));


	model A
	  Real x=1;
	  Real y=2;
	end A;
	
	model B
	  extends A;
	  Real z = 3;
	end B;
	
	model C
	  replaceable B b1(x=5) constrainedby B(x=3,y=4);
	  replaceable B b2(x=5) constrainedby B(y=3);
    end C;
    
    C c;
	
end RedeclareTest13;

model RedeclareTest14
    annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.FlatteningTestCase(name="RedeclareTest14",
                                               description="Basic redeclares.",
                                               flatModel=
"
fclass RedeclareTests.RedeclareTest14
 Real c.b1.z = 3 /*(3)*/;
 Real c.b1.x = 5 /*(5)*/;
 Real c.b1.y = 4 /*(4)*/;
 Real c.b2.z = 5 /*(5)*/;
 Real c.b2.x = 1 /*(1)*/;
 Real c.b2.y = 3 /*(3)*/;
end RedeclareTests.RedeclareTest14;
")})));

	model A
	  Real x=1;
	  Real y=2;
	end A;
	
	model B
	  extends A;
	  Real z = 3;
	end B;
	
	model C
	  replaceable B b1(x=5) constrainedby B(x=3,y=4);
	  replaceable B b2(x=5) constrainedby B(y=3);
    end C;
    
    C c(redeclare B b2(z=5));
	
end RedeclareTest14;

class RedeclareTest15 "Test of merging of modifications in parametrized classes"
 
      annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.FlatteningTestCase(name="RedeclareTest15",
        description="Test of parametrized classes.",
                                               flatModel=
"fclass RedeclareTests.RedeclareTest15
 Real d.c.a.x = 4 /*(4)*/;
 Real d.c.a.y = 5 /*(5)*/;
end RedeclareTests.RedeclareTest15;
"
  )})));
 
  
  model A
    Real x=1;
  end A;
 
  model B
   Real x=2;
   Real y=3;
  end B;
  
   model C
     replaceable model myA = A(x=2);
     myA a(x=4);
   end C;
 
   model D
      C c(redeclare replaceable model myA = B(y=5));
   end D;
 
   D d;

end RedeclareTest15;

class RedeclareTest16 "Test of merging of modifications in parametrized classes"
 
      annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.FlatteningTestCase(name="RedeclareTest16",
        description="Test of parametrized classes.",
                                               flatModel=
"fclass RedeclareTests.RedeclareTest16
 Real e.d.a.x = 5 /*(5)*/;
 Real e.d.a.y = 4 /*(4)*/;
 Real e.d.a.z = 6 /*(6)*/;
end RedeclareTests.RedeclareTest16;
"
  )})));
 
  
  model A
    Real x=1;
  end A;
 
  model B
   Real x=2;
   Real y=3;
  end B;
  
  model C
   Real x=2;
   Real y=3;
   Real z=4;
  end C;

   model D
     replaceable A a(x=4);
   
   end D;
 
   model E
     replaceable model myB = B(x=6,y=4);
     D d(redeclare replaceable myB a(x=5));
   end E;
 
   E e(redeclare model myB = C(z=6));

end RedeclareTest16;

class RedeclareTest161 "Test of merging of modifications in parametrized classes"
 
      annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.FlatteningTestCase(name="RedeclareTest161",
        description="Test of parametrized classes.",
                                               flatModel=
"fclass RedeclareTests.RedeclareTest161
 Real e.x = 6 /*(6)*/;
 Real e.y = 4 /*(4)*/;
 Real e.z = 6 /*(6)*/;
end RedeclareTests.RedeclareTest161;
"
  )})));
 
  
  model A
    Real x=1;
  end A;
 
  model B
   Real x=2;
   Real y=3;
  end B;
  
  model C
   Real x=2;
   Real y=3;
   Real z=4;
  end C;

   model E
     replaceable model myB = B(x=6,y=4);
     extends myB;
   end E;
 
   E e(redeclare model myB = C(z=6));

end RedeclareTest161;

class RedeclareTest165 
 
       annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.FlatteningTestCase(name="RedeclareTest165",
        description="Test of parametrized classes.",
                                               flatModel=
"fclass RedeclareTests.RedeclareTest165
 parameter Real e.pE = 5 /*(5)*/;
 Real e.d.a.x = 5 /*(5)*/;
 Real e.d.a.y = e.pE /*(5)*/;
 Real e.d.a.z = 6 /*(6)*/;
 Real e.d.a.u = 5 /*(5)*/;
 Real e.d.a.v = 6 /*(6)*/;
 Real e.d.a.w = 7 /*(7)*/;
end RedeclareTests.RedeclareTest165;
"
  )})));
 
 
  model A
    Real x=1;
  end A;
 
  model B
   Real x=2;
   Real y=3;
   Real z=4;
   Real u=5;
   Real v=6;
  end B;
 
  model C
   Real x=2;
   Real y=3;
   Real z=4;
   Real u=5;
   Real v=6;
   Real w=7;
  end C;
 
   model D
     replaceable A a(x=4);
 
   end D;
 
   model E
     parameter Real pE = 5;
     replaceable model myB = BB(x=6,y=pE); // This access to B should be illegal since
                                           // Redeclare165 is not a package.
     D d(redeclare replaceable myB a(x=5));
   end E;
 
   model BB = B(u=1); // This is tricky. Notice that 'u=1' is inside BB and is 
                      // handled as such when modifications are merged. In this
                      // case it means that it is discarded when myB is redeclared.
 
   E e(redeclare model myB = C(z=6));
 
end RedeclareTest165;

model RedeclareTest17
  
   
       annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.FlatteningTestCase(name="RedeclareTest17",
        description="Test of parametrized classes.",
                                               flatModel=
"fclass RedeclareTests.RedeclareTest17
 Real bb.x = 3 /*(3)*/;
 Real bb.y = 3 /*(3)*/;
 Real bb.z = 4 /*(4)*/;
end RedeclareTests.RedeclareTest17;

"
  )})));
  
  
   package P
   model A
    Real x=1;
   end A;
 
     model B
        Real x=2;
        Real y=3;
     end B;
 
     model C
        Real x=2;
        Real y=3;
        Real z=4;
     end C;
     
     replaceable model BB = B(x=3);
   end P;
 
   package PP = P(redeclare model BB = P.C(y=5));
 
  PP.BB bb(y=3);
 
end RedeclareTest17;

model RedeclareTest175
  
   
       annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.FlatteningTestCase(name="RedeclareTest175",
        description="Test of parametrized classes.",
                                               flatModel=
"fclass RedeclareTests.RedeclareTest175
 Real bb.x = 2 /*(2)*/;
 Real bb.y = 6 /*(6)*/;
 Real bb.z = 5 /*(5)*/;
end RedeclareTests.RedeclareTest175;

"
  )})));
  
   package P
   model A
    Real x=1;
   end A;
 
     model B
        Real x=2;
        Real y=3;
     end B;
 
     model C
        Real x=2;
        Real y=3;
        Real z=4;
     end C;
     
     replaceable model BB 
     	extends B(x=3);
     end BB;
   end P;
 
   package PP = P(redeclare model BB = P.C(z=5));
 
  PP.BB bb(y=6);
 
end RedeclareTest175;

model RedeclareTest176
  
   
       annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.FlatteningTestCase(name="RedeclareTest176",
        description="Test of parametrized classes.",
                                               flatModel=
"fclass RedeclareTests.RedeclareTest176
 Real bb.x = 3 /*(3)*/;
 Real bb.y = 6 /*(6)*/;
 Real bb.z = 4 /*(4)*/;
end RedeclareTests.RedeclareTest176;

"
  )})));
  
   package P
   model A
    Real x=1;
   end A;
 
     model B
        Real x=2;
        Real y=3;
     end B;
 
     model C
        Real x=2;
        Real y=3;
        Real z=4;
     end C;
     
     replaceable model BB = B(x=3);
     
   end P;
 
   package PP = P(redeclare model BB 
     	                      extends P.C(y=4);
                            end BB);
 
  PP.BB bb(y=6);
 
end RedeclareTest176;


class RedeclareTest18 "Test of merging of modifications in parametrized classes"
 
      annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.FlatteningTestCase(name="RedeclareTest18",
        description="Test of parametrized classes.",
                                               flatModel=
"
fclass RedeclareTests.RedeclareTest18
 Real g.f.e.a.x = 5 /*(5)*/;
 Real g.f.e.a.y = 4 /*(4)*/;
 Real g.f.e.a.z = 6 /*(6)*/;
 Real g.f.e.a.w = 5 /*(5)*/;
end RedeclareTests.RedeclareTest18;
"
  )})));
 
  
  model A
    Real x=1;
  end A;
 
  model B
   Real x=2;
   Real y=3;
  end B;
  
  model C
   Real x=2;
   Real y=3;
   Real z=4;
  end C;

  model D
   Real x=2;
   Real y=3;
   Real z=4;
   Real w=5;
  end D;

   model E
     replaceable A a(x=4);
   
   end E;
 
   model F
     replaceable model myB = B(x=6,y=4);
     E e(redeclare replaceable myB a(x=5));
   end F;
 
   model G
     replaceable model myC = C(y=7,z=4);
     F f(redeclare model myB = myC);
   end G;
    
   G g(redeclare model myC = D(z=6,w=5));

end RedeclareTest18;

class RedeclareTest19 "Test of merging of modifications in parametrized classes"
 
      annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.FlatteningTestCase(name="RedeclareTest19",
        description="Test of parametrized classes.",
                                               flatModel=
"
fclass RedeclareTests.RedeclareTest19
 Real g.f.e.a.x = 5 /*(5)*/;
 Real g.f.e.a.y = 4 /*(4)*/;
 Real g.f.e.a.z = 6 /*(6)*/;
 Real g.f.e.a.w = 5 /*(5)*/;
end RedeclareTests.RedeclareTest19;
"
  )})));
 
  
  model A
    Real x=1;
  end A;
 
  model B
   Real x=2;
   Real y=3;
  end B;
  
  model C
   Real x=2;
   Real y=3;
   Real z=4;
  end C;

  model D
   Real x=2;
   Real y=3;
   Real z=4;
   Real w=5;
  end D;

   model E
     replaceable A a(x=4);
   
   end E;
 
   model F
     replaceable model myB = B(x=6,y=4);
     E e(redeclare replaceable myB a(x=5));
   end F;
 
   model G
     replaceable model myC = C(y=7,z=4);
     model myC2 = myC(y=10);
     F f(redeclare model myB = myC2);
   end G;
    
    
   G g(redeclare model myC = D(z=6,w=5));

end RedeclareTest19;

class RedeclareTest20 "Test of merging of modifications in parametrized classes"
 
      annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.FlatteningTestCase(name="RedeclareTest20",
        description="Test of parametrized classes.",
                                               flatModel=
"
fclass RedeclareTests.RedeclareTest20
 Real g.f.e.b.x = 5 /*(5)*/;
 Real g.f.e.b.y = 3 /*(3)*/;
 Real g.f.e.a.x = 5 /*(5)*/;
 Real g.f.e.a.y = 4 /*(4)*/;
 Real g.f.e.a.z = 6 /*(6)*/;
 Real g.f.e.a.w = 5 /*(5)*/;
end RedeclareTests.RedeclareTest20;
	
"
  )})));
 
  
  model A
    Real x=1;
  end A;
 
  model B
   Real x=2;
   Real y=3;
  end B;
  
  model C
   Real x=2;
   Real y=3;
   Real z=4;
  end C;

  model D
   Real x=2;
   Real y=3;
   Real z=4;
   Real w=5;
  end D;

   model E
   
     model myB = B(x=5);
     myB b;
     replaceable A a(x=4);
   
   end E;
 
   model F
     replaceable model myB = B(x=6,y=4);
     E e(redeclare replaceable myB a(x=5));
   end F;
 
   model G
     replaceable model myC = C(y=7,z=4);
     model myC2 = myC(y=10);
     F f(redeclare model myB = myC2);
   end G;
    
   G g(redeclare model myC = D(z=6,w=5));

end RedeclareTest20;

class RedeclareTest21 "Test of merging of modifications in parametrized classes"
 
      annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.FlatteningTestCase(name="RedeclareTest21",
        description="Test of parametrized classes.",
                                               flatModel=
"
fclass RedeclareTests.RedeclareTest21
 parameter Real p0 = 5 /*(5)*/;
 parameter Real g.pG = 6 /*(6)*/;
 parameter Real g.f.pF = 4 /*(4)*/;
 parameter Real g.f.e.pE = 3 /*(3)*/;
 Real g.f.e.b.x = g.f.e.pE /*(3)*/;
 Real g.f.e.b.y = 3 /*(3)*/;
 Real g.f.e.a.x = 5 /*(5)*/;
 Real g.f.e.a.y = g.f.pF /*(4)*/;
 Real g.f.e.a.z = g.pG /*(6)*/;
 Real g.f.e.a.w = p0 /*(5)*/;
end RedeclareTests.RedeclareTest21;	
"
  )})));
 
  
  model A
    Real x=1;
  end A;
 
  model B
   Real x=2;
   Real y=3;
  end B;
  
  model C
   Real x=2;
   Real y=3;
   Real z=4;
  end C;

  model D
   Real x=2;
   Real y=3;
   Real z=4;
   Real w=5;
  end D;

   model E
     parameter Real pE = 3;
     model myB = B(x=pE);
     myB b;
     replaceable A a(x=4);
   
   end E;
 
   model F
     parameter Real pF = 4;
     replaceable model myB = B(x=6,y=pF);
     E e(redeclare replaceable myB a(x=5));
   end F;
 
   model G
   	 parameter Real pG = 6;
     replaceable model myC = C(y=7,z=pG);
     model myC2 = myC(y=10);
     F f(redeclare model myB = myC2);
   end G;
    
   parameter Real p0 = 5; 
   G g(redeclare model myC = D(w=p0));

end RedeclareTest21;

class RedeclareTest22 "Test of merging of modifications in parametrized classes"
 
      annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.FlatteningTestCase(name="RedeclareTest22",
        description="Test of parametrized classes.",
                                               flatModel=
"
fclass RedeclareTests.RedeclareTest22
 parameter Real p0 = 5 /*(5)*/;
 parameter Real g.pG = 6 /*(6)*/;
 parameter Real g.f.pF = 4 /*(4)*/;
 parameter Real g.f.e.pE = 3 /*(3)*/;
 Real g.f.e.b.x = g.f.e.pE /*(3)*/;
 Real g.f.e.b.y = 3 /*(3)*/;
 Real g.f.e.b.z = 4 /*(4)*/;
 Real g.f.e.b.w = p0 /*(5)*/;
end RedeclareTests.RedeclareTest22;
"
  )})));
 
  
  model A
    Real x=1;
  end A;
 
  model B
   Real x=2;
   Real y=3;
  end B;
  
  model C
   Real x=2;
   Real y=3;
   Real z=4;
  end C;

  model D
   Real x=2;
   Real y=3;
   Real z=4;
   Real w=5;
  end D;

   model E
     parameter Real pE = 3;
     replaceable model myB = B(x=pE);
     myB b;
   end E;
 
   model F
     parameter Real pF = 4;
     replaceable model myB2 = B(x=6,y=pF);
     E e(redeclare model myB = myB2);
   end F;
 
   model G
   	 parameter Real pG = 6;
     replaceable model myC = C(y=7,z=pG);
     F f(e(redeclare model myB = myC));
   end G;
    
   parameter Real p0 = 5; 
   G g(f(e(redeclare model myB = D(w=p0))));

end RedeclareTest22;

class RedeclareTest225 "Test of merging of modifications in parametrized classes"
 
      annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.FlatteningTestCase(name="RedeclareTest225",
        description="Test of parametrized classes.",
                                               flatModel=
"
fclass RedeclareTests.RedeclareTest225
 parameter Real p0 = 5 /*(5)*/;
 parameter Real f.e.pE = 3 /*(3)*/;
 Real f.e.b.x = f.e.pE /*(3)*/;
 Real f.e.b.y = 3 /*(3)*/;
 Real f.e.b.z = 4 /*(4)*/;
 Real f.e.b.w = p0 /*(5)*/;
end RedeclareTests.RedeclareTest225;	
"
  )})));
 
  
  model A
    Real x=1;
  end A;
 
  model B
   Real x=2;
   Real y=3;
  end B;
  
  model C
   Real x=2;
   Real y=3;
   Real z=4;
  end C;

  model D
   Real x=2;
   Real y=3;
   Real z=4;
   Real w=5;
  end D;

   model E
     parameter Real pE = 3;
     replaceable model myB = B(x=pE);
     myB b;
   end E;
 
   model F
     E e;
   end F;
 
   parameter Real p0 = 5; 
   F f(e(redeclare model myB = D(w=p0)));

end RedeclareTest225;

model RedeclareTest23


      annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.FlatteningTestCase(name="RedeclareTest23",
        description="Test of parametrized classes.",
                                               flatModel=
"
fclass RedeclareTests.RedeclareTest23
 Real d1.b.x = 4 /*(4)*/;
 Real d1.b.y = 3 /*(3)*/;
 Real d1.b.z = 10 /*(10)*/;
 Real d2.b.x = 4 /*(4)*/;
 Real d2.b.y = 3 /*(3)*/;
 Real d2.b.z = 10 /*(10)*/;
end RedeclareTests.RedeclareTest23;

"
  )})));

  model B
     Real x=2;
     Real y=3;
  end B;

  model C
     Real x=2;
     Real y=3;
     Real z=4;
  end C;

  model D
    replaceable model BB = B(x=4);
    BB b;
  end D;

  model CC = C(x=5,z=10);

  model CCC
     extends C(x=5,z=10);
  end CCC;


  D d1(redeclare model BB = CC);
  D d2(redeclare model BB = CCC);
 

end RedeclareTest23;

class RedeclareTest24 "Test of merging of modifications in parametrized classes"
 
      annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.FlatteningTestCase(name="RedeclareTest24",
        description="Test of parametrized classes.",
                                               flatModel=
"
fclass RedeclareTests.RedeclareTest24
 parameter Real p0 = 5 /*(5)*/;
 parameter Real g.pG = 6 /*(6)*/;
 parameter Real g.f.pF = 4 /*(4)*/;
 parameter Real g.f.e.pE = 3 /*(3)*/;
 Real g.f.e.b.x = g.f.e.pE /*(3)*/;
 Real g.f.e.b.y = 3 /*(3)*/;
 Real g.f.e.b.z = 4 /*(4)*/;
 Real g.f.e.b.w = p0 /*(5)*/;
end RedeclareTests.RedeclareTest24;
"
  )})));
 
  
  model A
    Real x=1;
  end A;
 
  model B
   Real x=2;
   Real y=3;
  end B;
  
  model C
   Real x=2;
   Real y=3;
   Real z=4;
  end C;

  model D
   Real x=2;
   Real y=3;
   Real z=4;
   Real w=5;
  end D;

   model E
     parameter Real pE = 3;
     replaceable model myB = B(x=pE);
     myB b;
   end E;
 
   model F
     parameter Real pF = 4;
     replaceable model myB2 = B(x=6,y=pF);
     E e(redeclare model myB = myB2(y=8));
   end F;
 
   model G
   	 parameter Real pG = 6;
     replaceable model myC = C(y=7,z=pG);
     F f(e(redeclare model myB = myC(z=9)));
   end G;
    
   parameter Real p0 = 5; 
   G g(f(e(redeclare model myB = D(w=p0))));

end RedeclareTest24;

class RedeclareTest25 "Test of merging of modifications in parametrized classes"
 
      annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.FlatteningTestCase(name="RedeclareTest25",
        description="Test of parametrized classes.",
                                               flatModel=
"
fclass RedeclareTests.RedeclareTest25
 parameter Real p0 = 5 /*(5)*/;
 parameter Real g.pG = 6 /*(6)*/;
 parameter Real g.f.pF = 4 /*(4)*/;
 parameter Real g.f.e.pE = 3 /*(3)*/;
 Real g.f.e.b.x = g.f.e.pE /*(3)*/;
 Real g.f.e.b.y = 8 /*(8)*/;
 Real g.f.e.b.z = 9 /*(9)*/;
 Real g.f.e.b.w = p0 /*(5)*/;
end RedeclareTests.RedeclareTest25;
"
  )})));
 
  
  model A
    Real x=1;
  end A;
 
  model B
   Real x=2;
   Real y=3;
  end B;
  
  model C
   Real x=2;
   Real y=3;
   Real z=4;
  end C;

  model D
   Real x=2;
   Real y=3;
   Real z=4;
   Real w=5;
  end D;

   model E
     parameter Real pE = 3;
     replaceable model myB = B(x=pE);
     myB b;
   end E;
 
   model F
     parameter Real pF = 4;
     replaceable model myB2 = B(x=6,y=pF);
     E e(redeclare replaceable model myB = myB2 constrainedby myB2(y=8));
   end F;
 
   model G
   	 parameter Real pG = 6;
     replaceable model myC = C(y=7,z=pG);
     F f(e(redeclare replaceable model myB = myC constrainedby myC(z=9)));
   end G;
    
   parameter Real p0 = 5; 
   G g(f(e(redeclare model myB = D(w=p0))));

end RedeclareTest25;

model RedeclareTest26 

      annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.FlatteningTestCase(name="RedeclareTest26",
        description="Test of parametrized classes.",
                                               flatModel=
"
fclass RedeclareTests.RedeclareTest26
 Real m.x;
 Real m.y;
end RedeclareTests.RedeclareTest26;
"
  )})));

	
	model M1
	  Real x;
	  model Q
	    Real z;
	  end Q;
	end M1;
	
	model M2
	  Real x;
	  Real y;
	  model Q
	    Real z;
	  end Q;
	end M2;
	
	model A
	   replaceable M1 m;
	end A;

    extends A(redeclare M2 m);

end RedeclareTest26;

model RedeclareTest27
 
      annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.FlatteningTestCase(name="RedeclareTest27",
        description="Test of parametrized classes.",
                                               flatModel=
"
fclass RedeclareTests.RedeclareTest27
 Real b.y = 3;
end RedeclareTests.RedeclareTest27;
")})));

 package P1
    model A
      Real x=2;
    end A;
  end P1;

  package P2
    extends P1;
    model B
      Real y=3;
    end B;
  end P2;

  package P3
    replaceable package P = P1;
  end P3;

  package P4
    extends P3(redeclare package P = P2);
  end P4;

  P4.P.B b;


end RedeclareTest27;

model RedeclareTest28

      annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.FlatteningTestCase(name="RedeclareTest28",
        description="Test of parametrized classes.",
                                               flatModel=
"
fclass RedeclareTests.RedeclareTest28
 parameter Real p2 = 3 /* 3.0 */;
 parameter Real p3 = 1 /* 1.0 */;
 parameter Real m1.p2 = p2;
 parameter Real m1.p1 = p3;
end RedeclareTests.RedeclareTest28;
")})));



  model M1
    parameter Real p1=2;
  end M1;

  model M2
    extends M1;
    parameter Real p2=2;
  end M2;

  model A
    parameter Real p3 = 1;
    replaceable M1 m1(p1=p3);
  end A;
  
  parameter Real p2 = 3;
  extends A(redeclare M2 m1(p2=p2));


end RedeclareTest28;



model RedeclareElement1
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.FlatteningTestCase(
         name="RedeclareElement1",
         description="Redeclare class as element, short replacing declaration, basic test",
         flatModel="
fclass RedeclareTests.RedeclareElement1
 Real c.b.y;
 Real c.b.z;
equation
 c.b.y = 1;
 c.b.z = 2;
end RedeclareTests.RedeclareElement1;
")})));

  model A
    replaceable model B
      Real y;
    end B;
    
    B b;
  end A;
  
  model C
    extends A;
    redeclare model B = D;
    model D 
      Real y;
      Real z;
    end D;
  end C;
  
  C c;
equation
  c.b.y = 1;
  c.b.z = 2;
end RedeclareElement1;


model RedeclareElement2
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.FlatteningTestCase(
         name="RedeclareElement2",
         description="Redeclare class as element, long replacing declaration, basic test",
         flatModel="
fclass RedeclareTests.RedeclareElement2
 Real c.b.y;
 Real c.b.z;
equation
 c.b.y = 1;
 c.b.z = 2;
end RedeclareTests.RedeclareElement2;
")})));

  model A
    replaceable model B
      Real y;
    end B;
    
    B b;
  end A;
  
  model C
    extends A;
    redeclare model B
      Real y;
      Real z;
    end B;
  end C;
  
  C c;
equation
  c.b.y = 1;
  c.b.z = 2;
end RedeclareElement2;


model RedeclareElement3
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.FlatteningTestCase(
         name="RedeclareElement3",
         description="Redeclare class as element, long extending declaration, basic test",
         flatModel="
fclass RedeclareTests.RedeclareElement3
 Real c.b.z;
 Real c.b.y;
equation
 c.b.y = 1;
 c.b.z = 2;
end RedeclareTests.RedeclareElement3;
")})));

  model A
    replaceable model B
      Real y;
    end B;
    
    B b;
  end A;
  
  model C
    extends A;
    redeclare model extends B
      Real z;
    end B;
  end C;
  
  C c;
equation
  c.b.y = 1;
  c.b.z = 2;
end RedeclareElement3;


model RedeclareElement4
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.FlatteningTestCase(
         name="RedeclareElement4",
         description="Redeclare class as element, long extending declaration, basic test",
         flatModel="
fclass RedeclareTests.RedeclareElement4
 Real c.b.z;
 Real c.b.y;
equation
 c.b.y = 1;
 c.b.z = 2;
end RedeclareTests.RedeclareElement4;
")})));

  model A
    replaceable model B
      Real y;
    end B;
    
    B b;
  end A;
  
  model C
    extends A;
    model extends B
      Real z;
    end B;
  end C;
  
  C c;
equation
  c.b.y = 1;
  c.b.z = 2;
end RedeclareElement4;



end RedeclareTests;

