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
import numpy.linalg
import scipy.special as SP

try:
    import legendre_polynomials
    legendre_present = True
except:
    legendre_present = False

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

class LegendreGaussRadau:
    """
    Class containing the LGR points which lie on the interval t=(-1,1].
    """
    pass

class LegendreGauss:
    """
    Class containing the LG points which lie on the interval t=(-1,1).
    
    WARNING! This implementation is unstable for K>30 (for scipy 0.7.0). Stable
    for K < 100 for scipy 0.9.0.
    """
    def __init__(self, K):
        
        if legendre_present:
            self.roots = N.zeros((K))
            self.weights = N.zeros((K))
            legendre_polynomials.legzo(self.roots, self.weights, K)
            
            self.roots.sort()
            
            kk = self.roots
            ii = N.append(-1.0, kk)
            
            Pn_k   = N.array([0.0])
            dPn_k  = N.array([0.0])
            ddPn_k = N.array([0.0])
            Pn_i   = N.array([0.0])
            dPn_i  = N.array([0.0])
            ddPn_i = N.array([0.0])
            self.matrix = N.zeros((K,K+1))
            
            #Create the differentiation matrix
            for k in range(len(kk)):
                tk = kk[k]
                legendre_polynomials.lpn(K,tk,Pn_k, dPn_k, ddPn_k)
                for i in range(len(ii)):
                    ti = ii[i]
                    legendre_polynomials.lpn(K,ti,Pn_i, dPn_i, ddPn_i)
                    if i != k+1:
                        self.matrix[k,i] = ( (1.0+tk)*dPn_k + Pn_k ) / ( (tk-ti)*( (1.0+ti)*dPn_i + Pn_i ) )
                    else:
                        self.matrix[k,i] = ( (1.0+ti)*ddPn_i + 2.0*dPn_i ) / ( 2.0*( (1.0+ti)*dPn_i + Pn_i )  )
                    #print k,i,tk,ti,self.matrix[k,i]
            
        else:
            Pn = SP.legendre(K)
            dPn = Pn.deriv()
            ddPn = dPn.deriv()
            
            #dPn = 1.0/2.0*(K+1)*SP.jacobi(K-1,1,1)
            #ddPn = 1.0/4.0*(K+1)*(K+2)*SP.jacobi(K-2,2,2)
            
            self.Pn = Pn
            self.dPn = dPn
            self.ddPn = ddPn
            self.roots = Pn.weights[:,0].real
            self.weights = Pn.weights[:,2].real
            self.matrix = N.zeros((K,K+1))

            kk = self.roots
            ii = N.append(-1.0, kk)

            #Create the differentiation matrix
            for k in range(len(kk)):
                for i in range(len(ii)):
                    tk = kk[k]
                    ti = ii[i]
                    if i != k+1:
                        self.matrix[k,i] = ( (1.0+tk)*dPn(tk) + Pn(tk) ) / ( (tk-ti)*( (1.0+ti)*dPn(ti) + Pn(ti) ) )
                    else:
                        self.matrix[k,i] = ( (1.0+ti)*ddPn(ti) + 2.0*dPn(ti) ) / ( 2.0*( (1.0+ti)*dPn(ti) + Pn(ti) )  )
                    #print k,i,tk,ti,self.matrix[k,i]
            
    def get_roots(self):
        """
        These are the collocation points which all lie in the interval (-1,1)
        """
        return self.roots
        
    def get_discretization_points(self):
        """
        The discretization points includes both t0 = -1.0 and tf = 1.0.
        """
        return N.append(N.append(-1.0, self.roots), 1.0)
        
    def get_approximation_polynomials(self):
        """
        The approximation is based on K+1 Lagrange polynomials. The roots of
        a K order Legendre polynomial plus t0=-1.0.
        """
        roots = N.append(-1.0, self.roots)
        return LagrangePol(roots)
    
    def get_legendre_pol(self):
        return self.Pn
        
    def get_lagrange_pol(self):
        return LagrangePol(self.get_roots())
        
    def get_weights(self):
        return self.weights
    
    def get_matrix(self):
        return self.matrix

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
        
def LegendrePn(K, x):
    """
    Calculates the Legendre polynomial of degree K at point x, P_n(x) using
    the recurrence relation:
    
        P_l(x) = (2l-1)/l*x*P_(l-1)(x)-(l-1)/l*P_(l-2)(x)
        
    Reference: http://mathworld.wolfram.com/LegendrePolynomial.html (eq:43)
    """
    p0 = 1.0
    p1 = x
    
    if N==0:
        return p0
    elif N==1:
        return p1
    else:
        for n in range(2,K+1):
            pn = (2*n-1)*x*p1/n-(n-1)*p0/n
            p0 = p1
            p1 = pn
        return pn

