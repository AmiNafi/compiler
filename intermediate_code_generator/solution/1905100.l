%option noyywrap yylineno  
%{
#include "1905100.h"
#include "y.tab.h"
#include <bits/stdc++.h>
using namespace std;
extern ofstream logstream;
extern ofstream errorstream;
extern YYSTYPE yylval;
void yyerror(const string &s, int nm = -1);
string commentbuff, strbuff;
int multistring = 0;
SymbolInfo* tokenout(string t, string a) {
    /*
    cout << "<" << t;
    if (a.length() != 0) cout << ", " << a;
    cout << ">" << "\n";
    if (a == "") {
        a = yytext;
    }
    */
    /*
    SymbolInfo* ret = new SymbolInfo();
    ret->name = a;
    ret->value.type = t;
    ret->linecnt = pii(yylineno, yylineno);
    */
    return new SymbolInfo(a, t, pii(yylineno, yylineno));
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
    /*
    string c = "\n";
    if (txt.back() == c.back()) c = "";
    logstream << "Error at line# "<< ln << ": " <<type << " " << txt << c;
    yyerror(type + " " + txt);
    */
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
CHAR_VAL (\\{NEWLINE})*([^'\n\\\r]|\\.)(\\{NEWLINE})*
CONST_CHAR '{CHAR_VAL}'
ALPHANUMERIC_CHAR [a-zA-Z0-9]
ALPHABET_CHAR [a-zA-Z]
IDENTIFIER [a-zA-Z_]({ALPHANUMERIC_CHAR}|_)*
STRING_START \"
STRING_END \"
ADDOP [+\-]
MULOP [*/%]
INCOP ("++")
DECOP ("--")
RELOP ([<>]=?)|([=!]=)
LOGICOP "&&"|"||"
MULTI_CHAR_ERROR '{CHAR_VAL}{2,}'
UNFINISHED_CHAR_ERROR '{CHAR_VAL}?
EMPTY_CHAR_ERROR '(\\{NEWLINE})*'
%%
"return"  {
            yylval.sp = tokenout("RETURN",string(yytext)); logstream<<"Line# "<< lincnt() <<": Token <RETURN> Lexeme " << yytext << " found\n";
            return RETURN;
        }
{NEWLINE} {

          }
{WHITESPACES}	{

				}
{LINE_COMMENT}	{
                    //logstream << yylineno << " line nong " << "\n";
					logstream << "Line# " << yylineno << ": Token <SINGLE LINE COMMENT> Lexeme "<< yytext << " found\n";
}
{START_COMMENT}	{
							BEGIN COMMENT_STATE;
							commentbuff+=yytext;
					}
<COMMENT_STATE>{
	{END_COMMENT} {
        //logstream << commentbuff << " comment  buff " << " " << yytext << endl;
		commentbuff += yytext;
        //logstream << commentbuff << " new comment buff " << "\n";
        logstream << "Line# " << lincnt(commentbuff) << ": Token <MULTI LINE COMMENT> Lexeme "<< commentbuff << " found\n";
		commentbuff.clear();
		BEGIN INITIAL;
	}
	. commentbuff+=yytext;
	{WHITESPACES} commentbuff += yytext;
	<<EOF>> {
                printerror(commentbuff , "UNFINISHED_COMMENT", yylineno);
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
                yylval.sp = tokenout("MULTI LINE STRING" , sp);
                logstream << "Line# " << lincnt(strbuff) << ": Token <MULTI LINE STRING> Lexeme " << strbuff << " found\n";
            }            
            else {
                yylval.sp = tokenout("SINGLE LINE STRING", sp);
                logstream << "Line# " << lincnt() << ": Token <SINGLE LINE STRING> Lexeme " << strbuff << " found\n";
            }		    			
			strbuff.clear();
			BEGIN INITIAL;
            return STRING;
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
		yylval.sp = tokenout("CONST_INT" , val);
        logstream << "Line# " << lincnt() << ": Token <CONST_INT> Lexeme " << val  << " found\n";
        return CONST_INT;
	}
{CONST_FLOAT}	{
		string val = string(yytext);
		yylval.sp = tokenout("CONST_FLOAT" ,val);
		logstream<<"Line# "<< lincnt() <<": Token <CONST_FLOAT> Lexeme "<< val <<" found\n";
        return CONST_FLOAT;
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
					yylval.sp = tokenout("CONST_CHAR" , asciival);
					logstream<<"Line# "<< lincnt() <<": Token <CONST_CHAR> Lexeme " << asciival << " found\n";				
                return CONST_CHAR;
				}

"if"    {
                yylval.sp = tokenout("IF", string(yytext));
                logstream<<"Line# "<< lincnt() <<": Token <IF> Lexeme " << yytext << " found\n";
                return IF;
        }
"else"  {
                yylval.sp = tokenout("ELSE", string(yytext));
                logstream<<"Line# "<< lincnt() <<": Token <ELSE> Lexeme " << yytext << " found\n";
                return ELSE;
        }
"for"   {
            yylval.sp = tokenout("FOR", string(yytext)); logstream<<"Line# "<< lincnt() <<": Token <FOR> Lexeme " << yytext << " found\n"; return FOR; 
        }

"while" { 
            yylval.sp = tokenout("WHILE", string(yytext)); logstream<<"Line# "<< lincnt() <<": Token <WHILE> Lexeme " << yytext << " found\n"; return WHILE;
        }
"do"    {
            yylval.sp = tokenout("DO", string(yytext)); logstream<<"Line# "<< lincnt() <<": Token <DO> Lexeme " << yytext << " found\n"; return DO; 
        }
"break" {
            yylval.sp = tokenout("BREAK", string(yytext));
            logstream<<"Line# "<< lincnt() <<": Token <BREAK> Lexeme " << yytext << " found\n";
            return BREAK; 
        }
"int"   {
                yylval.sp = tokenout("INT",string(yytext));
                logstream<<"Line# "<< lincnt() <<": Token <INT> Lexeme " << yytext << " found\n";
                return INT;
        }
"char"  {
                yylval.sp = tokenout("CHAR",string(yytext));
                logstream<<"Line# "<< lincnt() <<": Token <CHAR> Lexeme " << yytext << " found\n";
                return INT;
        }
"float" {
                yylval.sp = tokenout("FLOAT",string(yytext));
                logstream<<"Line# "<< lincnt() <<": Token <FLOAT> Lexeme " << yytext << " found\n";
                return FLOAT;
        }
"double" {
                yylval.sp = tokenout("DOUBLE",string(yytext));
                logstream<<"Line# "<< lincnt() <<": Token <DOUBLE> Lexeme " << yytext << " found\n";
                return DOUBLE;
        } 
"void"  {
            yylval.sp = tokenout("VOID",string(yytext)); logstream<<"Line# "<< lincnt() <<": Token <VOID> Lexeme " << yytext << " found\n";
            logstream<<"Line# "<< lincnt() <<": Token <SWITCH> Lexeme " << yytext << " found\n";
            return VOID;
        }


"switch"  {
            yylval.sp = tokenout("SWITCH",string(yytext)); logstream<<"Line# "<< lincnt() <<": Token <VOID> Lexeme " << yytext << " found\n";
            logstream<<"Line# "<< lincnt() <<": Token <SWITCH> Lexeme " << yytext << " found\n";
            return SWITCH;
        }
"case"  {
                yylval.sp = tokenout("CASE",string(yytext));
                logstream<<"Line# "<< lincnt() <<": Token <CASE> Lexeme " << yytext << " found\n";
                return CASE;
        }
"default"       {
                yylval.sp = tokenout("DEFAULT",string(yytext));
                logstream<<"Line# "<< yylineno <<": Token <DEFAULT> Lexeme " << yytext << " found\n";
                return DEFAULT;
        }
"continue"      {
                yylval.sp = tokenout("CONTINUE",string(yytext));
                logstream<<"Line# "<< yylineno <<": Token <CONTINUE> Lexeme " << yytext << " found\n";
                return CONTINUE;
        }
"println"      {
                yylval.sp = tokenout("PRINTLN",string(yytext));
                logstream<<"Line# "<< yylineno <<": Token <PRINTLN> Lexeme " << yytext << " found\n";
                return PRINTLN;
        }

"="     {
                yylval.sp = tokenout("ASSIGNOP",string(yytext));
                logstream<<"Line# "<< lincnt() <<": Token <ASSIGNOP> Lexeme " << yytext << " found\n";
                return ASSIGNOP;
        }
"!"     {
                yylval.sp = tokenout("NOT",string(yytext));
                logstream<<"Line# "<< lincnt() <<": Token <NOT> Lexeme " << yytext << " found\n";
                return NOT;
        }
"("     {
                yylval.sp = tokenout("LPAREN",string(yytext));
                logstream<<"Line# "<< lincnt() <<": Token <LPAREN> Lexeme " << yytext << " found\n";
                return LPAREN;
        }
")"     {
                yylval.sp = tokenout("RPAREN",string(yytext));
                logstream<<"Line# "<< lincnt() <<": Token <RPAREN> Lexeme " << yytext << " found\n";
                return RPAREN;
        }
"{"     {
                yylval.sp = tokenout("LCURL",string(yytext));
                logstream<<"Line# "<< lincnt() <<": Token <LCURL> Lexeme " << yytext << " found\n";
                return LCURL;
        }
"}"     {
                yylval.sp = tokenout("RCURL",string(yytext));
                logstream<<"Line# "<< lincnt() <<": Token <RCURL> Lexeme " << yytext << " found\n";
                return RCURL; 
        }
"["     {
                yylval.sp = tokenout("LSQUARE",string(yytext));
                logstream<<"Line# "<< lincnt() <<": Token <LSQUARE> Lexeme " << yytext << " found\n";
                return LSQUARE;
        }
"]"     {
                yylval.sp = tokenout("RSQUARE",string(yytext));
                logstream<<"Line# "<< lincnt() <<": Token <RSQUARE> Lexeme " << yytext << " found\n";
                return RSQUARE;
        }
","     {
                yylval.sp = tokenout("COMMA",string(yytext));
                logstream<<"Line# "<< lincnt() <<": Token <COMMA> Lexeme " << yytext << " found\n";
                return COMMA;
        }
";"     {
                yylval.sp = tokenout("SEMICOLON",string(yytext));
                logstream<<"Line# "<< lincnt() <<": Token <SEMICOLON> Lexeme " << yytext << " found\n";
                return SEMICOLON;
        }
{LOGICOP}	{
				yylval.sp = tokenout("LOGICOP",string(yytext));
                logstream<<"Line# "<< lincnt() <<": Token <LOGICOP> Lexeme " << yytext << " found\n";
                return LOGICOP;
        }
{ADDOP}		{
				yylval.sp = tokenout("ADDOP",string(yytext));
                logstream<<"Line# "<< lincnt() <<": Token <ADDOP> Lexeme " << yytext << " found\n";
                return ADDOP;
			}
{MULOP}		{
				yylval.sp = tokenout("MULOP",string(yytext));
                logstream<<"Line# "<< lincnt() <<": Token <MULOP> Lexeme "<<yytext<<" found\n";
                return MULOP;
			}
{INCOP}		{
				yylval.sp = tokenout("INCOP",string(yytext));
                logstream<<"Line# "<< lincnt() <<": Token <INCOP> Lexeme "<<yytext<<" found\n";
                return INCOP;
			}

{DECOP}		{
				yylval.sp = tokenout("DECOP",string(yytext));
                logstream<<"Line# "<< lincnt() <<": Token <DECOP> Lexeme "<<yytext<<" found\n";
                return DECOP;
			}
{RELOP}		{
				yylval.sp = tokenout("RELOP",string(yytext));
                logstream<<"Line# "<< lincnt() <<": Token <RELOP> Lexeme "<<yytext<<" found\n";
                return RELOP;
			}

{IDENTIFIER}	{ 
					string val = string(yytext);
					yylval.sp = tokenout("ID" , val);
					logstream<<"Line# "<< lincnt() <<": Token <ID> Lexeme "<< val <<" found\n";
                    return ID;
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
/*
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
    table.PrintAllScopeTable(logstream);
	logstream<<"Total lines: "<< yylineno <<"\n";
	logstream<<"Total errors: " << ercnt  <<"\n";
    fclose(yyin);
    yylex_destroy();
    return 0;
}
*/
