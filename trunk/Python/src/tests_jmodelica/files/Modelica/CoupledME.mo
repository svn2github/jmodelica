
package LinearStability

    model FullSystem
        SubSystem1 p1;
        SubSystem2 p2;
        parameter Real A[2,2] = [p1.a1,0;0,p2.a2];
        parameter Real B[2,2] = [p1.b1,0;0,p2.b2];
        parameter Real C[2,2] = [p1.c1,0;0,p2.c2];
        parameter Real D[2,2] = [p1.d1,0;0,p2.d2];
    equation
        p1.u1 = p2.y2;
        p1.y1 = p2.u2;
    end FullSystem;

    model SubSystem1
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
    end SubSystem1;
    
    model SubSystem2
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
    end SubSystem2;
    
    model FullSystemWithEvents
        SubSystemWithEvents1 p1;
        SubSystemWithEvents2 p2;
        parameter Real A[2,2] = [p1.a1,0;0,p2.a2];
        parameter Real B[2,2] = [p1.b1,0;0,p2.b2];
        parameter Real C[2,2] = [p1.c1,0;0,p2.c2];
        parameter Real D[2,2] = [p1.d1,0;0,p2.d2];
    equation
        p1.u1 = p2.y2;
        p1.y1 = p2.u2;
    end FullSystemWithEvents;
    
    model SubSystemWithEvents1
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
    end SubSystemWithEvents1;
    
    model SubSystemWithEvents2
        parameter Real d2=-0.9;
        parameter Real a2=-1;
        parameter Real b2=10;
        parameter Real c2=-31;
        Real x2(start=1,fixed=true);
        input Real u2;
        output Real y2;
    equation
        der(x2) = a2*x2+b2*u2;
        y2=c2*x2;
        
        when time > 0.5 then
            reinit(x2, 3);
        end when;
    end SubSystemWithEvents2;

    model FullSystemWithEvents_v2
        SubSystemWithEvents1_v2 p1;
        SubSystemWithEvents2_v2 p2;
        parameter Real A[2,2] = [p1.a1,0;0,p2.a2];
        parameter Real B[2,2] = [p1.b1,0;0,p2.b2];
        parameter Real C[2,2] = [p1.c1,0;0,p2.c2];
        parameter Real D[2,2] = [p1.d1,0;0,p2.d2];
    equation
        p1.u1 = p2.y2;
        p1.y1 = p2.u2;
    end FullSystemWithEvents_v2;
    
    model SubSystemWithEvents1_v2
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
        
        when y1 > 1.4 then
            reinit(x1, 2);
        end when;
    end SubSystemWithEvents1_v2;
    
    model SubSystemWithEvents2_v2
        parameter Real d2=-0.9;
        parameter Real a2=-1;
        parameter Real b2=1.1;
        parameter Real c2=-0.31;
        Real x2(start=6,fixed=true);
        input Real u2;
        output Real y2;
    equation
        der(x2) = a2*x2+b2*u2;
        y2=c2*x2;
        
        when time > 0.1 then
            reinit(x2, 3);
        end when;
    end SubSystemWithEvents2_v2;


end LinearStability;


