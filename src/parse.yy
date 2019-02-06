%{
    #include <stdio.h>
    #define YYSTYPE int
    int yyparse();
    int yylex();
    int yyerror(char *s);
}%

