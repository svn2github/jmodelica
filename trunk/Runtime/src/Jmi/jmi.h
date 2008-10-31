/*
 * Design motivations
 *
 * The model/optimization interface is intended to be used in a wide range of
 * applications and on multiple platforms. This also includes embedded
 * platforms in HILS applications.
 *
 * It is desirable that the model/optimization interfaces can be easily interfaced
 * with python. Python is the intended language for scripting in JModelica and it is
 * therefore important that the generated code is straight forward to use with the
 * python extensions framework.
 *
 * The model/optimization interface is intended to be used by wide range of users,
 * with different backgrounds and programming skills. It is therefore desirable that
 * the interface is as simple and intuitive as possible.
 *
 * Given these motivations, it is reasonable to use pure C where possible, and to a
 * limited extent C++ where needed (e.g. in solver interfaces and in most likely in the
 * AD framework).
 *
 * It should also be possible to build shared libraries for models/optimization problems.
 * In this way, it is possible to build applications that contains several models.
 *
 */

#ifndef _JMI_H
#define _JMI_H

typedef double Double_t;

/*
 * These constants are used to encode and decode the masks that are
 * used as arguments in the Jacobian fuctions.
 *
 */

static const int DER_PI = 1;
static const int DER_PD = 2;
static const int DER_DX = 4;
static const int DER_X = 8;
static const int DER_U = 16;
static const int DER_W = 32;

#endif
