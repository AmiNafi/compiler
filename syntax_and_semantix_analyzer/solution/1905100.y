%{
#include<bits/stdc++.h>
using namespace std;
#include "1905100.h"
#include "pfunc.h"
#include "mydata.h"
#include "RT.h"
int yyparse(void);
int yylex(void);
void yylex_destroy();
extern FILE *yyin;
SymbolTable* table;
ofstream logstream ,parsestream;
ofstream errorstream;
int ercnt = 0, goter = 0;
void yyerror(char *s)
{
	//write your code
}

%}
%union {
    SymbolInfo* sp;
}
%nonassoc SINGLE_IF
%nonassoc ELSE
%token <sp> CONST_FLOAT CONST_INT CONST_CHAR LPAREN LCURL LSQUARE RPAREN RCURL RSQUARE SEMICOLON COMMA ID STRING
%token <sp> IF ELSE FOR WHILE DO SWITCH CASE DEFAULT CONTINUE BREAK PRINTLN RETURN ASSIGNOP LOGICOP RELOP ADDOP MULOP NOT INCOP DECOP INT FLOAT VOID CHAR DOUBLE
%type <sp> argument_list arguments compound_statement declaration_list expression expression_statement factor func_declaration func_definition logic_expression
%type <sp> parameter_list program rel_expression simple_expression start statement statements term type_specifier unary_expression unit var_declaration variable
%%
start :  program
	{
        $$ = new SymbolInfo();
		$$->pb($1);
        $$->name = "start : program";
        ($$->linecnt).first = ($1->linecnt).first;
        ($$->linecnt).second = ($1->linecnt).second;
        $$->getptr()->getfploc()->clear();$$->getptr()->setfp($1->getptr()->getfp());$$->getptr()->setrt(getRT($1));
		print($$, 0, parsestream);
		delete $$;
	}
	;

program :  program unit
	{
        $$ = new SymbolInfo();
	//	$1 -> pb( $2 );
        $$->pb($1);
        $$->pb($2);
        $$->name ="program : program unit"; 
        ($$->linecnt).first = ($1->linecnt).first;
        ($$->linecnt).second = ($2->linecnt).second;
        
        $$->getptr()->getfploc()->clear();$$->getptr()->setfp($1->getptr()->getfp());$$->getptr()->setrt(getRT($1));
	//	$$ = $1;
	}
	|  unit
	{
        $$ = new SymbolInfo();
		$$ ->pb( $1);
        $$->name ="program : unit"; 
        ($$->linecnt).first = ($1->linecnt).first;
        ($$->linecnt).second = ($1->linecnt).second;
        
        $$->getptr()->getfploc()->clear();$$->getptr()->setfp($1->getptr()->getfp());$$->getptr()->setrt(getRT($1));
	//	
	}
	;

unit :  var_declaration
	{
        $$ = new SymbolInfo();
		$$ -> pb( $1);
        $$->name ="unit : var_declaration"; 
        ($$->linecnt).first = ($1->linecnt).first;
        ($$->linecnt).second = ($1->linecnt).second;
        
        $$->getptr()->getfploc()->clear();$$->getptr()->setfp($1->getptr()->getfp());$$->getptr()->setrt(getRT($1));
	//	
	}
	|  func_declaration
	{
        $$ = new SymbolInfo();
        $$ -> name = "unit : func_declaration";
        $$ -> pb($1);
        ($$->linecnt).first = ($1->linecnt).first;
        ($$->linecnt).second = ($1->linecnt).second;
        
        $$->getptr()->getfploc()->clear();$$->getptr()->setfp($1->getptr()->getfp());$$->getptr()->setrt(getRT($1));
		
	}
	|  func_definition
	{
        $$ = new SymbolInfo();
        $$ -> name = "unit : func_definition";
        $$ -> pb($1);
        ($$->linecnt).first = ($1->linecnt).first;
        ($$->linecnt).second = ($1->linecnt).second;
        
        $$->getptr()->getfploc()->clear();$$->getptr()->setfp($1->getptr()->getfp());$$->getptr()->setrt(getRT($1));
		
	}
    ;

func_declaration :  type_specifier ID LPAREN parameter_list RPAREN SEMICOLON
	{
        $$ = new SymbolInfo();
        $$ -> name = "func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON";
        $$ -> pb($1);
		$$ -> pb( $2 );
		$$ -> pb( $3 );
		$$ -> pb( $4 );
		$$ -> pb( $5 );
		$$ -> pb( $6 );
		fundec(getall($1)[0],getall($2)[0],$4);
        ($$->linecnt).first = ($1->linecnt).first;
        ($$->linecnt).second = ($6->linecnt).second;
        
        $$->getptr()->getfploc()->clear();$$->getptr()->setfp($1->getptr()->getfp());$$->getptr()->setrt(getRT($1));

	}
	|  type_specifier ID LPAREN RPAREN SEMICOLON
	{
        $$ = new SymbolInfo();
        $$ -> name = "func_declaration : type_specifier ID LPAREN RPAREN SEMICOLON";
        $$ -> pb($1);
		$$ -> pb( $2 );
		$$ -> pb( $3 );
		$$ -> pb( $4 );
		$$ -> pb( $5 );
		fundec(getall($1)[0],getall($2)[0],nullptr);

        ($$->linecnt).first = ($1->linecnt).first;
        ($$->linecnt).second = ($5->linecnt).second;
        
        $$->getptr()->getfploc()->clear();$$->getptr()->setfp($1->getptr()->getfp());$$->getptr()->setrt(getRT($1));
	}
    ;

