%{
#include <iostream>
%}

enum yystype
{
    INTEGER, STRING, ID, COMMA, COLON, SEMICOLON, LPARENTHESIS, RPARENTHESIS, LBRACKET,
    RBRACKET, LBRACE, RBRACE, DOT, PLUS, MINUS, TIMES, SLASH, EQ, NEQ, LT, LE, GT, GE,
    AND, OR, ASSIGN ,ERROR
};

/* Flex Options */
%option debug
%option noyywrap

/* Regexps definition */
integer [0-9]+
string \"(\\.|[^"\\])*\"
id [a-zA-Z][0-9a-zA-Z_]*

%%
[ \t\n]+        ;
{integer}       { yylval = atoi(yytext); return INTEGER;}
{string}        { return STRING;}
{id}            { return ID;}
","             { return COMMA; }
":"             { return COLON; }
";"             { return SEMICOLON; }
"("             { return LPARENTHESIS; }
")"             { return RPARENTHESIS; }
"["             { return LBRACKET; }
"]"             { return RBRACKET; }
"{"             { return LBRACE; }
"}"             { return RBRACE; }
"."             { return DOT; }
"+"             { return PLUS; }
"-"             { return MINUS; }
"*"             { return TIMES; }
"/"             { return SLASH; }
"="             { return EQ; }
"<>"            { return NEQ; }
"<"             { return LT; }
"<="            { return LE; }
">"             { return GT; }
">="            { return GE; }
"&"             { return AND; }
"|"             { return OR; }
":="            { return ASSIGN; }
.               { return ERROR;}
%%