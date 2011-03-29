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
        
def lagrange(R):
    """
    Creates K Lagrange Polynomials given R roots. Returns a vector of Poly1D 
    polynomial.
    
            L_i(t) = PROD_{j=0,j!=i}( (t-t_j) / (t_i - t_j ) )
            
    WARNING: Numerically highly unstable. Consider using "lagrange_eval"
    """
    K = len(R)
    L = []
    
    for i in range(K):
        p = 1.0
        for j in range(K):
            if i==j:
                continue
            else:
                p = p*SP.poly1d([1.0, -R[j]])/(R[i]-R[j])
        L += [p]
    return L

def lagrange_eval(R, i, x):
    """
    Evaluates the i:th Lagrange polynomial based on the roots, R at point x.
    
        L_i(t) = PROD_{j=0,j!=i}( (x-t_j) / (t_i - t_j ) )
    """
    val = N.array(1.0)
    
    K = len(R)
    
    for j in range(K):
        if j==i:
            continue
        else:
            val *= (x-R[j])/(R[i]-R[j])
    return val

def legendre_Pn(K, x):
    """
    Calculates the Legendre polynomial of degree K at point x, P_n(x) using
    the recurrence relation:
    
        P_l(x) = (2l-1)/l*x*P_(l-1)(x)-(l-1)/l*P_(l-2)(x)
        
    Reference: http://mathworld.wolfram.com/LegendrePolynomial.html (eq:43)
    """
    p0 = N.array(1.0)
    p1 = N.array(x)
    
    if K==0:
        return p0
    elif K==1:
        return p1
    else:
        for n in range(2,K+1):
            pn = (2*n-1)*x*p1/n-(n-1)*p0/n
            p0 = p1
            p1 = pn
        return pn

def legendre_dPn(K, x):
    """
    Calculates the derivative of the Legendre polynomial of degree K
    at point x, P_n'(x) using the relation:
    
        P_n'(x) = (n*P_(n-1)(x)-n*x*P_n)/(1-x^2)
    
    the end points P_n'(-1.0) and P_n'(1.0) are given by:
    
        P_n'(x) = x^(n+1)*n*(n+1)/2.0

    where P_(n-1) and P_n are the Legendre polynomials of degree K-1 and
    K.
    
    Reference: http://mathworld.wolfram.com/LegendrePolynomial.html (eq:44)
    """
    p0 = legendre_Pn(K-1, x)
    p1 = legendre_Pn(K, x)
    
    if N.abs(x)==1.0:
        pn = x**(K+1)*K*(K+1)/2.0
    else:
        pn = (K*p0-K*x*p1)/(1.0-x**2)
    
    return pn
    
def legendre_ddPn(K, x):
    """
    Calculates the second derivative of the Legendre polynomial of degree K
    at point x, P_n''(x) using the relation:

        P_n''(x) = 1/4*(n+1)*(n+2)*P_(n-2)^(2,2)(x)
        
    where P_(n-2)^(2,2)(x) is the K-2 degree Jacobi polynomial with a=2 and
    b=2. The Jacobi polynomial is solved using the recurrence relation:
    
        2l(l+4)(2l+2)*P_l^(2,2)(x) = (2l+2)_3*x*P_(l-1)^(2,2)(x)-2(l+1)^2*(2l+4)P_(l-2)^(2,2)(x)
    
    Reference: http://mathworld.wolfram.com/JacobiPolynomial.html (eq:12, eq:14)
    """
    p0 = N.array(0.0)
    p1 = N.array(0.0)
    
    if K==0:
        return p0
    elif K==1:
        return p1
    else:
        p0 = N.array(1.0)
        p1 = N.array(3.0*x)
        if K==2:
            pn=p0
        elif K==3:
            pn=p1
        else:
            for n in range(2, K-1):
                pn = 1.0/(2.0*n*(n+4.0)*(2.0*n+2.0))*((2.0*n+2.0)*(2.0*n+3.0)*(2.0*n+4.0)*x*p1-2.0*(n+1.0)**2.0*(2.0*n+4.0)*p0)
                p0 = p1
                p1 = pn
                
    return pn*1.0/4.0*(K+1.0)*(K+2.0)
    
