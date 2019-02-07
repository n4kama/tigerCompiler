%expect 0
%require "3.0"
%language "C++"
%define api.value.type variant
%define api.token.constructor
%define api.token.prefix {TOK_}
%define parse.trace
%locations
%parse-param {int& res}
%param {int& err_nb}

%code provides
{
    #define YY_DECL yy::parser::symbol_type yylex(int& err_nb)
    extern FILE *yyin;
    YY_DECL;
}

%{
    extern int yy_flex_debug;
    # include <cerrno>
    # include <climits>
    # include <cstdlib>
    # include <cstring>
    # include <string>
    # include <cstdio>
    int yyparse();
%}

%token <std::string>    STRING  "string"
%token <std::string>    ID      "identifier"
%token <int>            INTEGER "integer"
%token EOF 0 "end-of-file"
%token EOL "end-of-line"


%%

program : int | str | id | program EOL ;
int : INTEGER ;
str : STRING ;
id  : ID ;


%%

void yy::parser::error(const location_type& loc, const std::string& err)
{
    err_nb += 1;
    std::cerr << "line: " << loc << ", yyerror: " << err << '\n';
}

int main(int argc, char *argv[])
{
  auto res = 0;
  auto err = 0;
  yy::parser parser(res, err);

  if (getenv("SCAN"))
    {
      yy_flex_debug = 1;
    }

  if (getenv("PARSE"))
    parser.set_debug_level(1);

    for(int i = 1; i < argc; i++)
    {
        yyin = fopen(argv[1],"r");
          parser.parse();
    }
      return 0;
}