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
