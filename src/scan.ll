%{

    #include <iostream>

%}


/* Flex Options */

%option debug
%option noyywrap


/* Regexps definition */

INTEGER [0-9]+

STRING \"(\\.|[^"\\])*\"

ID [a-zA-Z][0-9a-z-A-Z_]*

%%
{INTEGER}       { yylval = atoi(yytext); return INTEGER;}
{STRING}        { return STRING;}
{ID}            { return ID;}
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