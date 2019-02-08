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

"("         return TOKEN(LPAR);
")"         return TOKEN(RPAR);
"{"         return TOKEN(LBRACE);
"}"         return TOKEN(RBRACE);
"["         return TOKEN(LBRACKET);
"]"         return TOKEN(RBRACKET);
"."         return TOKEN(DOT);
"of"        return TOKEN(OF);
"new"       return TOKEN(NEW);
"if"        return TOKEN(IF);
"then"      return TOKEN(THEN);
"else"      return TOKEN(ELSE);
"while"     return TOKEN(WHILE);
"do"        return TOKEN(DO);
"for"       return TOKEN(FOR);
"to"        return TOKEN(TO);
"nil"       return TOKEN(NIL);
"break"     return TOKEN(BREAK);
"let"       return TOKEN(LET);
"in"        return TOKEN(END);
"end"       return TOKEN(END);
"type"      return TOKEN(TYPE);
","         return TOKEN(COMMA);
";"         return TOKEN(SEMICOLON);
":"         return TOKEN(COLON);
"class"     return TOKEN(CLASS);
"function"  return TOKEN(FUNCTION);
"primitive" return TOKEN(PRIMITIVE);
"import"    return TOKEN(IMPORT);
"extends"   return TOKEN(EXTENDS);
"var"       return TOKEN(VAR);
"method"    return TOKEN(METHOD);
"array"     return TOKEN(ARRAY);

"+"         return TOKEN(PLUS);
"-"         return TOKEN(MINUS);
"*"         return TOKEN(TIMES);
"/"         return TOKEN(DIVIDE);
"<"         return TOKEN(LT);
">"         return TOKEN(GT);
"<="        return TOKEN(LE);
">="        return TOKEN(GE);
":="        return TOKEN(ASSIGN);
"="         return TOKEN(EQ);
"<>"        return TOKEN(NEQ);
"&"         return TOKEN(AND);
"|"         return TOKEN(OR);


{int}       {
                int val = strtol(yytext, nullptr, 0);
                return TOKEN_VAL(INTEGER, val);
            };
{string}    return TOKEN_VAL(STRING, yytext);
{id}        return TOKEN_VAL(ID, yytext);

"\n"        loc.lines(yyleng); loc.step();
[ \t]+      loc.step(); continue;
<<EOF>>     return TOKEN(EOF);
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
