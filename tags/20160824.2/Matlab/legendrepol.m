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

%    Copyright (C) 2009 Modelon AB
%
%    This program is free software: you can redistribute it and/or modify
%    it under the terms of the GNU General Public License as published by
%    the Free Software Foundation, version 3 of the License.
%
%    This program is distributed in the hope that it will be useful,
%    but WITHOUT ANY WARRANTY; without even the implied warranty of
%    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%    GNU General Public License for more details.
%
%    You should have received a copy of the GNU General Public License
%    along with this program.  If not, see <http://www.gnu.org/licenses/>.


l = zeros(1,deg+1);

if (deg==0)
  l(deg+1) = 1;
else
  for k=0:floor(deg/2),
    l(1+2*k) = 1/2^deg*(-1)^k*factorial(2*deg-2*k)/ ...
        (factorial(k)*factorial(deg-k)*factorial(deg-2*k));
  end
end