def LegendredPn(K, x):
    """
    Calculates the derivative of the Legendre polynomial of degree K
    at point x, P_n'(x) using the relation:
    
        P_n'(x) = (n*P_(n-1)(x)-n*x*P_n)/(1-x^2)
    
    the end points P_n'(-1.0) and P_n'(1.0) are given by:
    
        P_n'(x) = x^(n+1)*n*(n+1)/2.0

    where P_(n-1) and P_n are the Legendre polynomials of degree K-1 and
    N.
    
    Reference: http://mathworld.wolfram.com/LegendrePolynomial.html (eq:44)
    """
    p0 = LegendrePn(K-1, x)
    p1 = LegendrePn(K, x)
    
    if N.abs(x)==1.0:
        pn = x**(K+1)*K*(K+1)/2.0
    else:
        pn = (K*p0-K*x*p1)/(1.0-x**2)
    
    return pn
    
def LegendreddPn(K, x):
    """
    Calculates the second derivative of the Legendre polynomial of degree K
    at point x, P_n''(x) using the relation:

        P_n''(x) = 1/4*(n+1)*(n+2)*P_(n-2)^(2,2)(x)
        
    where P_(n-2)^(2,2)(x) is the K-2 degree Jacobi polynomial with a=2 and
    b=2. The Jacobi polynomial is solved using the recurrence relation:
    
        2l(l+4)(2l+2)*P_l^(2,2)(x) = (2l+2)_3*x*P_(l-1)^(2,2)(x)-2(l+1)^2*(2l+4)P_(l-2)^(2,2)(x)
    
    Reference: http://mathworld.wolfram.com/JacobiPolynomial.html (eq:12, eq:14)
    """
    p0 = 0.0
    p1 = 0.0
    
    if K==0:
        return p0
    elif K==1:
        return p1
    else:
        p0 = 1.0
        p1 = 3.0*x
        if K==2:
            pn=p0
        elif K==3:
            pn=p1
        else:
            for n in range(2, K-1):
                pn = 1.0/(2.0*n*(n+4)*(2*n+2))*((2.0*n+2)*(2.0*n+3.0)*(2.0*n+4.0)*x*p1-2.0*(n+1.0)**2.0*(2.0*n+4.0)*p0)
                p0 = p1
                p1 = pn
    return pn*1.0/4.0*(K+1.0)*(K+2.0)
    
def LegendrePnRoots(K):
    """
    Calculates the K roots of the K degree Legendre polynomial by first
    generating the Jacobi matrix.
    
    For Legendre polynomials the Jacobi matrix is:  
    
            [    0     1/sqrt(3)      0           0    ]
            [1/sqrt(3)     0      2/sqrt(15)      0    ]
            [    0     2/sqrt(15)     0      3/sqrt(35)]
            [    0         0      3/sqrt(35)      0    ]
    
           A(n+1,n) = n/sqrt(4*n^2-1)
           A(n,n+1) = n/sqrt(4*n^2-1)
    """
    supdiag = [i/N.sqrt(4.0*i*i-1) for i in range(1,K)]

    A = N.diag(supdiag, 1)+N.diag(supdiag, -1)
    r = N.linalg.eig(A)[0]
    r.sort()
    return r
    
def LegendredPnRoots(K):
    """
    Calculates K-1 roots of the derivative of the K degree Legendre Polynomial.
    The calculations are performed via generation of a Jacobi Matrix.
    
    
            A(n+1,n) = sqrt( n*(n+2) / ( (2n+1)*(2n+3) )
            A(n,n+1) = sqrt( n*(n+2) / ( (2n+1)*(2n+3) )
            
    Reference: http://mathworld.wolfram.com/JacobiPolynomial.html (eq:11, 12)
    """
    K = K-1
    supdiag = [N.sqrt(i*(i+2.0)/((2.0*i+1.0)*(2.0*i+3.0))) for i in range(1,K)]
    
    A = N.diag(supdiag, 1)+N.diag(supdiag, -1)
    r = N.linalg.eig(A)[0]
    r.sort()
    return r
    
def GaussQuadratureWeights(type, K):
    """
    Calculates the K Gauss quadrature weights for a given type of points. The
    type can either be:
    
        type = "LG" , corresponding to Legendre-Gauss points
        type = "LGL", corresponding to Legendre-Gauss-Lobatto points
        type = "LGR", corresponding to Legendre-Gauss-Radau points
    """
    w = N.zeros(K)
    
    if type == "LG":
        ti = LegendreRoots(K)
        dPn_ti = [LegendredPn(K,x) for x in ti]
        w = [2.0/((1.0-ti[i]**2)*x**2) for i,x in enumerate(dPn_ti)]
    elif type == "LGL":
        pass 
    elif type == "LGR":
        pass
    else:
        raise Exception("Unknown option to Gauss Quadrature.")
                        
    return N.array(w)