func_definition :  type_specifier ID LPAREN parameter_list RPAREN {funcdef(getall($1)[0] , getall($2)[0] , $4);} compound_statement
	{
        $$ = new SymbolInfo();
        $$ -> name = "func_definition : type_specifier ID LPAREN parameter_list RPAREN compound_statement";
        $$ -> pb($1);
		$$ -> pb( $2 );
		$$ -> pb( $3 );
		$$ -> pb( $4 );
		$$ -> pb( $5 );
		$$ -> pb( $7 );
		
        ($$->linecnt).first = ($1->linecnt).first;
        ($$->linecnt).second = ($7->linecnt).second;
        
        $$->getptr()->getfploc()->clear();$$->getptr()->setfp($1->getptr()->getfp());$$->getptr()->setrt(getRT($1));
	}
	|  type_specifier ID LPAREN RPAREN {funcdef($1 , $2 , nullptr);} compound_statement
	{
		
        $$ = new SymbolInfo();
        $$ -> name = "func_definition : type_specifier ID LPAREN RPAREN compound_statement";
        $$ -> pb($1);
		$$ -> pb( $2 );
		$$ -> pb( $3 );
		$$ -> pb( $4 );
		$$ -> pb( $6 );
		
        ($$->linecnt).first = ($1->linecnt).first;
        ($$->linecnt).second = ($6->linecnt).second;
        
        $$->getptr()->getfploc()->clear();$$->getptr()->setfp($1->getptr()->getfp());$$->getptr()->setrt(getRT($1));
	}
    | type_specifier ID LPAREN error {
    if (goter == 0) {
        goter = yylineno;
        cout << " got here before " << endl;
        yyerror("Syntax error at parameter list of function definition", yylineno);
        goter = 1;
        cout << " made 1 " << endl;
    }
    } RPAREN{goter = 0;} compound_statement    {
            SymbolInfo* nsm = new SymbolInfo("error", "parameter_list");//"error", "parameter_list", pii(($3->linecnt).second, ($6->linecnt).first));
            //nsm->name = "parameter_list : error";
            nsm->linecnt = pii(($3->linecnt).second, ($6->linecnt).first);
            $$ = new SymbolInfo();
            $$ -> name = "func_definition : type_specifier ID LPAREN parameter_list RPAREN compound_statement";
            $$->linecnt = pii(($1->linecnt).first, ($8->linecnt).second);
            $$->pb($1);
            $$->pb($2);
            $$->pb($3);
            $$->pb(nsm);
            $$->pb($6);
            $$->pb($8);
            goter = 0;
        }
	;

parameter_list :  parameter_list COMMA type_specifier ID
	{
        $$ = new SymbolInfo();
        $$ -> name = "parameter_list : parameter_list COMMA type_specifier ID";
        $$ -> pb($1);
		$$ -> pb( $2 );
		$$ -> pb( $3 );
		$$ -> pb( $4 );
        ($$->linecnt).first = ($1->linecnt).first;
        ($$->linecnt).second = ($4->linecnt).second;
        
        $$->getptr()->getfploc()->clear();$$->getptr()->setfp($1->getptr()->getfp());$$->getptr()->setrt(getRT($1));
		
	}
	|  parameter_list COMMA type_specifier
	{
        $$ = new SymbolInfo();
        $$ -> name = "parameter_list : parameter_list COMMA type_specifier";
        $$ -> pb($1);
		$$ -> pb( $2 );
		$$ -> pb( $3 );
        ($$->linecnt).first = ($1->linecnt).first;
        ($$->linecnt).second = ($3->linecnt).second;
        
        $$->getptr()->getfploc()->clear();$$->getptr()->setfp($1->getptr()->getfp());$$->getptr()->setrt(getRT($1));
	}
	|  type_specifier ID
	{
        $$ = new SymbolInfo();
        $$ -> name = "parameter_list : type_specifier ID";
        $$ -> pb($1);
		$$ -> pb( $2 );
        ($$->linecnt).first = ($1->linecnt).first;
        ($$->linecnt).second = ($2->linecnt).second;
        
        $$->getptr()->getfploc()->clear();$$->getptr()->setfp($1->getptr()->getfp());$$->getptr()->setrt(getRT($1));
		
	}
	|  type_specifier
	{
        $$ = new SymbolInfo();
		
        $$ -> name = "parameter_list : type_specifier";
        $$ -> pb($1);
        ($$->linecnt).first = ($1->linecnt).first;
        ($$->linecnt).second = ($1->linecnt).second;
        
        $$->getptr()->getfploc()->clear();$$->getptr()->setfp($1->getptr()->getfp());$$->getptr()->setrt(getRT($1));
	}
    ;

compound_statement :  LCURL{entersc();} statements RCURL
	{
        $$ = new SymbolInfo();
        $$ -> name = "compound_statement : LCURL statements RCURL";
        $$ -> pb($1);
		$$ -> pb( $3 );
		$$ -> pb( $4 );
        ($$->linecnt).first = ($1->linecnt).first;
        ($$->linecnt).second = ($4->linecnt).second;
		
        $$->getptr()->getfploc()->clear();$$->getptr()->setfp($1->getptr()->getfp());$$->getptr()->setrt(getRT($1));
        
		exitsc();
	}
	|  LCURL{entersc();} RCURL
	{
		
        $$ = new SymbolInfo();
        $$ -> name = "compound_statement : LCURL RCURL";
        $$ -> pb($1);
		$$ -> pb( $3 );
        ($$->linecnt).first = ($1->linecnt).first;
        ($$->linecnt).second = ($3->linecnt).second;
        
        $$->getptr()->getfploc()->clear();$$->getptr()->setfp($1->getptr()->getfp());$$->getptr()->setrt(getRT($1));
		exitsc();
	}
	;

