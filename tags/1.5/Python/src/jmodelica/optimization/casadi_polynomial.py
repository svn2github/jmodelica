#!/usr/bin/env python 
# -*- coding: utf-8 -*-

#    Copyright (C) 2011 Modelon AB
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, version 3 of the License.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.
"""
Module containing the polynomials for the Casadi collocation algorithms.
"""

import numpy as N
import scipy.special as SP

class RadauPol:

    def eval_lp(self,i,x):
        val = 0
        for j in range(self.n):
            val += self.lp_coeffs()[i,j]*(x**(self.n-j-1))
        return val

    def eval_lpp(self,i,x):
        val = 0
        for j in range(self.n+1):
            val += self.lp_coeffs()[i,j]*(x**(self.n-j))
        return val

class RadauPol3(RadauPol):

    def __init__(self):
        self.n = 3

    def p(self):
        return N.array([1.5505102572168217e-01,
                        6.4494897427831788e-01,
                        1.0000000000000000e+00])

    def w(self):
        return N.array([3.7640306270046731e-01,
                        5.1248582618842153e-01,
                        1.1111111111111110e-01])

    def lp_coeffs(self):
        return N.array([[2.4158162379719630e+00, -3.9738944426968859e+00, 1.5580782047249224e+00],
                        [-5.7491495713052974e+00, 6.6405611093635519e+00, -8.9141153805825557e-01],
                        [3.3333333333333339e+00, -2.6666666666666674e+00, 3.3333333333333337e-01]])

    def lp_dot_coeffs(self):
        return N.array([[0.0000000000000000e+00, 4.8316324759439260e+00, -3.9738944426968859e+00],
                        [0.0000000000000000e+00, -1.1498299142610595e+01, 6.6405611093635519e+00],
                        [0.0000000000000000e+00, 6.6666666666666679e+00, -2.6666666666666674e+00]])

    def lp_dot_vals(self):
        return N.array([[-3.2247448713915894e+00, -8.5773803324704145e-01, 8.5773803324704012e-01],
                        [4.8577380332470401e+00, -7.7525512860841328e-01, -4.8577380332470428e+00],
                        [-1.6329931618554527e+00, 1.6329931618554530e+00, 4.0000000000000000e+00]])

    def pp(self):
        return N.array([0.0000000000000000e+00,
                        1.5505102572168217e-01,
                        6.4494897427831788e-01,
                        1.0000000000000000e+00])

    def lpp_coeffs(self):
        return N.array([[-1.0000000000000000e+01, 1.8000000000000000e+01, -9.0000000000000000e+00, 1.0000000000000000e+00],
                                                  [1.5580782047249222e+01, -2.5629591447076638e+01, 1.0048809399827414e+01, -0.0000000000000000e+00],
                                                  [-8.9141153805825564e+00, 1.0296258113743304e+01, -1.3821427331607485e+00, -0.0000000000000000e+00],
                                                  [3.3333333333333339e+00, -2.6666666666666674e+00, 3.3333333333333337e-01, 0.0000000000000000e+00]])

    def lpp_dot_coeffs(self):
        return N.array([[0.0000000000000000e+00, -3.0000000000000000e+01, 3.6000000000000000e+01, -9.0000000000000000e+00],
                        [0.0000000000000000e+00, 4.6742346141747667e+01, -5.1259182894153277e+01, 1.0048809399827414e+01],
                        [0.0000000000000000e+00, -2.6742346141747667e+01, 2.0592516227486609e+01, -1.3821427331607485e+00],
                        [0.0000000000000000e+00, 1.0000000000000002e+01, -5.3333333333333348e+00, 3.3333333333333337e-01]])

    def lpp_dot_vals(self):
        return N.array([[-9.0000000000000000e+00, -4.1393876913398140e+00, 1.7393876913398127e+00, -3.0000000000000000e+00],
                        [1.0048809399827414e+01, 3.2247448713915885e+00, -3.5678400846904061e+00, 5.5319726474218047e+00],
                        [-1.3821427331607485e+00, 1.1678400846904053e+00, 7.7525512860840973e-01, -7.5319726474218065e+00],
                        [3.3333333333333337e-01, -2.5319726474218085e-01, 1.0531972647421810e+00, 5.0000000000000000e+00]])

class LegendreGaussLobatto:
    """
    Class containing the LGL points which lie on the interval t=[-1,1].
    
    WARNING! This implementation is unstable for K>30 (for scipy 0.7.0). Stable
    for K < 100 for scipy 0.9.0.
    """
    def __init__(self, K):
        Pn = SP.legendre(K-1)
        Jn = SP.jacobi(K-2, 1, 1)
        dPn = Pn.deriv()
        
        self.Pn = Pn
        self.Jn = Jn
        self.K = K
        
        self.roots = N.append(N.append(-1.0, Jn.weights[:,0]), 1.0).real
        """
        roots = N.roots(dPn)
        roots.sort()
        self.roots = N.append(N.append(-1.0, roots), 1.0)
        """
        self.pol = dPn*SP.poly1d([-1.0,0.0,1.0])*1.0/((K-1)*K)
        """
        weights = []
        for i in range(K):
            weights += [2.0/(K*(K-1.0))*1.0/(self.Pn(self.roots[i])**2)]
        self.weights = weights
        """
        weights = []
        weights += [2.0/(K*(K-1.0))*1.0/(self.Pn(-1.000000)**2)]
        weights += Jn.weights[:,2].real.tolist()
        weights += [2.0/(K*(K-1.0))*1.0/(self.Pn(1.000000)**2)]
        #for i in range(K):
        #    weights += [2.0/(K*(K-1.0))*1.0/(self.Pn(self.roots[i])**2)]
        self.weights = weights
        
        #print self.roots
        #print self.weights
        
        matrix = N.zeros((K,K))
        for k in range(K):
            for i in range(K):
                if k!=i:
                    matrix[k,i] = Pn(self.roots[k])/Pn(self.roots[i])*1.0/(self.roots[k]-self.roots[i])
                elif k==0 and i==0:
                    matrix[k,i] = -(K-1)*K/4.0
                elif k==K-1 and i==K-1:
                    matrix[k,i] = (K-1)*K/4.0
                else:
                    matrix[k,i] = 0.0
        self.matrix = matrix
        
    def get_roots(self):
        return self.roots
    
    def get_pol(self):
        #self.poly = []
        #for i in range(self.K):
        #    self.poly += self.pol*(1.0/self.Pn(self.roots[i]))*(1.0/)
        return self.pol
        
    def get_lagrange_pol(self):
        return LagrangePol(self.get_roots())
        
    def get_weights(self):
        return self.weights
    
    def get_matrix(self):
        return self.matrix

class LagrangePol:
    def __init__(self, roots):
        self.roots = roots
        self.K = len(self.roots)
        self._create_pol()
        
    def _create_pol(self):
        self.L = []
        for i in range(self.K):
            p = 1.0
            for j in range(self.K):
                if i==j:
                    continue
                else:
                    p = p*SP.poly1d([1.0, -self.roots[j]])/(self.roots[i]-self.roots[j])
            self.L += [p]
    
    def get_lagrange_polynomials(self):
        return self.L
