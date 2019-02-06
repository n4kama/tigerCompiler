%{
    #include <iostream>
    #include <string>
    #define YYSTYPE int
    int yyparse();
    int yylex();
    int yyerror(std::string s);
}%


%%
%%

int yyerror(std::string s);
{
    printf("yyerror : %s\n", s);
    return 0;
}

int main(void)
{
    yyparse();
    return 0;
}