                                                    // -*- C++ -*-
%expect 0
%require "3.0"
%language "C++"
// Set the namespace name to `parse', instead of `yy'.
%define api.prefix {parse}
%define api.value.type variant
%define api.token.constructor
%define parse.trace

  // FIXME: Some code was deleted here (Other directives: %skeleton "lalr1.cc" %expect 0 etc).
%define parse.error verbose
%defines
%debug
// Prefix all the tokens with TOK_ to avoid colisions.
%define api.token.prefix {TOK_}

/* We use pointers to store the filename in the locations.  This saves
   space (pointers), time (no deep copy), but leaves the problem of
   deallocation.  This would be a perfect job for a misc::symbol
   object (passed by reference), however Bison locations require the
   filename to be passed as a pointer, thus forcing us to handle the
   allocation and deallocation of this object.

   Nevertheless, all is not lost: we can still use a misc::symbol
   object to allocate a flyweight (constant) string in the pool of
   symbols, extract it from the misc::symbol object, and use it to
   initialize the location.  The allocated data will be freed at the
   end of the program (see the documentation of misc::symbol and
   misc::unique).  */
%define filename_type {const std::string}
%locations

// The parsing context.
%param { ::parse::TigerParser& tp }

/*---------------------.
| Support for tokens.  |
`---------------------*/
%code requires
{
#include <string>
#include <misc/algorithm.hh>
#include <misc/separator.hh>
#include <misc/symbol.hh>
#include <parse/fwd.hh>

  // Pre-declare parse::parse to allow a ``reentrant'' parsing within
  // the parser.
  namespace parse
  {
    ast_type parse(Tweast& input);
  }
}

%code provides
{
  // Announce to Flex the prototype we want for lexing (member) function.
  # define YY_DECL_(Prefix)                               \
    ::parse::parser::symbol_type                          \
    (Prefix parselex)(::parse::TigerParser& tp)
  # define YY_DECL YY_DECL_(yyFlexLexer::)
}

%printer { debug_stream() << $$; } <int> <std::string> <misc::symbol>;

%token <std::string>    STRING     "string"
%token <misc::symbol>   ID         "identifier"
%token <int>            INTEGER    "integer"


/*-----------------------------------------.
| Code output in the implementation file.  |
`-----------------------------------------*/

%code
{
# include <parse/tiger-parser.hh>
# include <parse/scantiger.hh>
# include <parse/tweast.hh>
# include <misc/separator.hh>
# include <misc/symbol.hh>

  namespace
  {

    /// Get the metavar from the specified map.
    template <typename T>
    T*
    metavar(parse::TigerParser& tp, unsigned key)
    {
      parse::Tweast* input = tp.input_;
      return input->template take<T>(key);
    }

  }

  /// Use our local scanner object.
  inline
  ::parse::parser::symbol_type
  parselex(parse::TigerParser& tp)
  {
    return tp.scanner_->parselex(tp);
  }
}

// Definition of the tokens, and their pretty-printing.
%token AND          "&"
       ARRAY        "array"
       ASSIGN       ":="
       BREAK        "break"
       CAST         "_cast"
       CLASS        "class"
       COLON        ":"
       COMMA        ","
       DIVIDE       "/"
       DO           "do"
       DOT          "."
       ELSE         "else"
       END          "end"
       EQ           "="
       EXTENDS      "extends"
       FOR          "for"
       FUNCTION     "function"
       GE           ">="
       GT           ">"
       IF           "if"
       IMPORT       "import"
       IN           "in"
       LBRACE       "{"
       LBRACKET     "["
       LE           "<="
       LET          "let"
       LPAR         "("
       LT           "<"
       MINUS        "-"
       METHOD       "method"
       NE           "<>"
       NEW          "new"
       NIL          "nil"
       OF           "of"
       OR           "|"
       PLUS         "+"
       PRIMITIVE    "primitive"
       RBRACE       "}"
       RBRACKET     "]"
       RPAR         ")"
       SEMICOLON    ";"
       THEN         "then"
       TIMES        "*"
       TO           "to"
       TYPE         "type"
       VAR          "var"
       WHILE        "while"
       EOF 0        "end of file"

%token DECS         "_decs"

  // FIXME: Some code was deleted here (Priorities/associativities).
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

%start program


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

/*---------------.
| Declarations.  |
`---------------*/

void
parse::parser::error(const location_type& loc, const std::string& err)
{
  tp.error_ << misc::error::error_type::parse << loc << ": " << err
  << '\n';
}