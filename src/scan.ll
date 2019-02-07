/* Lexer /

%option noyywrap
%option noinput
%option nounput
%option debug

%{
    #include "parse.hh"
    yy::parser::location_type loc;
    #include <iostream>
    #define YY_USER_ACTION                          \
    loc.columns(yyleng);
%}

int [0-9]+
string """([^\]|\.)"""
id [a-zA-Z][0-9a-zA-Z_]*

%%
    loc.step();

{int}       return yy::parser::make_INTEGER(strtol(yytext, nullptr, 0), loc);
{string}    return yy::parser::make_STRING(yytext, loc);
{id}        return yy::parser::make_ID(yytext, loc);
\n          loc.lines(yyleng); return yy::parser::make_EOL(loc);
[ \t]+      loc.step(); continue;
<<EOF>>  return yy::parser::make_EOF(loc);
.           std::cerr << "Lexing error : " << yytext << '\n'; err_nb += 1;

%%