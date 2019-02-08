                                                            /* -*- C++ -*- */
%option c++
%option nounput
%option debug
%option batch

%{

#include <cerrno>
#include <climits>
#include <regex>
#include <string>

#include <boost/lexical_cast.hpp>

#include <misc/contract.hh>
  // Using misc::escape is very useful to quote non printable characters.
  // For instance
  //
  //    std::cerr << misc::escape('\n') << '\n';
  //
  // reports about `\n' instead of an actual new-line character.
#include <misc/escape.hh>
#include <misc/symbol.hh>
#include <parse/parsetiger.hh>
#include <parse/tiger-parser.hh>

#include "parse.hh"
yy::parser::location_type loc;
#include <iostream>
#define YY_USER_ACTION

// Convenient shortcuts.
#define TOKEN_VAL(Type, Value)                  \
  parser::make_ ## Type(Value, tp.location_)

#define TOKEN(Type)                             \
  parser::make_ ## Type(tp.location_)


// Flex uses `0' for end of file.  0 is not a token_type.
#define yyterminate() return TOKEN(EOF)

# define CHECK_EXTENSION()                              \
  do {                                                  \
    if (!tp.enable_extensions_p_)                       \
      tp.error_ << misc::error::error_type::scan        \
                << tp.location_                         \
                << ": invalid identifier: `"            \
                << misc::escape(yytext) << "'\n";       \
  } while (false)

YY_FLEX_NAMESPACE_BEGIN
%}

%x SC_COMMENT SC_STRING

/* Abbreviations.  */
int             [0-9]+
string "\""([^\\]|\\.)*"\""
id [a-zA-Z][0-9a-zA-Z_]*|"_main"

%%
%{
  // FIXME: Some code was deleted here (Local variables).

  // Each time yylex is called.
  tp.location_.step();
%}

 /* The rules.  */

    loc.step();

"("         return yy::parser::make_LPAR(yytext, loc);
")"         return yy::parser::make_RPAR(yytext, loc);
"{"         return yy::parser::make_LBRACE(yytext, loc);
"}"         return yy::parser::make_RBRACE(yytext, loc);
"["         return yy::parser::make_LBRACKET(yytext, loc);
"]"         return yy::parser::make_RBRACKET(yytext, loc);
"."         return yy::parser::make_DOT(yytext, loc);
"of"        return yy::parser::make_OF(yytext, loc);
"new"       return yy::parser::make_NEW(yytext, loc);
"if"        return yy::parser::make_IF(yytext, loc);
"then"      return yy::parser::make_THEN(yytext, loc);
"else"      return yy::parser::make_ELSE(yytext, loc);
"while"     return yy::parser::make_WHILE(yytext, loc);
"do"        return yy::parser::make_DO(yytext, loc);
"for"       return yy::parser::make_FOR(yytext, loc);
"to"        return yy::parser::make_TO(yytext, loc);
"nil"       return yy::parser::make_NIL(yytext, loc);
"break"     return yy::parser::make_BREAK(yytext, loc);
"let"       return yy::parser::make_LET(yytext, loc);
"in"        return yy::parser::make_IN(yytext, loc);
"end"       return yy::parser::make_END(yytext, loc);
"type"      return yy::parser::make_TYPE(yytext, loc);
","         return yy::parser::make_COMMA(yytext, loc);
";"         return yy::parser::make_SEMICOLON(yytext, loc);
":"         return yy::parser::make_COLON(yytext, loc);
"class"     return yy::parser::make_CLASS(yytext, loc);
"function"  return yy::parser::make_FUNCTION(yytext, loc);
"primitive" return yy::parser::make_PRIMITIVE(yytext, loc);
"import"    return yy::parser::make_IMPORT(yytext, loc);
"extends"   return yy::parser::make_EXTENDS(yytext, loc);
"var"       return yy::parser::make_VAR(yytext, loc);
"method"    return yy::parser::make_METHOD(yytext, loc);
"array"     return yy::parser::make_ARRAY(yytext, loc);

"+"         return yy::parser::make_PLUS(yytext, loc);
"-"         return yy::parser::make_MINUS(yytext, loc);
"*"         return yy::parser::make_TIMES(yytext, loc);
"/"         return yy::parser::make_DIVIDE(yytext, loc);
"<"         return yy::parser::make_LT(yytext, loc);
">"         return yy::parser::make_GT(yytext, loc);
"<="        return yy::parser::make_LE(yytext, loc);
">="        return yy::parser::make_GE(yytext, loc);
":="        return yy::parser::make_ASSIGN(yytext, loc);
"="         return yy::parser::make_EQ(yytext, loc);
"<>"        return yy::parser::make_NEQ(yytext, loc);
"&"         return yy::parser::make_AND(yytext, loc);
"|"         return yy::parser::make_OR(yytext, loc);


{int}       {
                int val = strtol(yytext, nullptr, 0);
                return yy::parser::make_INTEGER(val, loc);
            };
{string}    return yy::parser::make_STRING(yytext, loc);
{id}        return yy::parser::make_ID(yytext, loc);

"\n"        loc.lines(yyleng); loc.step();
[ \t]+      loc.step(); continue;
<<EOF>>     return yy::parser::make_EOF(loc);
.           std::cerr << "Lexing error : " << yytext << '\n';
%%

// Do not use %option noyywrap, because then flex generates the same
// definition of yywrap, but outside the namespaces, so it defines it
// for ::yyFlexLexer instead of ::parse::yyFlexLexer.
int yyFlexLexer::yywrap() { return 1; }

void
yyFlexLexer::scan_open_(std::istream& f)
{
  yypush_buffer_state(YY_CURRENT_BUFFER);
  yy_switch_to_buffer(yy_create_buffer(&f, YY_BUF_SIZE));
}

void
yyFlexLexer::scan_close_()
{
  yypop_buffer_state();
}

YY_FLEX_NAMESPACE_END
