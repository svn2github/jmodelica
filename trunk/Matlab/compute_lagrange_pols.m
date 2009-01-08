
cp_max = 10;

for i=1:cp_max,
   cp{i} = radaupoints(i); 
   cpp{i} = [0; radaupoints(i)];
   Lp{i} = lagrangepol(i-1,cp{i});
   Lpp{i} = lagrangepol(i,[0; cp{i}]);
end

fprintf('// Radau points\n');
for i=1:cp_max,
    fprintf('static jmi_real_t jmi_opt_sim_lp_radau_%d[%d] = {',i,i);
    for j=1:i,
        fprintf('%5.16e',cp{i}(j));
        if (j~=i),
             fprintf(',\n                                               ');
        end
    end;
    fprintf('};\n\n');
end;
    
fprintf('// Lagrange polynomial coefficients. Lagrange polynomials based on\n');
fprintf('// Radau points. The first index denotes polynomial\n');
fprintf('// and the second index denotes coefficient.\n');
for i=1:cp_max,
    fprintf('static jmi_real_t jmi_opt_sim_lp_radau_coeffs_%d[%d][%d] = {',i,i,i);
    for j=1:i,
        fprintf('{');
        for k=1:i,
            fprintf('%5.16e',Lp{i}{j}(k));
            if (k~=i),
               fprintf(', ');
            end
        end
        fprintf('}');
        if (j~=i),
               fprintf(',\n                                                   ');
        end
     end;
    fprintf('};\n\n');
end;

for i=1:cp_max,
    fprintf('static jmi_real_t jmi_opt_sim_lp_radau_dot_coeffs_%d[%d][%d] = {',i,i,i);
    for j=1:i,
        fprintf('{');
        for k=1:i,
            Lp_dot = [0 polyder(Lp{i}{j})];
            fprintf('%5.16e',Lp_dot(k));
            if (k~=i),
               fprintf(', ');
            end
        end
        fprintf('}');
        if (j~=i),
               fprintf(',\n                                                       ');
        end
     end;
    fprintf('};\n\n');
end;

for i=1:cp_max,
    fprintf('static jmi_real_t jmi_opt_sim_lp_radau_dot_vals_%d[%d][%d] = {',i,i,i);
    for j=1:i,
        fprintf('{');
        for k=1:i,
            Lp_dot = [0 polyder(Lp{i}{j})];
            fprintf('%5.16e',polyval(Lp_dot,cp{i}(k)));
            if (k~=i),
               fprintf(', ');
            end
        end
        fprintf('}');
        if (j~=i),
               fprintf(',\n                                                       ');
        end
     end;
    fprintf('};\n\n');
end;

fprintf('// Radau points plus starting point of interval (0)\n');
for i=1:cp_max,
    fprintf('static jmi_real_t jmi_opt_sim_lp_radau_p_%d[%d] = {',i,i+1);
    for j=1:i+1,
        fprintf('%5.16e',cpp{i}(j));
        if (j~=i+1),
             fprintf(',\n                                               ');
        end
    end;
    fprintf('};\n\n');
end;
    

fprintf('// Lagrange polynomial coefficients. Lagrange polynomials based on\n');
fprintf('// Radau points plus the beginning of the interval. The first index\n');
fprintf('// denotes polynomial and the second index denotes coefficient.\n');
for i=1:cp_max,
    fprintf('static jmi_real_t jmi_opt_sim_lpp_radau_coeffs_%d[%d][%d] = {',i+1,i+1,i+1);
    for j=1:i+1,
        fprintf('{');
        for k=1:i+1,
            fprintf('%5.16e',Lpp{i}{j}(k));
            if (k~=i+1),
               fprintf(', ');
            end
        end
        fprintf('}');
        if (j~=i+1),
               fprintf(',\n                                                   ');
        end
     end;
    fprintf('};\n\n');
end;

for i=1:cp_max,
    fprintf('static jmi_real_t jmi_opt_sim_lpp_radau_dot_coeffs_%d[%d][%d] = {',i+1,i+1,i+1);
    for j=1:i+1,
        fprintf('{');
        for k=1:i+1,
            Lpp_dot = [0 polyder(Lpp{i}{j})];
            fprintf('%5.16e',Lpp_dot(k));
            if (k~=i+1),
               fprintf(', ');
            end
        end
        fprintf('}');
        if (j~=i+1),
               fprintf(',\n                                                       ');
        end
     end;
    fprintf('};\n\n');
end;

for i=1:cp_max,
    fprintf('static jmi_real_t jmi_opt_sim_lpp_radau_dot_vals_%d[%d][%d] = {',i+1,i+1,i+1);
    for j=1:i+1,
        fprintf('{');
        for k=1:i+1,
            Lpp_dot = [0 polyder(Lpp{i}{j})];
            fprintf('%5.16e',polyval(Lpp_dot,cpp{i}(k)));
            if (k~=i+1),
               fprintf(', ');
            end
        end
        fprintf('}');
        if (j~=i+1),
               fprintf(',\n                                                       ');
        end
     end;
    fprintf('};\n\n');
end;

    