var_declaration :  type_specifier declaration_list SEMICOLON
	{
        $$ = new SymbolInfo();
        $$->pb($1);
		$$ -> pb( $2 );
		$$ -> pb( $3 );
        ($$->linecnt).first = ($1->linecnt).first;
        ($$->linecnt).second = ($3->linecnt).second;
        $$->name = "var_declaration : type_specifier declaration_list SEMICOLON";
        
        $$->getptr()->getfploc()->clear();$$->getptr()->setfp($1->getptr()->getfp());$$->getptr()->setrt(getRT($1));
		vardec($$);
	}
    | type_specifier error {if(goter== 0){
                                    goter = yylineno;
                                    yyerror("Syntax error at declaration list of variable declaration", yylineno);
                                    //logout<<"Error at line no "<<errorLine<<" : syntax error"<<endl;
                                    }} SEMICOLON    {

            $$ = new SymbolInfo();//"type_specifier declaration_list SEMICOLON", "var_declaration", pii(($1->linecnt).first, ($4->linecnt).second));
            $$->name = "var_declaration : type_specifier declaration_list SEMICOLON";
            ($$->linecnt).first = ($1->linecnt).first;
            ($$->linecnt).second = ($4->linecnt).second;

            

            SymbolInfo* nsm = new SymbolInfo("error", "declaration_list");//"error", "declaration_list", pii(goter, goter));
            //nsm -> name = "declaration_list : error";
            nsm -> linecnt = pii(goter, goter);
            $$->pb($1);
            $$->pb(nsm);
            $$->pb($4);
            goter = 0;
        }
	;

type_specifier :  INT
	{
        $$ = new SymbolInfo();
		$$ -> pb( $1);
        $$ -> name = "type_specifier : INT";
        ($$->linecnt).first = ($1->linecnt).first;
        ($$->linecnt).second = ($1->linecnt).second;
        
        $$->getptr()->getfploc()->clear();$$->getptr()->setfp($1->getptr()->getfp());$$->getptr()->setrt(getRT($1));
	}
	|  FLOAT
	{
        $$ = new SymbolInfo();
        $$ -> name = "type_specifier : FLOAT";
		$$ -> pb( $1);
		
        ($$->linecnt).first = ($1->linecnt).first;
        ($$->linecnt).second = ($1->linecnt).second;
        
        $$->getptr()->getfploc()->clear();$$->getptr()->setfp($1->getptr()->getfp());$$->getptr()->setrt(getRT($1));
	}
	|  VOID
	{
		
        $$ = new SymbolInfo();
        $$ -> name = "type_specifier : VOID";
		$$ -> pb( $1);
		
        ($$->linecnt).first = ($1->linecnt).first;
        ($$->linecnt).second = ($1->linecnt).second;
        
        $$->getptr()->getfploc()->clear();$$->getptr()->setfp($1->getptr()->getfp());$$->getptr()->setrt(getRT($1));
	}
	;

declaration_list :  declaration_list COMMA ID
	{
		
        $$ = new SymbolInfo();
        $$ -> name = "declaration_list : declaration_list COMMA ID";
        $$ -> pb($1);
		$$ -> pb( $2 );
		$$ -> pb( $3 );
		
        ($$->linecnt).first = ($1->linecnt).first;
        ($$->linecnt).second = ($3->linecnt).second;
        
        $$->getptr()->getfploc()->clear();$$->getptr()->setfp($1->getptr()->getfp());$$->getptr()->setrt(getRT($1));
	}
	|  declaration_list COMMA ID LSQUARE CONST_INT RSQUARE
	{
		
        $$ = new SymbolInfo();
        $$ -> name = "declaration_list : declaration_list COMMA ID LSQUARE CONST_INT RSQUARE";
        $$ -> pb($1);
		$$ -> pb( $2 );
		$$ -> pb( $3 );
		$$ -> pb( $4 );
		$$ -> pb( $5 );
		$$ -> pb( $6 );
		
        ($$->linecnt).first = ($1->linecnt).first;
        ($$->linecnt).second = ($6->linecnt).second;
        
		
        $$->getptr()->getfploc()->clear();$$->getptr()->setfp($1->getptr()->getfp());$$->getptr()->setrt(getRT($1));
	}
	|  ID
	{
        $$ = new SymbolInfo();
        $$ -> name = "declaration_list : ID";
        $$ -> pb($1);
		
        ($$->linecnt).first = ($1->linecnt).first;
        ($$->linecnt).second = ($1->linecnt).second;
        
        $$->getptr()->getfploc()->clear();$$->getptr()->setfp($1->getptr()->getfp());$$->getptr()->setrt(getRT($1));
	}
	|  ID LSQUARE CONST_INT RSQUARE
	{
        $$ = new SymbolInfo();
        $$ -> name = "declaration_list : ID LSQUARE CONST_INT RSQUARE";
        $$ -> pb($1);
		$$ -> pb( $2 );
		$$ -> pb( $3 );
		$$ -> pb( $4 );
		
        ($$->linecnt).first = ($1->linecnt).first;
        ($$->linecnt).second = ($4->linecnt).second;
        
        $$->getptr()->getfploc()->clear();$$->getptr()->setfp($1->getptr()->getfp());$$->getptr()->setrt(getRT($1));
	}
    ;

statements :  statement
	{
        
        $$ = new SymbolInfo();
		$$->name = "statements : statement";
        $$->pb($1);
        ($$->linecnt).first = ($1->linecnt).first;
        ($$->linecnt).second = ($1->linecnt).second;
        
        $$->getptr()->getfploc()->clear();$$->getptr()->setfp($1->getptr()->getfp());$$->getptr()->setrt(getRT($1));
		
	}
	|  statements statement
	{
		
        $$ = new SymbolInfo();
        $$ -> name = "statements : statements statement";
        $$ -> pb($1);
		$$ -> pb( $2 );
		
        ($$->linecnt).first = ($1->linecnt).first;
        ($$->linecnt).second = ($2->linecnt).second;
        
        $$->getptr()->getfploc()->clear();$$->getptr()->setfp($1->getptr()->getfp());$$->getptr()->setrt(getRT($1));
	}
    ;