package QuarterCar
    
    partial model data
        parameter Real m_wheel = 40;
        parameter Real m_chassi = 400;
        parameter Real k_wheel = 150000;
        parameter Real k_chassi = 15000;
        parameter Real d_wheel = 0;
        parameter Real d_chassi = 1000;
    end data;
    
    model QuarterCarComplete
        extends data;
        
        Real x_chassi(start = 0.0);
        Real v_chassi(start = 0.0);
        Real x_wheel(start = 0.0);
        Real v_wheel(start = 0.0);
        
    equation
        der(x_chassi) = v_chassi;
        m_chassi*der(v_chassi)=k_chassi*(x_wheel-x_chassi)+d_chassi*(v_wheel-v_chassi);
        
        der(x_wheel) = v_wheel;
        m_wheel*der(v_wheel)=k_wheel*(0.1-x_wheel)+d_wheel*(0-v_wheel)-k_chassi*(x_wheel-x_chassi)-d_chassi*(v_wheel-v_chassi);
        
    end QuarterCarComplete;
    
    model QuarterCarWithoutFeedThrough1
        extends data;
        output Real x_chassi(start = 0.0);
        output Real v_chassi(start = 0.0);
        
        input Real x_wheel;
        input Real v_wheel;
        
    equation
    
        der(x_chassi) = v_chassi;
        m_chassi*der(v_chassi)=k_chassi*(x_wheel-x_chassi)+d_chassi*(v_wheel-v_chassi);
        
    end QuarterCarWithoutFeedThrough1;
    
    model QuarterCarWithoutFeedThrough2
        extends data;
        output Real x_wheel(start = 0.0);
        output Real v_wheel(start = 0.0);
        
        input Real x_chassi;
        input Real v_chassi;
        
    equation
        der(x_wheel) = v_wheel;
        m_wheel*der(v_wheel)=k_wheel*(0.1-x_wheel)+d_wheel*(0-v_wheel)-k_chassi*(x_wheel-x_chassi)-d_chassi*(v_wheel-v_chassi);
        
    
    end QuarterCarWithoutFeedThrough2;
    
    model QuarterCarFeedThrough1
        extends data;
        Real x_chassi(start = 0.0);
        Real v_chassi(start = 0.0);
        
        input Real u1;
        
    equation
    
        der(x_chassi) = v_chassi;
        //m_chassi*der(v_chassi)=k_chassi*(x_wheel-x_chassi)+d_chassi*(v_wheel-v_chassi);
        m_chassi*der(v_chassi)=u1;
        
    end QuarterCarFeedThrough1;
    
    model QuarterCarFeedThrough2
        extends data;
        Real x_wheel(start = 0.0);
        Real v_wheel(start = 0.0);
        
        input Real x_chassi;
        input Real v_chassi;
        
        output Real y2;
        
    equation
        der(x_wheel) = v_wheel;
        m_wheel*der(v_wheel)=k_wheel*(0.1-x_wheel)+d_wheel*(0-v_wheel)-k_chassi*(x_wheel-x_chassi)-d_chassi*(v_wheel-v_chassi);
        
        y2 = k_chassi*(x_wheel-x_chassi)+d_chassi*(v_wheel-v_chassi);
        
    end QuarterCarFeedThrough2;
    
end QuarterCar;

package DoublePendulum
model TopPendula
    constant Real g=9.81;
    parameter Real l1 = 1;
    parameter Real d1 = 0.5;
parameter Real m1=1;
  Real alpha(start = -1.0, fixed=true);
  Real w;
  input Real u1(start=5), u2(start=-16);
  output Real y1,y2;
equation
  w = der(alpha);
  m1*l1^2*der(w) = u1*l1*cos(alpha)+(u2-m1*g)*l1*sin(alpha)-d1*w;

  y1 = cos(alpha)*1/m1*(u1*cos(alpha)+(u2-m1*g)*sin(alpha))-sin(alpha)*w^2*l1;
y2 = sin(alpha)*1/m1*(u1*cos(alpha)+(u2-m1*g)*sin(alpha))+cos(alpha)*w^2*l1;

end TopPendula;

model BottomPendula
    constant Real g=9.81;
    parameter Real l2 = 1;
    parameter Real m2=1;
  Real alpha(start = 0.3, fixed=true);
  Real w(start=-3);

  input Real u1, u2;
  output Real y1,y2;
equation
  der(alpha) = w;
  m2*l2^2*der(w) + m2*l2*u1*cos(alpha)+m2*l2*u2*sin(alpha) = -m2*l2*g*sin(alpha);
  y1 = -sin(alpha)*m2*(u1*sin(alpha)-u2*cos(alpha)-l2*w^2-g*cos(alpha));
  y2 = cos(alpha)*m2*(u1*sin(alpha)-u2*cos(alpha)-l2*w^2-g*cos(alpha));

end BottomPendula;

model DoublePendula
    TopPendula pend1;
    BottomPendula pend2;
equation
   pend1.y1 = pend2.u1;
   pend1.y2 = pend2.u2;
   pend2.y1 = pend1.u1;
   pend2.y2 = pend1.u2;
end DoublePendula;

end DoublePendulum;