def legendre_Pn_roots(K):
    """
    Calculates the K roots of the K degree Legendre polynomial by first
    generating the Jacobi matrix.
    
    For a degree 4 Legendre polynomial the Jacobi matrix is:  
    
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
    
def legendre_dPn_roots(K):
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

def jacobi_a1_b0_roots(K):
    """
    Calculates the K roots of the K degree Jacobi (a=1,b=0) Polynomial. The
    calculations are performed via generation of a Jacobi Matrix.
    
            A(n+1,n) = sqrt( n*(n+1) )/ ( (2n+1) )
            A(n,n+1) = sqrt( n*(n+1) )/ ( (2n+1) )
            B(n,n)   = -1 / ( (2n+1)*(2n+3)  )
    
    Reference: http://mathworld.wolfram.com/JacobiPolynomial.html (eq:11, 12) 
    """
    A = [1.0/(2.0*i+1.0)*N.sqrt(i*(i+1.0)) for i in range(1,K)]
    B = [-1.0/((2.0*i+1.0)*(2.0*i+3.0)) for i in range(0,K)]
     
    M = N.diag(A, 1)+N.diag(A, -1)+N.diag(B)
    r = N.linalg.eig(M)[0]
    r.sort()
    return r

def differentiation_matrix(type, K):
    """
    Calculates the differentiation matrix for the given type of collocation
    points. 
    
        D_ki = d/dt L_i(t_k) where k=1,..,K and i=1,...,M
        
    where K are the collocation points and M are the number of points used
    in the approximation of the states. L are lagrange polynomials.
    
    The type can either be:
    
        type = "Gauss", generates the differentiation matrix for the Gauss
                        Pseudospectral method. M = K + 1
                        
            D_ki = { i!=k   ( (1+t_k) * dP_K(t_k) + P_K(t_k) ) / 
                            ( (t_k-t_i) * ( (1+t_i) * dP_K(t_i) + P_K(t_i) ) )
                     
                   { i==k   ( (1+t_i) * ddP_K(t_i) + 2 * dP_K(t_i) ) /
                            ( 2 * ( (1+t_i)*dP_K(t_i) + P_K(t_i) ) )
                            
        type = "Legendre", generates the differentiation matrix for the Legendre
                           Pseudospectral method. M = K
                           
            D_ki = { i!=k      P_(K-1)(t_k)/P_(K-1)(t_i) * 1 / (t_k - t_i)
                   
                   { k==i==1   - (K-1) * K / 4
                   
                   { k==i==K     (K-1) * K / 4
                   
                   { else        0.0
                   
        type = "Radau", generates the differentiation matrix for the Radau 
                        Pseudospectral method (flipped LGR points). M = K+1
                        
            D_ki = { i!=k  ( (1+t_k) * ( dP_K(t_k) - dP_{K-1}(t_k) ) + P_K(t_k) - P_{K-1}(t_k) ) / 
                           ( (t_k-t_i) * ( (1+t_i) * ( dP_K(t_i) - dP_{K-1}(t_i) ) + P_K(t_i) - P_{K-1}(t_k) ) )
                           
                   { i==k  ( (1+t_i) * ( ddP_K(t_i) - ddP_{K-1}(t_i) ) + 2 * dP_K(t_i) - 2 * dP_{K-1}(t_i) ) /
                           ( 2 * ( (1+t_i) * ( dP_K(t_i) - dP_{K-1}(t_i) ) + P_K(t_i) - P_{K-1}(t_k) ) )
    """
    if type == "Gauss":
        M = K+1
        D = N.zeros((K,M))
        
        kk = legendre_Pn_roots(K)
        ii = N.append(-1.0, kk)
        
        Pn_k   = [legendre_Pn(K, x) for x in ii]
        dPn_k  = [legendre_dPn(K, x) for x in ii]
        ddPn_k = [legendre_ddPn(K, x) for x in ii]
        
        for k in range(K):
            tk = kk[k]
            for i in range(M):
                ti = ii[i]
                if i != k+1:
                    D[k,i] = ( (1.0+tk)*dPn_k[k+1] + Pn_k[k+1] ) / ( (tk-ti)*( (1.0+ti)*dPn_k[i] + Pn_k[i] ) )
                else:
                    D[k,i] = ( (1.0+ti)*ddPn_k[i] + 2.0*dPn_k[i] ) / ( 2.0*( (1.0+ti)*dPn_k[i] + Pn_k[i] )  )
    
    elif type == "Legendre":
        M = K
        D = N.zeros((K,M))
        
        kk = N.append(N.append(-1.0, legendre_dPn_roots(K-1)), 1.0)
        ii = kk
        
        Pn_k   = [legendre_Pn(K-1, x) for x in ii]
        
        for k in range(K):
            tk = kk[k]
            for i in range(M):
                ti = ii[i]
                if i != k:
                    D[k,i] = Pn_k[k]/Pn_k[i] * 1.0 / (tk-ti)
                elif k==0 and i==0:
                    D[k,i] = -(K-1)*K / 4.0
                elif k+1==K and i+1 ==K:
                    D[k,i] =  (K-1)*K / 4.0
                else:
                    D[k,i] = 0.0
    
    elif type == "Radau":
        M = K+1
        D = N.zeros((K,M))
        
        kk = N.append(jacobi_a1_b0_roots(K-1), 1.0)
        ii = N.append(-1.0, kk)
        
        Pn_k   = [legendre_Pn(K, x)-legendre_Pn(K-1, x) for x in ii]
        dPn_k  = [legendre_dPn(K, x)-legendre_dPn(K-1, x) for x in ii]
        ddPn_k = [legendre_ddPn(K, x)-legendre_ddPn(K-1, x) for x in ii]
        
        for k in range(K):
            tk = kk[k]
            for i in range(M):
                ti = ii[i]
                if i != k+1:
                    D[k,i] = ( (1.0+tk)*dPn_k[k+1] + Pn_k[k+1] ) / ( (tk-ti)*( (1.0+ti)*dPn_k[i] + Pn_k[i] ) )
                else:
                    D[k,i] = ( (1.0+ti)*ddPn_k[i] + 2.0*dPn_k[i] ) / ( 2.0*( (1.0+ti)*dPn_k[i] + Pn_k[i] )  )
    
    else:
        raise Exception("Unknown option to differentiation_matrix.")
        
    return D
    
def gauss_quadrature_weights(type, K):
    """
    Calculates the K Gauss quadrature weights for a given type of points. The
    type can either be:
    
        type = "LG" , corresponding to Legendre-Gauss points
            
            - Weights are calculated for the K Legendre-Gauss points as:
                
                w_i = 2 / ( (1-ti^2)*dP_n(ti)^2 ), [i=1,...,K]
                
        type = "LGL", corresponding to Legendre-Gauss-Lobatto points
        
            - Weights are calculated for the K Legendre-Gauss-Lobatto points
              as:
              
                w_i = 2 / ( K (K-1) ) * 1 / ( P_(n-1)(ti)^2 ), [i=1,...,K]
              
        type = "LGR", corresponding to (flipped) Legendre-Gauss-Radau points,
                      i.e the end point 1 is included instead of -1.
                      
            - Weights are calculated for the K Legendre-Gauss-Radau points as:
                
                w_i = 1 / ( (1-ti)*dP_n(ti)^2 ), [i=1,..,K-1]
                w_K = 2 / K^2
    """
    w = N.zeros(K)
    
    if type == "LG":
        ti = legendre_Pn_roots(K)
        dPn_ti = [legendre_dPn(K,x) for x in ti]
        w = [2.0/((1.0-ti[i]**2)*x**2) for i,x in enumerate(dPn_ti)]
        
    elif type == "LGL":
        ti = N.append(N.append(-1.0, legendre_dPn_roots(K-1)), 1.0)
        Pn_ti = [legendre_Pn(K-1, x) for x in ti]
        w = [2.0/(K*(K-1))*1.0/x**2 for x in Pn_ti]
        
    elif type == "LGR":
        ti = jacobi_a1_b0_roots(K-1)
        dPn_ti = [legendre_dPn(K-1, x) for x in ti]
        w = [1.0/((1.0+ti[i])*x**2) for i,x in enumerate(dPn_ti)]
        w += [N.array(2.0/K**2)]
        
    else:
        raise Exception("Unknown option to Gauss Quadrature.")
                        
    return N.array(w)