statement :  var_declaration
	{
		
        $$ = new SymbolInfo();
		$$->name = "statement : var_declaration";
        $$->pb($1);
		
        ($$->linecnt).first = ($1->linecnt).first;
        ($$->linecnt).second = ($1->linecnt).second;
        
        $$->getptr()->getfploc()->clear();$$->getptr()->setfp($1->getptr()->getfp());$$->getptr()->setrt(getRT($1));
	}
	|  expression_statement
	{
        $$ = new SymbolInfo();
		$$->name = "statement : expression_statement";
        $$->pb($1);

		
        ($$->linecnt).first = ($1->linecnt).first;
        ($$->linecnt).second = ($1->linecnt).second;
        
        $$->getptr()->getfploc()->clear();$$->getptr()->setfp($1->getptr()->getfp());$$->getptr()->setrt(getRT($1));
	}
	|  compound_statement
	{
        $$ = new SymbolInfo();
		$$->name = "statement : compound_statement";
        $$->pb($1);
		
        ($$->linecnt).first = ($1->linecnt).first;
        ($$->linecnt).second = ($1->linecnt).second;
        
        $$->getptr()->getfploc()->clear();$$->getptr()->setfp($1->getptr()->getfp());$$->getptr()->setrt(getRT($1));
	}
	|  FOR LPAREN expression_statement expression_statement expression RPAREN statement
	{
        $$ = new SymbolInfo();
        $$ -> name = "statement : FOR LPAREN expression_statement expression_statement expression RPAREN statement";
        $$ -> pb($1);
		$$ -> pb( $2 );
		$$ -> pb( $3 );
		$$ -> pb( $4 );
		$$ -> pb( $5 );
		$$ -> pb( $6 );
		$$ -> pb( $7 );
		
        ($$->linecnt).first = ($1->linecnt).first;
        ($$->linecnt).second = ($7->linecnt).second;
        $$->getptr()->getfploc()->clear();$$->getptr()->setfp($1->getptr()->getfp());$$->getptr()->setrt(getRT($1));
	}
	|  FOR LPAREN expression_statement expression_statement RPAREN statement
	{
		
        $$ = new SymbolInfo();
        $$ -> name = "statement : FOR LPAREN expression_statement expression_statement RPAREN statement";
        $$ -> pb($1);
		$$ -> pb( $2 );
		$$ -> pb( $3 );
		$$ -> pb( $4 );
		$$ -> pb( $5 );
		$$ -> pb( $6 );
		
        ($$->linecnt).first = ($1->linecnt).first;
        ($$->linecnt).second = ($6->linecnt).second;
        
        $$->getptr()->getfploc()->clear();$$->getptr()->setfp($1->getptr()->getfp());$$->getptr()->setrt(getRT($1));
	}
	|  IF LPAREN expression RPAREN statement %prec SINGLE_IF
	{
        $$ = new SymbolInfo();
        $$ -> name = "statement : IF LPAREN expression RPAREN statement";
        $$ -> pb($1);
		$$ -> pb( $2 );
		$$ -> pb( $3 );
		$$ -> pb( $4 );
		$$ -> pb( $5 );
        ($$->linecnt).first = ($1->linecnt).first;
        ($$->linecnt).second = ($5->linecnt).second;
        
        $$->getptr()->getfploc()->clear();$$->getptr()->setfp($1->getptr()->getfp());$$->getptr()->setrt(getRT($1));
	}
	|  IF LPAREN expression RPAREN statement ELSE statement
	{
        $$ = new SymbolInfo();
        $$ -> name = "statement : IF LPAREN expression RPAREN statement ELSE statement";
        $$ -> pb($1);
		$$ -> pb( $2 );
		$$ -> pb( $3 );
		$$ -> pb( $4 );
		$$ -> pb( $5 );
		$$ -> pb( $6 );
		$$ -> pb( $7 );
		
        ($$->linecnt).first = ($1->linecnt).first;
        ($$->linecnt).second = ($7->linecnt).second;
        
        $$->getptr()->getfploc()->clear();$$->getptr()->setfp($1->getptr()->getfp());$$->getptr()->setrt(getRT($1));
	}
	|  WHILE LPAREN expression RPAREN statement
	{
        $$ = new SymbolInfo();
        $$ -> name = "statement : WHILE LPAREN expression RPAREN statement";
        $$ -> pb($1);
		$$ -> pb( $2 );
		$$ -> pb( $3 );
		$$ -> pb( $4 );
		$$ -> pb( $5 );
		
        ($$->linecnt).first = ($1->linecnt).first;
        ($$->linecnt).second = ($5->linecnt).second;
        
        $$->getptr()->getfploc()->clear();$$->getptr()->setfp($1->getptr()->getfp());$$->getptr()->setrt(getRT($1));
	}
	|  PRINTLN LPAREN ID RPAREN SEMICOLON
	{
        $$ = new SymbolInfo();
        $$ -> name = "statement : PRINTLN LPAREN ID RPAREN SEMICOLON";
        $$ -> pb($1);
		$$ -> pb( $2 );
		$$ -> pb( $3 );
		$$ -> pb( $4 );
        ($$->linecnt).first = ($1->linecnt).first;
        ($$->linecnt).second = ($4->linecnt).second;
        
        $$->getptr()->getfploc()->clear();$$->getptr()->setfp($1->getptr()->getfp());$$->getptr()->setrt(getRT($1));
	}
	|  RETURN expression SEMICOLON
	{
        $$ = new SymbolInfo();
        $$ -> name = "statement : RETURN expression SEMICOLON";
        $$ -> pb($1);
		$$ -> pb( $2 );
		$$ -> pb( $3 );
		
        ($$->linecnt).first = ($1->linecnt).first;
        ($$->linecnt).second = ($3->linecnt).second;
        
        $$->getptr()->getfploc()->clear();$$->getptr()->setfp($1->getptr()->getfp());$$->getptr()->setrt(getRT($1));
	}
	| func_declaration
	{
        $$ = new SymbolInfo();
        $$ -> name = "statement : func_declaration";
        $$ -> pb($1);
        ($$->linecnt).first = ($1->linecnt).first;
        ($$->linecnt).second = ($1->linecnt).second;
        
        $$->getptr()->getfploc()->clear();$$->getptr()->setfp($1->getptr()->getfp());$$->getptr()->setrt(getRT($1));
		//yyerror("Function declaration is not in global scope", -1);
	}
	| func_definition
	{
        $$ = new SymbolInfo();
        $$ -> name = "statement : func_definition";
        $$ -> pb($1);

        ($$->linecnt).first = ($1->linecnt).first;
        ($$->linecnt).second = ($1->linecnt).second;
		
        
        $$->getptr()->getfploc()->clear();$$->getptr()->setfp($1->getptr()->getfp());$$->getptr()->setrt(getRT($1));
		yyerror("Function defination is not in global scope", -1);
	}
	;

