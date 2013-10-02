#ifndef _MODELICACASADI_REF
#define _MODELICACASADI_REF

#include <cassert>
#include <cstddef>  // for NULL


namespace ModelicaCasADi
{
template <class T> class Ref {
    public:
        // Default constructor needed so that SWIG doesn't use SWIGValueWrapper<Ref<T>>
        Ref() { this->node = NULL; }
        // Non-template versions of constructors and assignment operator needed by SWIG
        Ref(T *node) { this->node = node; incRef(); }
        Ref(const Ref<T> &ref) { this->node = ref.node; incRef(); }
        template <class S> Ref(S *node) { this->node = node; incRef(); }
        template <class S> Ref(const Ref<S> &ref) { this->node = ref.node; incRef(); }
        ~Ref() { decRef(); }
        
        Ref<T>& operator=(T* node) { setNode(node); return *this; }
        Ref<T>& operator=(const Ref<T>& ref) { setNode(ref.node); return *this; }
        template <class S> Ref<T>& operator=(S* node) { setNode(node); return *this; }
        template <class S> Ref<T>& operator=(const Ref<S>& ref) { setNode(ref.node); return *this; }
        
        const T *operator->() const { assert(node != NULL); return node; }
        T *operator->() { assert(node != NULL); return node; }
        
        const T *getNode() const { return node; }
        T *getNode() { return node; }

        void setNode(T *node) {
            if (this->node == node) return;
            
            decRef();
            this->node = node;
            incRef();
        }

        T *node;    
    private:
        void incRef() { incRefNode(node); }
        void decRef() { if (decRefNode(node)) node = NULL; }
};
}; // End namespace
#endif
