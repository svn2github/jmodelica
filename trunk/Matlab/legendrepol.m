function l = legendrepol(deg)
% LEGENDREPOL Calculate a Legendre polynomial.
% L = LEGENDREPOL(DEG) gives the coefficients of a Legendre polynomial 
% of degree DEG.
%
%  Input arguments:
%  DEG       Polynomial degree.
% 
%  Output arguments:
%  P         Polynomial coefficients.
%
% See also: LAGRANGEPOL
%

l = zeros(1,deg+1);

if (deg==0)
  l(deg+1) = 1;
else
  for k=0:floor(deg/2),
    l(1+2*k) = 1/2^deg*(-1)^k*factorial(2*deg-2*k)/ ...
        (factorial(k)*factorial(deg-k)*factorial(deg-2*k));
  end
end


