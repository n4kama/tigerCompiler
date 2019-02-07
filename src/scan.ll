%{
    #include "scan.hh"
    #include <iostream>
%}

/* Flex Options */
%option c++
%option debug
%option noyywrap
/*%define api.prefix {yy} */

/* Regexps definition */
integer [0-9]+
string "\""([^\\]|\\.)*"\""

id [a-zA-Z][0-9a-zA-Z_]*

%%
[ \t\n]+        ;
{id}            return yy.parser::make_ID(yytext);
{string}        return yy.parser::make_STRING(std::string(yytext + 1, yyleng - 2));
{integer}       return yy.parser::make_INTEGER(atoi(yytext));


","             return yy::parser::make_COMMA
":"             return yy::parser::make_COLON
";"             return yy::parser::make_SEMICOLON
"("             return yy::parser::make_LPARENTHESIS
")"             return yy::parser::make_RPARENTHESIS
"["             return yy::parser::make_LBRACKET
"]"             return yy::parser::make_RBRACKET
"{"             return yy::parser::make_LBRACE
"}"             return yy::parser::make_RBRACE
"."             return yy::parser::make_DOT
"+"             return yy::parser::make_PLUS
"-"             return yy::parser::make_MINUS
"*"             return yy::parser::make_TIMES
"/"             return yy::parser::make_SLASH
"="             return yy::parser::make_EQ
"<>"            return yy::parser::make_NEQ
"<"             return yy::parser::make_LT
"<="            return yy::parser::make_LE
">"             return yy::parser::make_GT
">="            return yy::parser::make_GE
"&"             return yy::parser::make_AND
"|"             return yy::parser::make_OR
":="            return yy::parser::make_ASSIGN
.               {
                    throw yy::parser::syntax_error
                    ("invalid character: " + std::string(yytext))
                }
<<EOF>> return yy::parser::make_EN
%%