expression_statement :  SEMICOLON
	{
        $$ = new SymbolInfo();
        $$ -> name = "expression_statement : SEMICOLON";
        $$ -> pb($1);
		
        ($$->linecnt).first = ($1->linecnt).first;
        ($$->linecnt).second = ($1->linecnt).second;
        
        $$->getptr()->getfploc()->clear();$$->getptr()->setfp($1->getptr()->getfp());$$->getptr()->setrt(getRT($1));
	}
	|  expression SEMICOLON
	{
        $$ = new SymbolInfo();
        $$ -> name = "expression_statement : expression SEMICOLON";
        $$ -> pb($1);
		$$ -> pb( $2 );
        ($$->linecnt).first = ($1->linecnt).first;
        ($$->linecnt).second = ($2->linecnt).second;
        
        $$->getptr()->getfploc()->clear();$$->getptr()->setfp($1->getptr()->getfp());$$->getptr()->setrt(getRT($1));
	}
    | error {if(goter == 0){
                    goter = yylineno;
                    }
                    } SEMICOLON   {

            yyerror("Syntax error at expression of expression statement", goter);
            SymbolInfo* nsm = new SymbolInfo("error", "expression");//, , pii(goter, goter));
            //nsm->name = "expression : error";
            nsm->linecnt = pii(goter,goter);// ($3->linecnt).second);
            $$ = new SymbolInfo();
            $$ -> name = "expression_statement : expression SEMICOLON";
            ($$->linecnt).first = goter;
            ($$->linecnt).second = ($3->linecnt).second;
            $$->pb(nsm);
            $$->pb($3);
            goter = 0;
        }
	;

variable :  ID
	{
        cout << yylineno << " yylineno here " << endl;
        $$ = new SymbolInfo();
	    $$->name = "variable : ID";	
        vector <SymbolInfo*> vsim = getall($1);
		$1 -> getptr()-> setrt(getvartype(vsim[0] ->name));
		$$->pb( $1 );
        ($$->linecnt).first = ($1->linecnt).first;
        ($$->linecnt).second = ($1->linecnt).second;
        
        $$->getptr()->getfploc()->clear();$$->getptr()->setfp($1->getptr()->getfp());$$->getptr()->setrt(getRT($1));
		
	}
	|  ID LSQUARE expression RSQUARE
	{
        $$ = new SymbolInfo();
        $$ -> name = "variable : ID LSQUARE expression RSQUARE";
            
		$1 -> getptr()-> setrt(getaratype(getall($1)[0] -> name ));
		if(getRT($3) != Int)
		{
			if( getRT($3) != Error )
				// yyerror("Non-integer Array Index index type : "+ $3 -> getptr() -> getRT(), -1);
				yyerror("Array subscript is not an integer", -1);
		}

        $$ -> pb($1);
		$$ -> pb( $2 );
        $$ -> pb($3);
		$$ -> pb( $4 );
        ($$->linecnt).first = ($1->linecnt).first;
        ($$->linecnt).second = ($4->linecnt).second;
        
        $$->getptr()->getfploc()->clear();$$->getptr()->setfp($1->getptr()->getfp());$$->getptr()->setrt(getRT($1));
	}
	;

expression :  logic_expression
	{
        $$ = new SymbolInfo();
        $$ -> name = "expression : logic_expression";

        $$ -> pb($1);
		
        ($$->linecnt).first = ($1->linecnt).first;
        ($$->linecnt).second = ($1->linecnt).second;
        $$->getptr()->getfploc()->clear();$$->getptr()->setfp($1->getptr()->getfp());$$->getptr()->setrt(getRT($1));
	}
	|  variable ASSIGNOP logic_expression
	{
        $$ = new SymbolInfo();
        $$ -> name = "expression : variable ASSIGNOP logic_expression";
		RT type1 = getRT($1);
		RT type2 = getRT($3);

		if( typematch(type1 ,    type2 ) == false ) {
            if(type1 != Error and type2 != Error) {
                if (type1 == Void || type2 == Void) 
                    yyerror("Void cannot be used in expression ", -1);
                else 
                    yyerror("Type Mismatch : "+ rttostr(type1) + " " + $2 -> name + " " + rttostr(type2), -1);
                }
		}
			
		$1 -> getptr() -> setrt(type1);
		

        $$ -> pb($1);
        $$ -> pb($2);
        $$ -> pb($3);
        ($$->linecnt).first = ($1->linecnt).first;
        ($$->linecnt).second = ($3->linecnt).second;
        
        $$->getptr()->getfploc()->clear();$$->getptr()->setfp($1->getptr()->getfp());$$->getptr()->setrt(getRT($1));
	}
	;

