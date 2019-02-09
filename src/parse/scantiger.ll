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

#define YY_USER_ACTION tp.location_.columns(yyleng);

// Flex uses `0' for end of file.  0 is not a token_type.
#define yyterminate() return TOKEN(EOF)

std::string grown_string = std::string();
int depth = 0;

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
  tp.location_.step();
%}

 /* The rules.  */

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
"in"        return TOKEN(IN);
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
                int val = std::atoi(yytext);
                if(val < 0)
                {
                  tp.error_ << misc::error::error_type::scan << tp.location_
                  << ": " << "Number out of integer"
                  << '\n' << &misc::error::exit;
                }
                return TOKEN_VAL(INTEGER, val);
            };
{id}        return TOKEN_VAL(ID, yytext);


"/*"        {depth++; BEGIN(SC_COMMENT); }
<SC_COMMENT>{
              "/*" { depth++; }

              <<EOF>> {
                        tp.error_ << misc::error::error_type::scan << tp.location_
                        << ": " << "Unterminated comment" << '\n' << &misc::error::exit;
                      }

              "*/"  {
                      depth--;
                      if (depth == 0)
                        BEGIN(INITIAL);
                    }

              .     {}
            }



"\""          grown_string.clear(); BEGIN SC_STRING;

<SC_STRING>{ /* Handling of the strings.  Initial " is eaten. */
     "\"" {
              BEGIN INITIAL;
              return TOKEN_VAL(STRING, grown_string);
          }

     \\x[0-9a-fA-F]{2}  {
              grown_string.append(1, strtol(yytext + 2, 0, 16));
          }

      "\\a"
      "\\b"
      "\\f"
      "\\n"
      "\\r"
      "\\t"
      "\\v"

      "\\\"" {
        grown_string.append("\\\"");
      }

      "\\\\" {
        grown_string.append("\\\\");
      }

      "\\". {
          tp.error_ << misc::error::error_type::scan << tp.location_
          << ": Unexpected value after \\" << '\n'
          << &misc::error::exit;
      }

      . {
              grown_string.append(yytext);
      }

      <<EOF>> {
          tp.error_ << misc::error::error_type::scan << tp.location_
          << ": Unexpected end of file : unterminated string" << '\n'
          << &misc::error::exit;
      }
}


(\n|\r|\n\r|\r\n)   tp.location_.lines(yyleng);
[ \t]       ;
<<EOF>>     return TOKEN(EOF);

.           {
                tp.error_ << misc::error::error_type::scan << tp.location_
                << ": Unexpected character : " << yytext << '\n'
                << &misc::error::exit;
            }
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
