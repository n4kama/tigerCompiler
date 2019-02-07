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

/*
program : int | str | id | program EOL ;
int : INTEGER ;
str : STRING ;
id  : ID ;
*/

program :
    exp
  | decs;


exp :
    "nil"
  | int
  | str

  | type-id "[" exp "]" "of" exp
  | type-id "{" array_rec "}"

  | "new" type-id

  | lvalue

  | id "("  exp  method_rec  ")"

  | lvalue "." id "("  exp  method_rec  ")"

  | "-" exp

  | exp op exp

  | "(" exps ")"
  | lvalue ":=" exp
  | "if" exp "then" exp "else" exp
  | "while" exp "do" exp
  | "for" id ":=" exp "to" exp "do" exp
  | "break"
  | "let" decs "in" exps "end" ;

arr_rec_bis :
    "," id "=" exp arr_rec_bis
  | %empty ;

array_rec :
    id "=" exp arr_rec_bis
  	| %empty ;

method_rec :
	"," exp method_rec
	| %empty ;


lvalue : id
  | lvalue "." id
  | lvalue "[" exp "]" ;

exps : exp exps_rec ;

exps_rec :
	";" exp exps
	| %empty

decs : dec
	| %empty

dec :
    "type" id "=" ty
  | "class" id  "extends" type-id  "{" classfields "}"
  | vardec
  | "function" id "(" tyfields ")"  ":" type-id  "=" exp
  | "primitive" id "(" tyfields ")"  ":" type-id
  | "import" str ;

vardec : "var" id  ":" type-id  ":=" exp ;


classfields :  classfield
classfield :
    vardec
  | "method" id "(" tyfields ")"  ":" type-id  "=" exp

ty :
     type-id
   | "{" tyfields  "}"
   | "array" "of" type-id
   | "class" "extends" type-id "{" classfields "}"
tyfields :  id ":" type-id  "," id ":" type-id

type-id :
        id

int : INTEGER ;
str : STRING ;
id  : ID ;

op : "+" | "-" | "*" | "/" | "=" | "<>" | ">" | "<" | ">=" | "<=" | "&" | "|"


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