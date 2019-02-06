%{
    #include <iostream>
    #include <string>
    #define YYSTYPE int
    int yyparse();
    int yylex();
    int yyerror(std::string s);
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

program : exp { std::cout << "tokens : " << $1; }

exp : op | INTEGER | STRING { $$ = $1; }

op : PLUS | MINUS | TIMES | SLASH | EQ | NEQ | GT | LT | GE | LE | AND { $$ = $1; }

%%

int yyerror(std::string s)
{
    printf("yyerror : %s\n", s);
    return 0;
}

int main(void)
{
    yyparse();
    return 0;
}