/**
 ** \file misc/symbol.hxx
 ** \brief Inline implementation of misc::symbol.
 */

#pragma once

#include <misc/symbol.hh>

namespace misc
{

  inline symbol&
  symbol::operator=(const symbol& rhs)
  {
    obj_ = rhs.obj_;
    return *this;
  }

  inline bool
  symbol::operator==(const symbol& rhs) const
  {
    return obj_ == rhs.obj_;
  }

  inline bool
  symbol::operator!=(const symbol& rhs) const
  {
    return obj_ != rhs.obj_;
  }

  inline std::ostream&
  operator<<(std::ostream& ostr, const symbol& the)
  {
    ostr << the.get();
    return ostr;
  }

}
