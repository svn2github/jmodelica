package LinearTest

    model Linear1
        parameter Real small = 1e-10;
        parameter Real A = 2496000;
        parameter Real B = 2560000*A_Qhat/small;
        parameter Real N = (7763.0 * 492 * (1.0 / 59.9));
        parameter Real A_Qhat = (2 * 0.000625)/(59.9 * 2 * 3.141592653589793 * (0.01 + 0.0025) * 1.0);
        parameter Real Ahat = (A+B)/N;
        
        Real x; //The ODE state
        
        initial equation
            der(x) = 0.0;

        equation
            //--- Solved equation ---
            der(x) = Ahat*x;
    end Linear1;

end package;
