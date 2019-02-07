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

%printer { yyo << $$; } <int>;

%precedence "do" "else" "of" ":="

%left "|"
%left "&"
%precedence "<=" ">=" "=" "<>" "<" ">"
%left "+" "-"
%left "*" "/"


%%

//good
program :
    exp
  | decs;


exp :
//good
	"nil"
 	| int
 	| STRING

//good
 	| lvalue_left "of" exp
 	| type-id "{" array_rec "}"
 	| "new" type-id
  | lvalue
	| type-id "(" func_call ")"
 	| lvalue "." type-id "(" func_call ")"
	| "-" exp
	| exp op exp
	| "(" exps ")"
	| lvalue ":=" exp
	| "if" exp "then" exp ctrl_else
  | "while" exp "do" exp
	| "for" type-id ":=" exp "to" exp "do" exp
  | "break"
  | "let" decs "in" exps "end" ;

ctrl_else :
    "else" exp
    | %empty ;

func_call :
    exp func_call_bis
    | %empty ;

func_call_bis :
    "," exp func_call_bis
    | %empty ;

arr_rec_bis :
    "," type-id "=" exp arr_rec_bis
    | %empty ;

array_rec :
    type-id "=" exp arr_rec_bis
  	| %empty ;


lvalue : type-id
 	  | lvalue "." type-id
  	| lvalue_left ;

lvalue_left : lvalue "[" exp "]" ;

exps : exps_rec ;

exps_rec :
	exp exps_bis
  	| %empty ;

exps_bis :
	";" exp exps_bis
	  | %empty ;

decs : dec decs
	  | %empty ;

dec :
    "type" type-id "=" ty
    | "class" type-id  extend_rec  "{" classfields "}"
    | vardec
    | "function" type-id "(" tyfields ")"  type_rec  "=" exp
    | "primitive" type-id "(" tyfields ")"  type_rec
    | "import" STRING ;

extend_rec : "extends" type-id
	  | %empty ;

type_rec : ":" type-id
	  | %empty ;

vardec : "var" type-id  type_rec ":=" exp ;

classfields :  classfield classfields
	  | %empty ;

classfield :
    vardec
  | "method" type-id "(" tyfields ")"  type_rec  "=" exp ;

ty :
     type-id
   | "{" tyfields "}"
   | "array" "of" type-id
   | "class" extend_rec "{" classfields "}" ;

tyfields :  "id" ":" type-id id_type_rec
	| %empty ;

id_type_rec :  "," type-id ":" type-id id_type_rec
	| %empty ;

type-id : ID ;
int : INTEGER ;
op : "+" | "-" | "*" | "/" | "=" | "<>" | ">" | "<" | ">=" | "<=" | "&" | "|" ;


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