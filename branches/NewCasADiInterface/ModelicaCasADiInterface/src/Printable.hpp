#ifndef _MODELICACASADI_PRINTABLE
#define _MODELICACASADI_PRINTABLE

#include <iostream>
#include <string>

namespace ModelicaCasADi
{
class Printable {
    public:
        virtual void print(std::ostream& os) const;
        
        friend std::ostream& operator<<(std::ostream& os, const Printable& p);
        std::string repr();
};

inline std::ostream &operator<<(std::ostream &os, const Printable &p) {
    p.print(os);
    return os;
}

inline std::string Printable::repr() {
    std::stringstream s;
    s << *this;
    return s.str();    
}

inline void Printable::print(std::ostream& os) const {
    // Test code to help debug python printing problems. Todo: remove
    os << "<This is a Printable>";
}

#ifdef SWIG
%extend Printable{
  std::string __str__()  { return $self->repr(); }
  std::string __repr__() { return $self->repr(); }
}
#endif // SWIG    

} // End namespace

#endif // _MODELICACASADI_PRINTABLE
