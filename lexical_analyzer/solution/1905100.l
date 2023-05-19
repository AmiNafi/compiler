%option noyywrap yylineno  
%{
#include "1905100.h"
#include <bits/stdc++.h>
using namespace std;
string commentbuff, strbuff;
SymbolTable mytable(10);
int ercnt = 0, multistring = 0;
void insert(string key, string val) {
    if (mytable.insert(key, val)) mytable.PrintAllScopeTable(cerr);
    else {
        cerr << "\t" << key << " already exisits in the current ScopeTable" << "\n";
    }
}
void tokenout(string t, string a) {
    cout << "<" << t;
    if (a.length() != 0) cout << ", " << a;
    cout << ">" << "\n";
}
string specialchar(string cur) {
    if (cur == "\\\"") cur = '"';
    else if (cur == "\\\\") cur = '\\';
    else if (cur == "\\t") cur = '\t';
    else if (cur == "\\0") cur = '\0';
    else if (cur == "\\f") cur = '\f';
    else if (cur == "\\v") cur = '\v';
    else if (cur == "\\b") cur = '\b';
    else if (cur == "\\r") cur = '\r';
    else if (cur == "\\a") cur = '\a';
    else if (cur == "\\\'") cur = '\'';
    else if (cur == "\\n") cur = '\n';
    else if (cur.size() == 2 && cur[0] == '\\') cur = cur[1];
    return cur;
}

string specialstr(string cur) {
    string ans = "";
    for (int i = 0; i < cur.length(); i++) {
        if (cur[i] == '\\') {
            if (cur[i + 1] == '\n') i++;
            else if (i + 2 < cur.size() && cur[i + 1] == '\r' && cur[i + 2] == '\n') i += 2;
            else {
                string nw = cur.substr(i, 2);
                ans += specialchar(nw);
                i++;
            }
        }
        else ans += cur[i];
    }
    ans.pop_back();
    ans.erase(ans.begin());
    return ans;
}
int lincnt(string all = yytext) {
    int mycnt = yylineno;
    for (char c : all) mycnt -= (c == '\n');
    return mycnt;
}
void printerror(string txt, string type, int ln) {
    ercnt++;
    cerr << "Error at line# "<< ln << ": " <<type << " " << txt << "\n";
}
%}

%x COMMENT_STATE
%x STR_STATE

