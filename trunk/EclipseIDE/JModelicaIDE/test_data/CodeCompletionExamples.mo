package CodeCompletionExamples.mo

  /* Completion of class names */

  model ClassTest1
    model MA
      Real x;
    end MA;
    model MB
      Real x;
    end MB;
    CodeCompletionExamples.ClassTest1.^ // {'MA','MB'}
  end ClassTest1;

  model ClassTest2
    model MA
      Real x;
    end MA;
    model MB
      Real x;
    end MB;
    ClassTest1.^ // {'MA','MB'}
  end ClassTest2;

  model ClassTest3
    model MA
      Real x;
    end MA;
    model MB
      Real x;
    end MB;
    M.^ // {'MA','MB'}
  end ClassTest3;

  model ClassTest4
    Modelica.^// {'Blocks','Constants','Electrical','Icons',Images','Math','Mechanics','Media','SIunits','StateGraph','Thermal','Utilities'} 
  end ClassTest4;

model ClassTest5

 model M1
    model A
	Real x=2;
    end A;
  end M1;

   model M2 extends M1;
    model B extends M1.A;
      Real y=3;
    end B;
  end M2;

  model M
    replaceable model MM = M1;
  end M;

  package myM = M(redeclare model MM=M2);

   myM.MM.^ // {'A','B'}

end ClassTest5;

 /* Completion of component names */
 
 model ComponentTest1
   model A
     Real x;
   end A;

   A a;

  equation
   a.^ // {'x'}

 end ComponentTest1;

 model ComponentTest2
   model A
     Real x;
   end A;

   model B
     extends A;
     Real y;

   B b;

  equation
   b.^ // {'x','y'}

 end ComponentTest2;


 model ComponentTest3
   model A
     parameter Real x;
   end A;

   A b;
   Real p = A.^ // {'x'} 
 end ComponentTest3;

  model ComponentTest4 

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

 equation
   c.a.^ // {'x','y'}
 
end ComponentTest4;


 /* Completion of modifications. */
 model ModificationTest1
   Real x(m^ // {'min','max'}
 end ModificationTest1;

end CodeCompletionExamples.mo;