logic_expression :  rel_expression
	{
        $$ = new SymbolInfo();
        $$ -> name = "logic_expression : rel_expression";
        $$ -> pb($1);
        ($$->linecnt).first = ($1->linecnt).first;
        ($$->linecnt).second = ($1->linecnt).second;
		
        $$->getptr()->getfploc()->clear();$$->getptr()->setfp($1->getptr()->getfp());$$->getptr()->setrt(getRT($1));
       /* 
         if (yylineno == 45) {
            //cout << "log to rel 44444444444555555555555555555555 " << $$->getptr()->getfploc()->size()<< endl;
            for (RT fp : $$->getptr()->getfp()) //cout << rttostr(fp) << endl;
        }
        */
	}
	|  rel_expression LOGICOP rel_expression
	{

        $$ = new SymbolInfo();
        $$ -> name = "logic_expression : rel_expression LOGICOP rel_expression";
		RT type1  = $1->getptr()->getrt();
		RT type2  = $3->getptr()->getrt();
		RT resultType = Error;

		if(type1!=Int or type2 != Int ){
			if(type1 != Error and type2 != Error)
				yyerror("Type Mismatch of Logic operation : " + to_string(type1) + " "+ $2 ->getptr()->gettype() +  " " + to_string(type2), -1);
		}
		else 
			resultType = Int;

		$1 -> getptr() -> setrt(resultType);

        $$ -> pb($1);
        $$ -> pb($2);
        $$ -> pb($3);
        ($$->linecnt).first = ($1->linecnt).first;
        ($$->linecnt).second = ($3->linecnt).second;
        
        $$->getptr()->getfploc()->clear();$$->getptr()->setfp($1->getptr()->getfp());$$->getptr()->setrt(getRT($1));
	}
	;

rel_expression :  simple_expression
	{
        $$ = new SymbolInfo();
        $$ -> name = "rel_expression : simple_expression";
        $$ -> pb($1);
        ($$->linecnt).first = ($1->linecnt).first;
        ($$->linecnt).second = ($1->linecnt).second;
		
        
        $$->getptr()->getfploc()->clear();$$->getptr()->setfp($1->getptr()->getfp());$$->getptr()->setrt(getRT($1));

	}
	|  simple_expression RELOP simple_expression
	{
        $$ = new SymbolInfo();
        $$ -> name = "rel_expression : simple_expression RELOP simple_expression";

		RT type1 = getRT($1);
		RT type2 = getRT($3);
		RT resultType = Error;
		if(type1 == Error or type2 == Error)
			;
		else if(type1 == Void or type2 == Void )
			yyerror("Type Mismatch of relational operation : " + to_string(type1) + " "+ $2 ->getptr()->gettype() +  " " + to_string(type2), -1);
		else 
			resultType = Int;
		
		$1 -> getptr() -> setrt(resultType);

        $$ -> pb($1);
        $$ -> pb($2);
        $$ -> pb($3);
        ($$->linecnt).first = ($1->linecnt).first;
        ($$->linecnt).second = ($3->linecnt).second;
        
        $$->getptr()->getfploc()->clear();$$->getptr()->setfp($1->getptr()->getfp());$$->getptr()->setrt(getRT($1));
	}
	;

simple_expression :  term
	{
        $$ = new SymbolInfo();
        $$ -> name = "simple_expression : term";
        $$ -> pb($1);
        ($$->linecnt).first = ($1->linecnt).first;
        ($$->linecnt).second = ($1->linecnt).second;
        
        $$->getptr()->getfploc()->clear();$$->getptr()->setfp($1->getptr()->getfp());$$->getptr()->setrt(getRT($1));
        
	}
	|  simple_expression ADDOP term
	{
        $$ = new SymbolInfo();
        $$ -> name = "simple_expression : simple_expression ADDOP term";
        ////////cout << " here befole arithtype " << endl;
		$1 -> getptr() -> setrt( arithtype(getRT($1) , getRT($3)) );
        //////cout << " here after arithtype " << endl;

        $$ -> pb($1);
        $$ -> pb($2);
        $$ -> pb($3);
		
        ($$->linecnt).first = ($1->linecnt).first;
        ($$->linecnt).second = ($3->linecnt).second;
        
        $$->getptr()->getfploc()->clear();$$->getptr()->setfp($1->getptr()->getfp());$$->getptr()->setrt(getRT($1));
	}
	;

term :  unary_expression
	{
        $$ = new SymbolInfo();
        $$ -> name = "term : unary_expression";
        $$ -> pb($1);
        ($$->linecnt).first = ($1->linecnt).first;
        ($$->linecnt).second = ($1->linecnt).second;
        

        $$->getptr()->getfploc()->clear();$$->getptr()->setfp($1->getptr()->getfp());$$->getptr()->setrt(getRT($1));
		
	}
	|  term MULOP unary_expression
	{

        $$ = new SymbolInfo();
        $$ -> name = "term : term MULOP unary_expression";
		RT type1 = getRT($1);
		RT type2 = getRT($3);
		RT resultType  = Error;
        cout << yylineno << " here mod " << $2->name << endl;
		if(getall($2)[0] -> name == "%")
		{
            cout  << yylineno << " here after mod " << $3->name << endl;
			if(type1 != Int or type2 != Int) 
			{
				if(type1 != Error and type2 != Error)
					yyerror("Operands of modulus must be integers ", -1);
			}
			else if(zeroval(getall($3)[0] -> name) )
				yyerror("Warning: division by zero i=0f=1Const=0", -1);
			else
				resultType = Int;
		}
		else {
        //////cout <<  " another arith " << endl;
			resultType  = arithtype(type1 , type2);
        //////cout <<  " another arith finish" << endl;
        }
	
		$1 -> getptr() -> setrt( resultType);

        $$ -> pb($1);
        $$ -> pb($2);
        $$ -> pb($3);
		
        ($$->linecnt).first = ($1->linecnt).first;
        ($$->linecnt).second = ($3->linecnt).second;
        
        $$->getptr()->getfploc()->clear();$$->getptr()->setfp($1->getptr()->getfp());$$->getptr()->setrt(getRT($1));
	}
	;