NEWLINE \r?\n
CONTINUOUS_LINE \\{NEWLINE}
WHITESPACE [ \n\t\r]
WHITESPACES {WHITESPACE}+
LINE_COMMENT \/\/([^\r\n]|(\\{NEWLINE}))*
START_COMMENT "/*"
END_COMMENT "*/"
DIGIT [0-9]
CONST_INT [0-9]+
EXPONENT ((E|e)[+-]?{DIGIT}+)
CONST_FLOAT ((({DIGIT}+\.{DIGIT}*)|({DIGIT}*\.{DIGIT}+))((E|e)[+-]?{DIGIT}+)?)|({DIGIT}+((E|e)[+-]?{DIGIT}+))
MANY_DECIMAL_ERROR [0-9]*\.[0-9]*(\.[0-9]*)+(((E|e)[+-]?{DIGIT}+)\.{DIGIT}*)*
NUMID_ERROR ({CONST_FLOAT}|{CONST_INT}){IDENTIFIER}
ILL_FORMED_ERROR {CONST_FLOAT}(\.{DIGIT}*)*
ADDOP [+\-]
MULOP [*/%]
INCOP ("++")|("--")
RELOP ([<>]=?)|([=!]=)
LOGICOP "&&"|"||"
CHAR_VAL (\\{NEWLINE})*([^'\n\\\r]|\\.)(\\{NEWLINE})*
CONST_CHAR '{CHAR_VAL}'
ALPHANUMERIC_CHAR [a-zA-Z0-9]
ALPHABET_CHAR [a-zA-Z]
IDENTIFIER [a-zA-Z_]({ALPHANUMERIC_CHAR}|_)*
STRING_START \"
STRING_END \"
MULTI_CHAR_ERROR '{CHAR_VAL}{2,}'
UNFINISHED_CHAR_ERROR '{CHAR_VAL}?
EMPTY_CHAR_ERROR '(\\{NEWLINE})*'
%%
{NEWLINE} {

          }
{WHITESPACES}	{

				}
{LINE_COMMENT}	{
                    //cerr << yylineno << " line nong " << "\n";
					cerr << "Line# " << lincnt() << ": Token <SINGLE LINE COMMENT> Lexeme "<< yytext << " found\n";
}
{START_COMMENT}	{
							BEGIN COMMENT_STATE;
							commentbuff+=yytext;
					}
<COMMENT_STATE>{
	{END_COMMENT} {
        //cerr << commentbuff << " comment  buff " << " " << yytext << endl;
		commentbuff += yytext;
        //cerr << commentbuff << " new comment buff " << "\n";
        cerr << "Line# " << lincnt(commentbuff) << ": Token <MULTI LINE COMMENT> Lexeme "<< commentbuff << " found\n";
		commentbuff.clear();
		BEGIN INITIAL;
	}
	. commentbuff+=yytext;
	{WHITESPACES} commentbuff += yytext;
	<<EOF>> {
                printerror(commentbuff , "UNFINISHED_COMMENT", lincnt(commentbuff));
				commentbuff.clear();
				BEGIN INITIAL;
			}
}
{STRING_START} {
    multistring = 0;
	BEGIN STR_STATE;
	strbuff += yytext;
}
<STR_STATE>{
	{STRING_END}	{
			strbuff += yytext;
            string sp = specialstr(strbuff);
			if (multistring) {
                tokenout("MULTI LINE STRING" , sp);
                cerr << "Line# " << lincnt(strbuff) << ": Token <MULTI LINE STRING> Lexeme " << strbuff << " found\n";
            }            
            else {
                tokenout("SINGLE LINE STRING", sp);
                cerr << "Line# " << lincnt() << ": Token <SINGLE LINE STRING> Lexeme " << strbuff << " found\n";
            }		    			
			strbuff.clear();
			BEGIN INITIAL;
		}
	{CONTINUOUS_LINE} {
        strbuff += yytext;
        multistring = 1;
    }
	\\.	strbuff += yytext;
	. strbuff += yytext;

	<<EOF>> {
				printerror(strbuff,"UNFINISHED_STRING", lincnt(strbuff));
				strbuff.clear();
				BEGIN INITIAL;
			}
	\n {
				strbuff += yytext;
				printerror(strbuff,"UNFINISHED_STRING", lincnt(strbuff));
				strbuff.clear();
				BEGIN INITIAL;
			}
}
{CONST_INT}	{
		string val = string(yytext);
		tokenout("CONST_INT" , val);
        cerr << "Line# " << lincnt() << ": Token <CONST_INT> Lexeme " << val  << " found\n";
	}
{CONST_FLOAT}	{
		string val = string(yytext);
		tokenout("CONST_FLOAT" ,val);
		cerr<<"Line# "<< lincnt() <<": Token <CONST_FLOAT> Lexeme "<< val <<" found\n";
	}
{CONST_CHAR}	{
					string val = string(yytext);
					string asciival = val;
					if(asciival[0] == '\'') {
						asciival = asciival.substr(1);
                    }
					if(asciival.back() == '\'') {
						asciival.pop_back();
                    }
					asciival = specialchar(asciival);
					tokenout("CONST_CHAR" , asciival);
					cerr<<"Line# "<< lincnt() <<": Token <CONST_CHAR> Lexeme " << asciival << " found\n";				
				}

"if"    {
                tokenout("IF", string(yytext));
                cerr<<"Line# "<< lincnt() <<": Token <IF> Lexeme " << yytext << " found\n";
        }
"else"  {
                tokenout("ELSE", string(yytext));
                cerr<<"Line# "<< lincnt() <<": Token <ELSE> Lexeme " << yytext << " found\n";
        }
"for"   {
                tokenout("FOR", string(yytext));
                cerr<<"Line# "<< lincnt() <<": Token <FOR> Lexeme " << yytext << " found\n";
        }
"while" {
                tokenout("WHILE", string(yytext));
                cerr<<"Line# "<< lincnt() <<": Token <WHILE> Lexeme " << yytext << " found\n";
        }
"do"    {
                tokenout("DO", string(yytext));
                cerr<<"Line# "<< lincnt() <<": Token <DO> Lexeme " << yytext << " found\n";
        }
"break" {
                tokenout("BREAK", string(yytext));
                cerr<<"Line# "<< lincnt() <<": Token <BREAK> Lexeme " << yytext << " found\n";
        }
"int"   {
                tokenout("INT",string(yytext));
                cerr<<"Line# "<< lincnt() <<": Token <INT> Lexeme " << yytext << " found\n";
        }
"char"  {
                tokenout("CHAR",string(yytext));
                cerr<<"Line# "<< lincnt() <<": Token <CHAR> Lexeme " << yytext << " found\n";
        }
"float" {
                tokenout("FLOAT",string(yytext));
                cerr<<"Line# "<< lincnt() <<": Token <FLOAT> Lexeme " << yytext << " found\n";
        }
"double"        {
                tokenout("DOUBLE",string(yytext));
                cerr<<"Line# "<< lincnt() <<": Token <DOUBLE> Lexeme " << yytext << " found\n";
        }
"void"  {
                tokenout("VOID",string(yytext));
                cerr<<"Line# "<< lincnt() <<": Token <VOID> Lexeme " << yytext << " found\n";
        }
"return"        {
                tokenout("RETURN",string(yytext));
                cerr<<"Line# "<< lincnt() <<": Token <RETURN> Lexeme " << yytext << " found\n";
        }
"switch"        {
                tokenout("SWITCH",string(yytext));
                cerr<<"Line# "<< lincnt() <<": Token <SWITCH> Lexeme " << yytext << " found\n";
        }
"case"  {
                tokenout("CASE",string(yytext));
                cerr<<"Line# "<< lincnt() <<": Token <CASE> Lexeme " << yytext << " found\n";
        }
"default"       {
                tokenout("DEFAULT",string(yytext));
                cerr<<"Line# "<< yylineno <<": Token <DEFAULT> Lexeme " << yytext << " found\n";
        }
"continue"      {
                tokenout("CONTINUE",string(yytext));
                cerr<<"Line# "<< yylineno <<": Token <CONTINUE> Lexeme " << yytext << " found\n";
        }
"="     {
                tokenout("ASSIGNOP",string(yytext));
                cerr<<"Line# "<< lincnt() <<": Token <ASSIGNOP> Lexeme " << yytext << " found\n";
        }
"!"     {
                tokenout("NOT",string(yytext));
                cerr<<"Line# "<< lincnt() <<": Token <NOT> Lexeme " << yytext << " found\n";
        }
"("     {
                tokenout("LPAREN",string(yytext));
                cerr<<"Line# "<< lincnt() <<": Token <LPAREN> Lexeme " << yytext << " found\n";
        }
")"     {
                tokenout("RPAREN",string(yytext));
                cerr<<"Line# "<< lincnt() <<": Token <RPAREN> Lexeme " << yytext << " found\n";
        }
"{"     {
                tokenout("LCURL",string(yytext));
				mytable.EnterScope(10);
                cerr<<"Line# "<< lincnt() <<": Token <LCURL> Lexeme " << yytext << " found\n";
        }
"}"     {
                tokenout("RCURL",string(yytext));
				mytable.ExitScope();
                cerr<<"Line# "<< lincnt() <<": Token <RCURL> Lexeme " << yytext << " found\n";
        }
"["     {
                tokenout("LSQUARE",string(yytext));
                cerr<<"Line# "<< lincnt() <<": Token <LSQUARE> Lexeme " << yytext << " found\n";
        }
"]"     {
                tokenout("RSQUARE",string(yytext));
                cerr<<"Line# "<< lincnt() <<": Token <RSQUARE> Lexeme " << yytext << " found\n";
        }
","     {
                tokenout("COMMA",string(yytext));
                cerr<<"Line# "<< lincnt() <<": Token <COMMA> Lexeme " << yytext << " found\n";
        }
";"     {
                tokenout("SEMICOLON",string(yytext));
                cerr<<"Line# "<< lincnt() <<": Token <SEMICOLON> Lexeme " << yytext << " found\n";
        }
{LOGICOP}	{
				tokenout("LOGICOP",string(yytext));
                cerr<<"Line# "<< lincnt() <<": Token <LOGICOP> Lexeme " << yytext << " found\n";
        }
{ADDOP}		{
				tokenout("ADDOP",string(yytext));
                cerr<<"Line# "<< lincnt() <<": Token <ADDOP> Lexeme " << yytext << " found\n";
			}
{MULOP}		{
				tokenout("MULOP",string(yytext));
                cerr<<"Line# "<< lincnt() <<": Token <MULOP> Lexeme "<<yytext<<" found\n";
			}
{INCOP}		{
				tokenout("INCOP",string(yytext));
                cerr<<"Line# "<< lincnt() <<": Token <INCOP> Lexeme "<<yytext<<" found\n";
			}
{RELOP}		{
				tokenout("RELOP",string(yytext));
                cerr<<"Line# "<< lincnt() <<": Token <RELOP> Lexeme "<<yytext<<" found\n";
			}
{IDENTIFIER}	{ 
					string val = string(yytext);
					tokenout("ID" , val);
					cerr<<"Line# "<< lincnt() <<": Token <ID> Lexeme "<< val <<" found\n";
					insert(val , "ID");
				}


{MANY_DECIMAL_ERROR}	{
								printerror(yytext, "TOO_MANY_DECIMAL_POINTS", lincnt());
							}
{NUMID_ERROR}		{
								printerror(yytext, "INVALID_ID_SUFFIX_NUM_PREFIX", lincnt());
								}
{ILL_FORMED_ERROR}	{
								printerror(yytext, "ILLFORMED_NUMBER", lincnt());
						}
{MULTI_CHAR_ERROR}	{
                            printerror(yytext, "MULTICHAR_CONST_CHAR", lincnt());
					}
{UNFINISHED_CHAR_ERROR}	{
                            printerror(yytext, "UNFINISHED_CONST_CHAR", lincnt());
						}	
{EMPTY_CHAR_ERROR}	{
                            printerror(yytext, "EMPTY_CONST_CHAR", lincnt());
					}
.	{

                            printerror(yytext, "UNRECOGNIZED_CHAR", lincnt());
	}
%%

int main (int argc, char* argv[]) {
    if(argc!=2){
        printf("Please provide input file name and try again\n");
        return 0;
    }
    
    FILE *fin=fopen(argv[1],"r");
    if(fin==NULL){
        printf("Cannot open specified file\n");
        return 0;
    }
    freopen("log.txt" , "w+" , stderr);
    freopen("token.txt" , "w+" , stdout);
    yylineno = 1;

    yyin= fin;
    yylex();
    mytable.PrintAllScopeTable(cerr);
	cerr<<"Total lines: "<< yylineno <<"\n";
	cerr<<"Total errors: " << ercnt  <<"\n";
    fclose(yyin);
    yylex_destroy();
    return 0;
}
