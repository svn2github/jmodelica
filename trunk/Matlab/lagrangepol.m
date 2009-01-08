function p = lagrangepol(deg,tau)
% LAGRANGEPOL Calculation of Lagrange polynomials.
% P = LAGRANGEPOL(DEG,TAU) gives Lagrange polynomials in a cell array P.
% The resulting P then contains the DEG+1 Lagrange polynomials 
% accessible by P{1}..P{DEG+1}.
%
%  Input arguments:
%  DEG       Degree of the lagrange polynomials
%  TAU       Normalized points where one of the polynomials are
%            equal to 1 and the others are equal to 0.
%
%  Output arguments:
%  P         Cell array containing polynomials.
%
% See also: LEGENDREPOL, GENRADAULAGRANGEBASIS
%

if and(length(tau)-1~=deg,deg>0)
  
  error('The tau vector must contain deg+1 elements')
  
end

if deg>0,
  for k=1:deg+1,
    
    p{k} = 1;
    
    for j=1:deg+1,
      
      if k~=j,
	p{k} = conv(p{k},[1 -tau(j)])/(tau(k)-tau(j));
      end
      
    end
    
  end
  
else
  p{1} = 1;
end