unary_expression :  ADDOP unary_expression
	{
        $$ = new SymbolInfo();
        $$ -> name = "unary_expression : ADDOP unary_expression";
		RT type = getRT($2);
		RT resultType = Error;

		switch (type)
		{
		case Void:
			yyerror("Void statement used in expression ", -1);
			break;

		default:
			resultType = type;
			break;
		}

		$1->getptr()->setrt(resultType);

		
        $$ -> pb($1);
        $$ -> pb($2);
        ($$->linecnt).first = ($1->linecnt).first;
        ($$->linecnt).second = ($2->linecnt).second;
        
        $$->getptr()->getfploc()->clear();$$->getptr()->setfp($1->getptr()->getfp());$$->getptr()->setrt(getRT($1));
	}
	|  NOT unary_expression
	{
        $$ = new SymbolInfo();
        $$ -> name = "unary_expression : ADDOP unary_expression";
		RT type = $2->getptr()->getrt();
		RT resultType = Error;

		switch (type)
		{
		case Void:
			yyerror("Void statement used in expression ", -1);
			break;

		case Float:
			yyerror("Invalid not operation for float type", -1);
			break;

		case Int:
			resultType = Int;
			break;
		
		default:
			break;
		}

		$1->getptr()->setrt(resultType);

        $$ -> pb($1);
        $$ -> pb($2);
		
        ($$->linecnt).first = ($1->linecnt).first;
        ($$->linecnt).second = ($2->linecnt).second;
        
        $$->getptr()->getfploc()->clear();$$->getptr()->setfp($1->getptr()->getfp());$$->getptr()->setrt(getRT($1));
	}
	|  factor
	{
        $$ = new SymbolInfo();
        $$ -> name = "unary_expression : factor";
        $$ -> pb($1);
        ($$->linecnt).first = ($1->linecnt).first;
        ($$->linecnt).second = ($1->linecnt).second;
        
        $$->getptr()->getfploc()->clear();
        $$->getptr()->getfploc()->clear();$$->getptr()->setfp($1->getptr()->getfp());$$->getptr()->setrt(getRT($1));

	}
	;

factor :  variable
	{
        $$ = new SymbolInfo();
        $$ -> name = "factor : variable";
        $$ -> pb($1);
		
        ($$->linecnt).first = ($1->linecnt).first;
        ($$->linecnt).second = ($1->linecnt).second;
        
        $$->getptr()->getfploc()->clear();$$->getptr()->setfp($1->getptr()->getfp());$$->getptr()->setrt(getRT($1));
	}
	|  ID LPAREN argument_list RPAREN
	{
        $$ = new SymbolInfo();
        $$ -> name = "factor : ID LPAREN argument_list RPAREN";
        vector <SymbolInfo*> vsim = getall($1);
		$1 -> getptr() -> setrt( getrettype(vsim[0]->name ,$3));
        vsim = getall($3);
        if (yylineno == 48) cout << "hhhhhhhhhhhhhhhhhhhhhhhhhhhh " << vsim.size() << endl;
        int cnt = 0;
        for (int i = 0; i < vsim.size(); i++) {
            if ((vsim[i]->value).type != "ID") continue;
            cnt++;
            if (yylineno == 48) cout << "hhhhhhhhhhhhhhhhhhhhhhhhhhhh " << vsim[i]->name << endl;
            SymbolInfo* rf = table->LookUp(vsim[i]->name);
            if (rf != NULL && ((rf->getptr()->isara() && (i == vsim.size() - 1 || vsim[i + 1]->name != "[")) || (rf->getptr()->isfunction() && (i == vsim.size() - 1 || vsim[i + 1]->name != "(")))) {
                yyerror("Type mismatch for argument " + inttostr(cnt) + " of '" + $1->name + "'", (vsim[i]->linecnt).first);
            }
        }
        ////cout <<vsim[0]->name << " " <<  rttostr(getrettype(getall($1)[0]->name, $3)) << " here the type " << endl; 
        ////cout << " before loop " << endl;
        ////cout << getall($1)[0]->name << " " << " ddddddddddddddddddddddddd  " << (getall($3)[0]->value).type << endl;
        $$ -> pb($1);
        $$ -> pb($2);
        $$ -> pb($3);
        $$ -> pb($4);
        ($$->linecnt).first = ($1->linecnt).first;
        ($$->linecnt).second = ($4->linecnt).second;
        $$->getptr()->getfploc()->clear();$$->getptr()->setfp($1->getptr()->getfp());$$->getptr()->setrt(getRT($1));
	}
	|  LPAREN expression RPAREN
	{
        $$ = new SymbolInfo();
        $$ -> name = "factor : LPAREN expression RPAREN";
		$1 -> getptr()->setrt( getRT($2));

		
        $$ -> pb($1);
        $$ -> pb($2);
        $$ -> pb($3);
        ($$->linecnt).first = ($1->linecnt).first;
        ($$->linecnt).second = ($3->linecnt).second;
        $$->getptr()->getfploc()->push_back(getRT($2));
        
        $$->getptr()->getfploc()->clear();$$->getptr()->setfp($1->getptr()->getfp());$$->getptr()->setrt(getRT($1));
	}
	|  CONST_INT
	{
        $$ = new SymbolInfo();
        $$ -> name = "factor : CONST_INT";
		$1->getptr() -> setrt(Int);
        $$ -> pb($1);
		
        ($$->linecnt).first = ($1->linecnt).first;
        ($$->linecnt).second = ($1->linecnt).second;
        
        $$->getptr()->getfploc()->clear();
        $$->getptr()->setrt(getRT($1));
	}
	|  CONST_FLOAT
	{
		
        $$ = new SymbolInfo();
        $$ -> name = "factor : CONST_FLOAT";
		$1->getptr() -> setrt(Float);
        $$ -> pb($1);
		
        ($$->linecnt).first = ($1->linecnt).first;
        ($$->linecnt).second = ($1->linecnt).second;
        $$->getptr()->getfploc()->push_back(getRT($1));
        //cout << rttostr(getRT($1)) << "float " << yylineno<< endl;
        //cout << $$->name << " " << $1->name << endl;
        
        $$->getptr()->getfploc()->clear();
        //cout << $$->getptr()->getfploc()->size() << endl;
        $$->getptr()->setrt(getRT($1));// $1->getptr()->getfp());

	}
	|  variable INCOP
	{

        $$ = new SymbolInfo();
        $$ -> name = "factor : variable INCOP";

		RT type = getRT($1);
		RT resultType = Error;

		switch (type)
		{
		case Void:
			yyerror("Void statement used in expression ", -1);
			break;

		case Int:
		case Float:
			resultType = type;
			break;
			
		default:
			break;
		}

		$1 -> getptr() -> setrt(resultType);

		// if(getRT($1) != Int and getRT($1) != Float )
		// 	yyerror("Type Mismatch : "+ to_string(getRT($1)) + " INCOP", -1);

		
        $$ -> pb($1);
        $$ -> pb($2);
        ($$->linecnt).first = ($1->linecnt).first;
        ($$->linecnt).second = ($2->linecnt).second;
        
        $$->getptr()->getfploc()->clear();$$->getptr()->setfp($1->getptr()->getfp());$$->getptr()->setrt(getRT($1));
	}
	|  variable DECOP
	{
        $$ = new SymbolInfo();
        $$ -> name = "factor : variable DECOP";
		RT type = getRT($1);
		RT resultType = Error;

		switch (type)
		{
		case Void:
			yyerror("Void statement used in expression ", -1);
			break;

		case Int:
		case Float:
			resultType = type;
			break;

		default:
			break;
		}

		// if(getRT($1) != Int and getRT($1) != Float )
		// 	yyerror("Type Mismatch : "+ to_string(getRT($1)) + " DECOP", -1);

		$1 -> getptr() -> setrt(resultType);

		
        $$ -> pb($1);
        $$ -> pb($2);
		
        ($$->linecnt).first = ($1->linecnt).first;
        ($$->linecnt).second = ($2->linecnt).second;
        
        $$->getptr()->getfploc()->clear();$$->getptr()->setfp($1->getptr()->getfp());$$->getptr()->setrt(getRT($1));
	}
	;

