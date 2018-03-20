/*
    Copyright (C) 2016 Modelon AB

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License version 3 as published
    by the Free Software Foundation, or optionally, under the terms of the
    Common Public License version 1.0 as published by IBM.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License, or the Common Public License, for more details.

    You should have received copies of the GNU General Public License
    and the Common Public License along with this program.  If not,
    see <http://www.gnu.org/licenses/> or
    <http://www.ibm.com/developerworks/library/os-cpl.html/> respectively.
*/

#include "jmi.h"
#include "jmi_math.h"
#include "jmi_math_ad.h"

/*
FLogExp -> Use the regular divide method (using AD though)
FDotDivExp -> Use the regular divide method (using AD though)
FSinhExp -> use call to jmi_cosh
FCoshExp -> use call to jmi_sinh
FLog10Exp -> use regular divide method (using AD though)
* 
* acos / asin / atan2 / sqrt / pow
*/

void jmi_ad_sqrt_function(const char func_name[], jmi_real_t x, jmi_real_t dx, jmi_real_t* v, jmi_real_t* d, const char msg[]) {
    jmi_ad_sqrt(NULL, func_name, x, dx, v, d, msg);
}

void jmi_ad_sqrt_equation(jmi_t *jmi, jmi_real_t x, jmi_real_t dx, jmi_real_t* v, jmi_real_t* d, const char msg[]) {
    jmi_ad_sqrt(jmi, NULL, x, dx, v, d, msg);
}

void jmi_ad_sqrt(jmi_t *jmi, const char func_name[], jmi_real_t x, jmi_real_t dx, jmi_real_t* v, jmi_real_t* d, const char msg[]) {
    *v = sqrt(x);
    
    if (x < 0.0) {
        /* Range problem, will return NAN */
        char val[64];
        sprintf(val, "%.14E", x);
        jmi_log_func_or_eq(jmi, "RangeError", func_name, msg, val);
    }
    if (x <= 0.0) {
        *d = 0.0;
    } else {
        *d = dx / ( 2 * *v);
    }
}


void jmi_ad_asin_function(const char func_name[], jmi_real_t x, jmi_real_t dx, jmi_real_t* v, jmi_real_t* d, const char msg[]) {
    jmi_ad_asin(NULL, func_name, x, dx, v, d, msg);
}

void jmi_ad_asin_equation(jmi_t *jmi, jmi_real_t x, jmi_real_t dx, jmi_real_t* v, jmi_real_t* d, const char msg[]) {
    jmi_ad_asin(jmi, NULL, x, dx, v, d, msg);
}

void jmi_ad_asin(jmi_t *jmi, const char func_name[], jmi_real_t x, jmi_real_t dx, jmi_real_t* v, jmi_real_t* d, const char msg[]) {
    *v = asin(x);
    
    if (*v - *v != 0.0) { /* Nan */
        char val[64];
        sprintf(val, "%.14E", x);
        jmi_log_func_or_eq(jmi, "RangeError", func_name, msg, val);
    }
    
    if (x <= -1.0 || x >= 1.0) {
        *d = 0.0;
    } else {
        *d = dx/sqrt(1 - x*x);
    }
}

void jmi_ad_acos_function(const char func_name[], jmi_real_t x, jmi_real_t dx, jmi_real_t* v, jmi_real_t* d, const char msg[]) {
    jmi_ad_acos(NULL, func_name, x, dx, v, d, msg);
}

void jmi_ad_acos_equation(jmi_t *jmi, jmi_real_t x, jmi_real_t dx, jmi_real_t* v, jmi_real_t* d, const char msg[]) {
    jmi_ad_acos(jmi, NULL, x, dx, v, d, msg);
}

void jmi_ad_acos(jmi_t *jmi, const char func_name[], jmi_real_t x, jmi_real_t dx, jmi_real_t* v, jmi_real_t* d, const char msg[]) {
    *v = acos(x);
    
    if (*v - *v != 0.0) { /* Nan */
        char val[64];
        sprintf(val, "%.14E", x);
        jmi_log_func_or_eq(jmi, "RangeError", func_name, msg, val);
    }
    
    if (x <= -1.0 || x >= 1.0) {
        *d = 0.0;
    } else {
        *d = -dx/sqrt(1 - x*x);
    }
}


void jmi_ad_atan2_function(const char func_name[], jmi_real_t x, jmi_real_t y, jmi_real_t dx, jmi_real_t dy, jmi_real_t* v, jmi_real_t* d, const char msg[]) {
    jmi_ad_atan2(NULL, func_name, x, y, dx, dy, v, d, msg);
}

void jmi_ad_atan2_equation(jmi_t *jmi, jmi_real_t x, jmi_real_t y, jmi_real_t dx, jmi_real_t dy, jmi_real_t* v, jmi_real_t* d, const char msg[]) {
    jmi_ad_atan2(jmi, NULL, x, y, dx, dy, v, d, msg);
}

void jmi_ad_atan2(jmi_t *jmi, const char func_name[], jmi_real_t x, jmi_real_t y, jmi_real_t dx, jmi_real_t dy, jmi_real_t* v, jmi_real_t* d, const char msg[]) {
    *v = jmi_atan2(jmi, func_name, x, y, msg);
    
    if (x == 0 && y == 0) {
        char val[64];
        sprintf(val, "%.14E, %.14E", x, y);
        
        if (jmi == NULL) jmi = jmi_get_current();
        jmi_log_func_or_eq(jmi, "IllegalDerAtan2Input", func_name, msg, val);
        
        *d = 0.0;
    } else {
        *d = (dx*y - x*dy) / (x*x + y*y);
    }
}

void jmi_ad_pow_function(const char func_name[], jmi_real_t x, jmi_real_t y, jmi_real_t dx, jmi_real_t dy, jmi_real_t *v, jmi_real_t *d, const char msg[]) {
    jmi_ad_pow(NULL, func_name, x, y, dx, dy, v, d, msg);
}

void jmi_ad_pow_equation(jmi_t *jmi, jmi_real_t x, jmi_real_t y, jmi_real_t dx, jmi_real_t dy, jmi_real_t *v, jmi_real_t *d, const char msg[]) {
    jmi_ad_pow(jmi, NULL, x, y, dx, dy, v, d, msg);
}

void jmi_ad_pow(jmi_t *jmi, const char func_name[], jmi_real_t x, jmi_real_t y, jmi_real_t dx, jmi_real_t dy, jmi_real_t *v, jmi_real_t *d, const char msg[]) {
    *v = jmi_pow(jmi, func_name, x, y, msg);
    
    if (x == 0.0) {
        if (y == 1.0 ) {
            *d = dx;
		} else {
            *d = 0.0;
        }
    } else {
        *d = *v * (dx*y/x + dy*log(jmi_abs(x)));
    }
}

