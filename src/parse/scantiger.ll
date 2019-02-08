/* Lexer */

%option noyywrap
%option noinput
%option nounput
%option debug

%{
    #include "parse.hh"
    yy::parser::location_type loc;
    #include <iostream>
    #define YY_USER_ACTION
%}

int [0-9]+
string "\""([^\\]|\\.)*"\""
id [a-zA-Z][0-9a-zA-Z_]*|"_main"

%%
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