argument_list :  arguments
	{
        $$ = new SymbolInfo();
        $$ -> name = "argument_list : arguments";
        $$ -> pb($1);
        ($$->linecnt).first = ($1->linecnt).first;
        ($$->linecnt).second = ($1->linecnt).second;
        
        $$->getptr()->getfploc()->clear();$$->getptr()->setfp($1->getptr()->getfp());$$->getptr()->setrt(getRT($1));
	}
	| 
	{
        $$ = new SymbolInfo();
        $$ -> name = "argument_list :";
		
	}
    ;

arguments :  arguments COMMA logic_expression
	{
       
        $$ = new SymbolInfo();
        $$ -> name = "arguments : arguments COMMA logic_expression";
		$1 -> getptr()->getfploc()->push_back(getRT($3));
        //cout << "getrt 3 " << rttostr(getRT($3)) << endl;
        $$ -> pb($1);
        $$ -> pb($2);
        $$ -> pb($3);
        ($$->linecnt).first = ($1->linecnt).first;
        ($$->linecnt).second = ($3->linecnt).second;
        $$->getptr()->getfploc()->clear();$$->getptr()->setfp($1->getptr()->getfp());$$->getptr()->setrt(getRT($1));

         /*if (yylineno == 45) {
            //cout << "arg to log 44444444444555555555555555555555 " << $$->getptr()->getfploc()->size()<< endl;
            for (RT fp : $$->getptr()->getfp()) //cout << rttostr(fp) << endl;
        }
        */
	}
	|  logic_expression
	{
        $$ = new SymbolInfo();
        $$ -> name = "arguments : logic_expression";
        $$ -> pb($1);
        ($$->linecnt).first = ($1->linecnt).first;
        ($$->linecnt).second = ($1->linecnt).second;
        $1->getptr()->getfploc()->push_back(getRT($1));
        $$->getptr()->getfploc()->clear();$$->getptr()->setfp($1->getptr()->getfp());$$->getptr()->setrt(getRT($1));

         /*if (yylineno == 45) {
            //cout << "arg to log  2 44444444444555555555555555555555 " << $$->getptr()->getfploc()->size()<< endl;
            for (RT fp : $$->getptr()->getfp()) //cout << rttostr(fp) << endl;
        }
        */
	}
			
    ;
%%
int main(int argc,char *argv[])
{
    freopen("log.txt", "w", stdout);
	FILE * fp ;
	fp=fopen(argv[1],"r");
	if( fp == NULL)
	{
		printf("Cannot Open Input File.\n");
		exit(1);
	}
	string error_file = "error.txt";
	table = new SymbolTable(30);
    parsestream.open("parsetree.txt", ios::out);
	errorstream.open(error_file , ios::out);
	yyin=fp;
	yyparse();
	yylex_destroy();
	delete table;

	fclose(fp);
	
	
	return 0;
}

