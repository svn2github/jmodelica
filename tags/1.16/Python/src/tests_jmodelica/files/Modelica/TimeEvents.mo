package TimeEvents

    model Basic1
        Real x;
    equation
        if time < 1 then
            der(x) = 1;
        else
            der(x) = -1;
        end if;
    end Basic1;
    
    model Basic2
        Real x;
        parameter Real p = 2;
    equation
        if time < p then
            der(x) = 1;
        else
            der(x) = -1;
        end if;
    end Basic2;
    
    model Basic3
        Real x;
        parameter Real p = 2;
    equation
        if time < p or time < 1.5 then
            der(x) = 1;
        else
            der(x) = -1;
        end if;
    end Basic3;
    
    model Basic4
        Real x;
        parameter Real p = 2;
    initial equation
        x = if time > 0.5 then 1 else 2;
    equation
        der(x) = -1;
    end Basic4;
    
    model Advanced1
        Real x(start = 1);
        Integer i(start=0);
    equation 
        der(x) = -1;
        when {time >= 0.5,time>0.5} then
            i=pre(i)+1;
        end when;
    end Advanced1;
    
    model Advanced2
        Real x(start = 1);
        Integer i(start=0);
    equation 
        der(x) = -1;
        when {time >= 0.5,0.5<time} then
            i=pre(i)+1;
        end when;
    end Advanced2;
    
    model Advanced3
        Real x(start = 1);
        Integer i(start=0);
        Integer j(start=0);
    equation 
        der(x) = -1;
        when {time >= 0.5,0.5<time} then
            i=pre(i)+1;
        end when;
        when {0.5<time} then
            j=pre(j)+1;
        end when;
    end Advanced3;
    
    model Advanced4
        Real x(start = 1);
        Integer i(start=0);
        Integer j(start=0);
    equation 
        der(x) = -1;
        when {time >= 0.5} then
            i=pre(i)+1;
        end when;
        when {0.5<time} then
            j=pre(j)+1;
        end when;
    end Advanced4;
    
    model Mixed1
        Real x(start=0.5);
        parameter Real p = 2;
    equation
        if time < p or time < 1.5 then
            der(x) = if x < 1 then 1 else 0.5;
        else
            der(x) = if x < 1 then -0.5 else -1;
        end if;
    end Mixed1;

end TimeEvents;
