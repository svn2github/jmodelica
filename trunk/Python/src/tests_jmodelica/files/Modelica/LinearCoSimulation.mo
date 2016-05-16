package LinearCoSimulation

    model LinearFullSystem
        LinearSubSystem1 p1;
        LinearSubSystem2 p2;
        parameter Real A[2,2] = [p1.a1,0;0,p2.a2];
        parameter Real B[2,2] = [p1.b1,0;0,p2.b2];
        parameter Real C[2,2] = [p1.c1,0;0,p2.c2];
        parameter Real D[2,2] = [p1.d1,0;0,p2.d2];
    equation
        p1.u1 = p2.y2;
        p1.y1 = p2.u2;
    end LinearFullSystem;

    model LinearSubSystem1
        parameter Real d1=1;
        parameter Real a1=-0.9;
        parameter Real b1=0.5;
        parameter Real c1=3;
        Real x1(start=1,fixed=true);
        input Real u1;
        output Real y1;
    equation
        der(x1) = a1*x1+b1*u1;
        y1=c1*x1+d1*u1;
    end LinearSubSystem1;
    
    model LinearSubSystem2
        parameter Real d2=-0.9;
        parameter Real a2=-1;
        parameter Real b2=10;
        parameter Real c2=-31;
        Real x2(start=1,fixed=true);
        input Real u2;
        output Real y2;
    equation
        der(x2) = a2*x2+b2*u2;
        y2=c2*x2+d2*u2;
    end LinearSubSystem2;
    
    model LinearFullSystemNoFeed
        LinearSubSystemNoFeed1 p1;
        LinearSubSystemNoFeed2 p2;
        parameter Real A[2,2] = [p1.a1,0;0,p2.a2];
        parameter Real B[2,2] = [p1.b1,0;0,p2.b2];
        parameter Real C[2,2] = [p1.c1,0;0,p2.c2];
    equation
        p1.u1 = p2.y2;
        p1.y1 = p2.u2;
    end LinearFullSystemNoFeed;

    model LinearSubSystemNoFeed1
        parameter Real a1=-0.9;
        parameter Real b1=0.5;
        parameter Real c1=3;
        Real x1(start=1,fixed=true);
        input Real u1;
        output Real y1;
    equation
        der(x1) = a1*x1+b1*u1;
        y1=c1*x1;
    end LinearSubSystemNoFeed1;
    
    model LinearSubSystemNoFeed2
        parameter Real a2=-1;
        parameter Real b2=10;
        parameter Real c2=-31;
        Real x2(start=1,fixed=true);
        input Real u2;
        output Real y2;
    equation
        der(x2) = a2*x2+b2*u2;
        y2=c2*x2;
    end LinearSubSystemNoFeed2;

end LinearCoSimulation;
