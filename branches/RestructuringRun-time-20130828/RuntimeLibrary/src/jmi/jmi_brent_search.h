#ifndef JMI_BRENT_SEARCH_H
#define JMI_BRENT_SEARCH_H

/* A C89 implementation of zero() from
    Brent R.P.:
    Algorithms for Minimization without derivatives. Prentice Hall, 1973, pp. 58-59.
    Download: http://wwwmaths.anu.edu.au/~brent/pd/rpb011i.pdf
    Errata and new print: http://wwwmaths.anu.edu.au/~brent/pub/pub011.html 
*/
#include <sundials/sundials_types.h>
#include <sundials/sundials_math.h>

typedef int (*jmi_brent_func_t)(realtype u, realtype* f, void* data);

typedef enum {
    JMI_BRENT_BAD_PARAM = -10    

    
} JMI_BRENT_CODES;

/* 
    \brief Solve scalar equation f(u) = 0 in a very reliable and efficient way 
        (u_min < u_max; f(u_min) and f(u_max) must have different signs).
    
    @param f        The function to search for the root.
    @param u_min    Lower bound  of search intervall
    @param u_max    Upper bound of search intervall
    @param f_min    f(u_min), both input and output
    @param f_max    f(u_max), both input and output
    @param tolerance      Relative tolerance for u
    @param u_out    Solution or best guess
    @param f_out    Residual at u_out
    @param data    user data propagated to the function
    @return Error flag (forwarded from the call to f())    
 */
int jmi_brent_search(jmi_brent_func_t f, realtype u_min, realtype u_max, realtype f_min, realtype f_max, realtype tolerance, realtype* u_out, realtype* f_out,void *data) {
    realtype a=u_min; /* left point */
    realtype fa = f_min;
    realtype b=u_max; /* right point */
    realtype fb = f_max;
    realtype c = u_min; /* Intermediate point a <= c <= b */
    realtype fc = f_min;
    realtype e= u_max - u_min;
    realtype d=e;
    realtype m;
    realtype s;
    realtype p;
    realtype q;
    realtype r;
    realtype tol; /* absolute tolerance for the current "b" */
    int flag;
#ifdef DEBUG
    if(fa*fb > 0) {
        return JMI_BRENT_BAD_PARAM;
    }
#endif
    while(1) {
        if(RAbs(fc) < RAbs(fb)) {
            a = b;
            b = c;
            c = a;
            fa = fb;
            fb = fc;
            fc = fa;
        }
        tol = 2*UNIT_ROUNDOFF*RAbs(b) + tolerance;
        m = (c - b)/2;
        
        if((RAbs(m) <= tol) || (fb == 0.0)) {
            /* root found (interval is small enough) */
            if(RAbs(fb) < RAbs(fc)) {
                *u_out = b;
                *f_out = fb;
            }
            else {
                *u_out = c;
                *f_out = fc;
            }
            return 0;
        }
        /* Find the new point: */
        /* Determine if a bisection is needed */
        if((RAbs(e) < tol) || ( RAbs(fa) <= RAbs(fb))) {
            e = m;
            d = e;
        }
        else {
            s = fb/fa;
            if(a == c) {
                /* linear interpolation */
                p = 2*m*s;
                q = 1 - s;
            }
            else {
                /* inverse quadratic interpolation */
                q = fa/fc;
                r = fb/fc;
                p = s*(2*m*q*(q - r) - (b - a)*(r - 1));
                q = (q - 1)*(r - 1)*(s - 1);
            }
            if(p > 0) 
                q = -q;
            else
                p = -p;
            s = e;
            e = d;
            
            if(( 2*p < 3*m*q - RAbs(tol*q)) && (p < RAbs(0.5*s*q)))
                /* interpolation successful */
                d = p/q;
            else {
                /* use bi-section */
                e = m;
                d = e;
            }
        }
        
        
        /* Best guess value is saved into "a" */
        a = b;
        fa = fb;
        b = b + ((RAbs(d) > tol) ? d : ((m > 0) ? tol: -tol));
        flag = f(b, &fb, data);
        if(flag) {
             if(RAbs(fa) < RAbs(fc)) {
                *u_out = a;
                *f_out = fa;
            }
            else {
                *u_out = c;
                *f_out = fc;
            }
            return flag;
        }

        if(fb * fc  > 0) {
            /* initialize variables */
            c = a;
            fc = fa;
            e = b - a;
            d = e;
        }
    }
}
#endif /* JMI_BRENT_SEARCH_H */
