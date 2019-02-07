%require "3.0"
%language "C++"

//%language "c++"
//%define api.value.type variant
//%define api.token.constructor
%{
    # include <cerrno>
    # include <climits>
    # include <cstdlib>
    # include <cstring>
    # include <string>
    #define YYSTYPE int
    int yyparse();
    int yylex();
    int yyerror(std::string s);
    FILE *yyin;
%}

%token INTEGER
%token STRING
%token ID
%token COMMA
%token COLON
%token SEMICOLON
%token LPARENTHESIS
%token RPARENTHESIS
%token LBRACKET
%token RBRACKET
%token LBRACE
%token RBRACE
%token DOT
%token PLUS
%token MINUS
%token TIMES
%token SLASH
%token EQ
%token NEQ
%token LT
%token LE
%token GT
%token GE
%token AND
%token OR
%token ASSIGN
%token ERROR

%%

program : program program | exp { std::cout << "(bigR < dbz < naruto) et tokens : " << $1 << "\n"; }

exp : op | INTEGER | STRING | ID { $$ = $1; }

op : PLUS | MINUS | TIMES | SLASH | EQ | NEQ | GT | LT | GE | LE | AND { $$ = $1; }

%%

int yyerror(std::string s)
{
    std::cout << "yyerror :" << s << '\n';
    return 0;
}

int main(int argc, char *argv[])
{
    if (argc == 1)
    {
        yyparse();
    }

    if (argc == 2)
    {
        yyin = fopen(argv[1], "r");
        yyparse();
    }

    return 0;
}