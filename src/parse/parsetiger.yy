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
%token <std::string> LPAR RPAR LBRACE RBRACE LBRACKET RBRACKET DOT OF NEW IF
       THEN ELSE WHILE DO FOR TO NIL BREAK LET IN END TYPE COMMA
       SEMICOLON COLON CLASS FUNCTION PRIMITIVE IMPORT EXTENDS VAR METHOD ARRAY
       PLUS MINUS TIMES DIVIDE LT GT LE GE ASSIGN EQ NEQ AND OR

%printer { yyo << $$; } <int>;

%nonassoc ASSIGN
%left OR
%left AND
%nonassoc LT GT EQ NEQ LE GE
%left PLUS MINUS
%left TIMES DIVIDE
%left DOT
%nonassoc OF
%nonassoc DO
%nonassoc NOT_ELSE
%nonassoc ELSE

%%

program :
    exp
  | decs;


exp : NIL
 	| INTEGER
 	| STRING
 	| lvalue_left OF exp
 	| type-id LBRACE array_rec RBRACE
 	| NEW type-id
  | lvalue
	| type-id LPAR func_call RPAR
 	| lvalue DOT type-id LPAR func_call RPAR
	| MINUS exp
	| exp PLUS exp
    | exp MINUS exp
    | exp TIMES exp
    | exp DIVIDE exp
    | exp EQ exp
    | exp NEQ exp
    | exp GT exp
    | exp LT exp
    | exp GE exp
    | exp LE exp
    | exp AND exp
    | exp OR exp
	| LPAR exps RPAR
	| lvalue ASSIGN exp
  | IF exp THEN exp %prec NOT_ELSE
	| IF exp THEN exp ELSE exp
  | WHILE exp DO exp
	| FOR type-id ASSIGN exp TO exp DO exp
	| BREAK
  | LET decs IN exps END ;


func_call : exp func_call_bis | %empty ;

func_call_bis :
    COMMA exp func_call_bis
    | %empty ;

arr_rec_bis :
    COMMA type-id EQ exp arr_rec_bis
    | %empty ;

array_rec :
    type-id EQ exp arr_rec_bis
  	| %empty ;

lvalue : type-id
 	  | lvalue DOT type-id
  	| lvalue_left ;

lvalue_left : lvalue LBRACKET exp RBRACKET ;

exps : exps_rec ;

exps_rec :
	exp exps_bis
  	| %empty ;

exps_bis :
	SEMICOLON exp exps_bis
	  | %empty ;

decs : dec decs
	  | %empty ;

dec :
    TYPE type-id EQ ty
    | CLASS type-id  extend_rec  LBRACE classfields RBRACE
    | vardec
    | FUNCTION type-id LPAR tyfields RPAR  type_rec  EQ exp
    | PRIMITIVE type-id LPAR tyfields RPAR  type_rec
    | IMPORT STRING ;

extend_rec : EXTENDS type-id
	  | %empty ;

type_rec : COLON type-id
	  | %empty ;

vardec : VAR type-id  type_rec ASSIGN exp ;

classfields :  classfield classfields
	  | %empty ;

classfield :
    vardec
  | METHOD type-id LPAR tyfields RPAR  type_rec  EQ exp ;

ty :
     type-id
   | LBRACE tyfields RBRACE
   | ARRAY OF type-id
   | CLASS extend_rec LBRACE classfields RBRACE ;

tyfields :  type-id COLON type-id id_type_rec
	| %empty ;

id_type_rec : COMMA type-id COLON type-id id_type_rec
	| %empty ;

type-id : ID;

%%

void yy::parser::error(const location_type& loc, const std::string& err)
{
    err_nb += 1;
    std::cerr << "line: " << loc << ", c'est un scandale, sah jsuis anéanti, quelle vie...: " << err << '\n';
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