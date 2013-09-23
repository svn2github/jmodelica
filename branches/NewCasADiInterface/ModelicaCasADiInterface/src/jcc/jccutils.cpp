#include <jni.h>

#include "initjcc.h"
#include "jccutils.h"

using namespace java::lang;

jstring fromUTF(const char *bytes) {
    return vm_env->NewStringUTF(bytes);
}
String StringFromUTF(const char *bytes) {
    return String(fromUTF(bytes));
}

JArray<String> new_JArray(const char *items[], int n) {
    String *itemsS = new String[n];
    for (int k=0; k < n; k++) itemsS[k] = StringFromUTF(items[k]);
    JArray<String> result = new_JArray<String>(itemsS, n);
    delete[] itemsS;
    return result;
}
