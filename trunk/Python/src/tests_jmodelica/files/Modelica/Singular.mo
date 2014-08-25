package Singular "Some tests for singular systems" 

    model Linear1
        Real x,y,z,v;
        parameter Real a11 = 1;
        parameter Real a12 = 0;
        parameter Real a13 = 0;
        parameter Real a21 = 0;
        parameter Real a22 = 1;
        parameter Real a23 = 0;
        parameter Real a31 = 0;
        parameter Real a32 = 0;
        parameter Real a33 = 1;
        parameter Real b[3] = {1,2,3};
    equation
        a11*x+a12*y+a13*z = b[1];
        a21*x+a22*y+a23*z = b[2];
        a31*x+a32*y+a33*z = b[3];
        der(v) = time;
    end Linear1;
    
    model Linear2
        extends Linear1(z(start=5));
    end Linear2;
    
    model Linear3
        extends Linear1(y(start=5));
    end Linear3;

    model NonLinear1 "Actually Linear"
        parameter Real a11 = 1;
        parameter Real a12 = 0;
        parameter Real a13 = 0;
        parameter Real a21 = 0;
        parameter Real a22 = 1;
        parameter Real a23 = 0;
        parameter Real a31 = 0;
        parameter Real a32 = 0;
        parameter Real a33 = 1;
        Real A[3,3];
        
        function MatrixMul
            input Real x,y,z;
            input Real A[:,:];
            output Real b[3];
            
        algorithm
            b[1] := A[1,1]*x+A[1,2]*y+A[1,3]*z;
            b[2] := A[2,1]*x+A[2,2]*y+A[2,3]*z;
            b[3] := A[3,1]*x+A[3,2]*y+A[3,3]*z;
            
            annotation (Inline=true);
        end MatrixMul;
        Real x,y,z,v;
        parameter Real b[3] = {1,2,3};
    equation
        A[1,1] = a11;
        A[1,2] = a12;
        A[1,3] = a13;
        A[2,1] = a21;
        A[2,2] = a22;
        A[2,3] = a23;
        A[3,1] = a31;
        A[3,2] = a32;
        A[3,3] = a33;
        b = MatrixMul(x,y,z,A);
        der(v) = time;
    end NonLinear1;
    
    model NonLinear2
        extends NonLinear1(z(start=5));
    end NonLinear2;
    
    model NonLinear3
        extends NonLinear1(y(start=5));
    end NonLinear3;
    
    model LinearInf
        extends Linear1;
    end LinearInf;

end Singular;
