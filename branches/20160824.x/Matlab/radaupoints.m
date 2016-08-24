function [p,w] = radaupoints(deg)
% [P,W]=RADAUPOINTS(DEG) Computes DEG Radau points in the interval [0 1].
%
%  Input arguments:
%  DEG       Number of Points.
%
%  Output arguments:
%  P         The Radau points.
%  W         Weights for integral approximation.
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


[r p k] = residue(legendrepol(deg)+[0 legendrepol(deg-1)],[1 1]);

p = [roots(k)];

Pp = polyder(legendrepol(deg-1));
w = conv([-1 1],conv(Pp,Pp));

w = 1./polyval(w,p);
w = [2/deg^2;w];
p = [-1;p];

% scale from [-1 1] to [0 1]
p(1) = 0;
p(2:deg) = (p(2:deg)+1)/2;
w = w/2;

% reverse interval
p = 1-p;

Q = sortrows([p w],1);

p = Q(:,1);
w = Q(:,2);
