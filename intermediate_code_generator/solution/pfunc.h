using namespace std;
#include "1905100.h"
#include "mydata.h"
#include "RT.h"
#define pii pair <int, int>
#define getRT(sp) sp->getptr()->getrt()
extern int yylineno;
extern char* yytext;
extern SymbolTable* table;
extern ofstream logstream, icgstream;
extern ofstream errorstream;
extern int ercnt;
int soffset, label;
bool isneg = false;
string curlabel = "", retlabel = "";
SymbolInfo* lpar;
vector < SymbolInfo* > parvec;
ofstream opout;
void argcode(SymbolInfo* sp);
void comp (SymbolInfo* sp);
void expcode (SymbolInfo* sp);
void stcode (SymbolInfo* sp);
void simpexpcode(SymbolInfo* sp);
void declist(SymbolInfo* sp);
void logicexpcode(SymbolInfo* sp);
void yyerror(const string &s, int nm = -1) {

    ercnt++;
    //cout << nm << " here multiple " << endl;
    if (nm == -1) {
        errorstream << "Line# " << yylineno << ": ";
    }
    else {
        errorstream << "Line# " << nm << ": ";
    }
    errorstream << s << endl;
}

void yywarning(const string &s) {

}
inline bool isatype(SymbolInfo* sp) {
    if (sp == nullptr) return false;
    return (sp->getptr()->gettype() == "INT" ||
        sp->getptr()->gettype() == "FLOAT" ||
        sp->getptr()->gettype() == "VOID");
}
void lgrule(string r) {
    logstream << "Line " << yylineno << ": " << r << endl << endl;
}
string inttostr(int x) {
    string s = "";
    int got = 0;
    if (x < 0) {
        got = 1;
        x *= -1;
    }
    while (x) {
        s += (char)('0' + x % 10);
        x /= 10;
    }
    if (got) s += "-";
    reverse(s.begin(), s.end());
    return s;
}
int strtoint(string s) {
    int x = 0;
    for (int i = 0; i < s.length(); i++) {
        if (s[i] >= '0' && s[i] <= '9') {
            x = x * 10 + (int)(s[i] - '0');
        }
    }
    if (s[0] == '-') x *= -1;
    return x;
}
string createlabel() {
    label++;
    return "L" + inttostr(label);
}
vector < SymbolInfo* > getall(SymbolInfo* psp) {
    vector < SymbolInfo* > ret;
    if (((*(psp->adj)).size()) == 0) {
        ret.push_back(psp);
    }
    for (SymbolInfo* s : (*(psp->adj))) {
        vector < SymbolInfo* > nret = getall(s);
        for (SymbolInfo* ns : nret) ret.push_back(ns);
    }
    return ret;
}
void newlinecode() {
    icgstream << "new_line proc\n\tpush ax\n\tpush dx\n\tmov ah,2\n\tmov dl,cr\n\tint 21h\n\tmov ah,2\n\tmov dl,lf\n\tint 21h\n\tpop dx\n\tpop ax\n\tret\nnew_line endp"<<endl;
}

void outputcode () {
       icgstream << "print_output proc  ;print value in ax\n"
            "\tpush ax\n\tpush bx\n\tpush cx\n\tpush dx\n\tpush si\n\tlea si,number\n\tmov bx,10\n\tadd si,4\n\tcmp ax,0\n\tjnge negate\n\tprint:\n\txor dx,dx\n\tdiv bx\n\tmov [si],dl\n\tadd [si],'0'\n\tdec si\n\tcmp ax,0\n\tjne print\n\tinc si\n\tlea dx,si\n\tmov ah,9\n\tint 21h\n\tpop si\n\tpop dx\n\tpop cx\n\tpop bx\n\tpop ax\n\tret\n\tnegate:\n\tpush ax\n\tmov ah,2\n\tmov dl,'-'\n\tint 21h\n\tpop ax\n\tneg ax\n\tjmp print\nprint_output endp"<<endl;
    }
void arglistcode(SymbolInfo *sp) {
    //if ((sp->linecnt).first == 31) cout << sp->name << " yyyyyyyyyyyyyyyyyyyyyyyyyyyyy " << (*(sp->adj))[0]->name << endl;
    if(sp->name == "arguments"){
        argcode((*(sp->adj))[0]);
    }
}
void argcode(SymbolInfo* sp) {
    if ((sp->linecnt).first == 31) cout << sp->name << " xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx" << endl;
        if(sp->name == "arguments COMMA logic_expression"){
            logicexpcode((*(sp->adj))[2]);
            argcode((*(sp->adj))[0]);
        }

        else if(sp->name == "logic_expression"){
            logicexpcode((*(sp->adj))[0]);
        }
    }
void vardeccode(SymbolInfo* sp) {
    icgstream << "\t\t;variable_declaration"<<endl;
    declist((*(sp->adj))[1]);
}

void declist(SymbolInfo* sp) {
        if(sp->adj->size() == 1) {
            soffset+=2;
            ((*(sp->adj))[0])->soffset= soffset;
            table->insert((*(sp->adj))[0]);
            icgstream << "\tSUB SP, 2"<<endl;
        }

        else if(sp->adj->size() == 3) {
            soffset+=2;
            ((*(sp->adj))[2])->soffset = soffset;
            table->insert((*(sp->adj))[2]);
            icgstream << "\tSUB SP, 2"<<endl;
            declist((*(sp->adj))[0]);
        }

        else if(sp->adj->size() == 4) {
            soffset+=2*(((*(sp->adj))[0])->arraysize);
            ((*(sp->adj))[0])->soffset = (soffset);
            table->insert(((*(sp->adj))[0]));
            icgstream << "\tSUB SP, "<< 2*(((*(sp->adj))[0])->arraysize)<<endl;
        }

        else if(sp->adj->size() == 6) {
            soffset+=2*(((*(sp->adj))[2])->arraysize);
            ((*(sp->adj))[2])->soffset = (soffset);
            table->insert(((*(sp->adj))[2]));
            icgstream << "\tSUB SP, "<< 2 * (((*(sp->adj))[2])->arraysize) <<endl;
            declist((*(sp->adj))[0]);
        }
}
void expstcode(SymbolInfo* sp) {
    //if ((sp->linecnt).first == 10) 
        //cout << sp->name << " " << (sp->linecnt).first << " kkkkkkkkkkk " << sp->adj->size() << " adj size hre " << endl;
    if(sp->adj->size() == 2) {
        //icgstream << (*(sp->adj))[0]->name << " name again and type " << (*(sp->adj))[0]->gettype() << endl;
        expcode((*(sp->adj))[0]);
        icgstream << "\tPOP AX"<<endl;
    }
}
void expcode (SymbolInfo* sp) {
    if ((sp->linecnt).first == 5) {
        cout << sp->adj->size() << " adj size " << endl;
        //cout << sp->name << " " << sp->adj->size() << " expcode here this is " << endl;
        //for (SymbolInfo* cur : getall(sp)) {
            //cout << cur->name << " curname " << endl;
        //}
    }
    if(sp->adj->size() == 3) {
        logicexpcode((*(sp->adj))[2]);
        string v1 ="";
        if(((*(sp->adj))[0])->adj->size() == 1) {
            //cout << " nnnnooo this " << endl;
            string varname =(*(((*(sp->adj))[0])->adj))[0]->name;
            //cout << " varname " << varname << endl;
            SymbolInfo* s1 =table->LookUp(varname );
            cout << " this is varname " << varname << (sp->linecnt).first << " " << s1->name << " " << s1->name<< endl;
            //cout << " the this is offset " << s1->soffset << endl;
            if(s1->soffset == 0) {
                v1 =s1->name;
            }

            else if(s1->soffset > 0) {
                v1 ="[BP-"+inttostr(s1->soffset)+"]";
            }

            else if(s1->soffset < 0) {
                v1 ="[BP+"+inttostr((s1->soffset)*(-1))+"]";
            }
        }

        else{
            string varname =(*(((*(sp->adj))[0])->adj))[0]->name;
            SymbolInfo* s1 =table->LookUp(varname);
            expcode((*(((*(sp->adj))[0])->adj))[2]);
            icgstream << "\tPOP SI"<<endl;
            icgstream << "\tSHL SI, 1"<<endl;

            if(s1->soffset == 0) {
                v1 =s1->name + "[SI]";
            }

            else if(s1->soffset > 0) {
                icgstream << "\tNEG SI"<<endl;
                icgstream << "\tADD SI, "<<s1->soffset <<endl;
                icgstream << "\tNEG SI"<<endl;
                v1 ="BP[SI]";
            }

            else if(s1->soffset < 0) {
                icgstream << "\tSUB SI, "<<s1->soffset <<endl;
                v1 ="BP[SI]";
            }
        }
        //cout << " v1 here this is " << v1 << " " << ((*(sp->adj))[2])->name << endl;
        icgstream << "\tPOP AX"<<endl;
        icgstream << "\tMOV "<<v1<< ", AX"<<endl;
        icgstream << "\tPUSH AX"<<endl;
    }

    else {
        //if ((sp->linecnt).first == 4) //cout << " now this " << (*(sp->adj))[0]->name << endl;
        logicexpcode((*(sp->adj))[0]);
    }
}
void factorcode(SymbolInfo* sp) {
    //cout << " spppppppppppppppppppppppppppppp " << sp->name << endl;
        if((*(sp->adj))[0]->gettype() == "CONST_INT"){
            icgstream << "\tMOV AX, "<<(*(sp->adj))[0]->name<<endl;
            if(isneg){
                icgstream << "\tNEG AX"<<endl;
                isneg=false;
            }
            icgstream << "\tPUSH AX"<<endl;
        }

        else if((*(sp->adj))[0]->gettype() == "CONST_FLOAT"){
            icgstream << "\tMOV AX, "<<(*(sp->adj))[0]->name<<endl;
            if(isneg){
                icgstream << "\tNEG AX"<<endl;
                isneg=false;
            }
            icgstream << "\tPUSH AX"<<endl;
        }

        else if(sp->name == "variable"){
            string v1 ="";
            if(((*(sp->adj))[0])->adj->size() == 1){
                string varname=((*(((*(sp->adj))[0])->adj))[0])->name;
                SymbolInfo* s1 =table->LookUp(varname);

                if(s1->soffset == 0){
                    v1 =s1->name;
                }

                else if(s1->soffset > 0){
                    v1 ="[BP-"+inttostr(s1->soffset)+"]";
                }

                else if(s1->soffset < 0){
                    v1 ="[BP+"+inttostr((s1->soffset)*(-1))+"]";
                }
            }

            else{
                string varname=((*(((*(sp->adj))[0])->adj))[0])->name;
                SymbolInfo* s1 =table->LookUp(varname);
                expcode((*(((*(sp->adj))[0])->adj))[2]);
                icgstream << "\tPOP SI"<<endl;
                icgstream << "\tSHL SI, 1"<<endl;

                if(s1->soffset == 0){
                    v1 =s1->name+"[SI]";
                }

                else if(s1->soffset > 0){
                    icgstream << "\tNEG SI"<<endl;
                    icgstream << "\tADD SI, "<<s1->soffset <<endl;
                    icgstream << "\tNEG SI"<<endl;
                    v1 ="BP[SI]";
                }

                else if(s1->soffset < 0){
                    icgstream << "\tSUB SI, "<<s1->soffset <<endl;
                    v1 ="BP[SI]";
                }
            }

            icgstream << "\tMOV AX, "<<v1<<endl;
            if(isneg){
                icgstream << "\tNEG AX"<<endl;
                isneg=false;
            }
            icgstream << "\tPUSH AX"<<endl;
        }

        else if(sp->name == "variable INCOP"){
            string v1 ="";
            if(((*(sp->adj))[0])->adj->size() == 1){
                string varname=((*(((*(sp->adj))[0])->adj))[0])->name;
                SymbolInfo* s1 =table->LookUp(varname);

                if(s1->soffset == 0){
                    v1 =s1->name;
                }

                else if(s1->soffset > 0){
                    v1 ="[BP-"+inttostr(s1->soffset)+"]";
                }

                else if(s1->soffset < 0){
                    v1 ="[BP+"+inttostr((s1->soffset)*(-1))+"]";
                }
            }

            else{
                string varname = ((*(((*(sp->adj))[0])->adj))[0])->name;
                SymbolInfo* s1 =table->LookUp(varname);
                expcode((*(((*(sp->adj))[0])->adj))[2]);
                icgstream << "\tPOP SI"<<endl;
                icgstream << "\tSHL SI, 1"<<endl;

                if(s1->soffset == 0){
                    v1 =s1->name+"[SI]";
                }

                else if(s1->soffset > 0){
                    icgstream << "\tNEG SI"<<endl;
                    icgstream << "\tADD SI, "<<s1->soffset <<endl;
                    icgstream << "\tNEG SI"<<endl;
                    v1 ="BP[SI]";
                }

                else if(s1->soffset < 0){
                    icgstream << "\tSUB SI, "<<s1->soffset <<endl;
                    v1 ="BP[SI]";
                }
            }

            icgstream << "\tMOV AX, "<<v1<<endl;
            if(isneg){
                icgstream << "\tNEG AX"<<endl;
                isneg=false;
            }
            icgstream << "\tPUSH AX"<<endl;
            icgstream << "\tINC AX"<<endl;
            icgstream << "\tMOV "<<v1<<", AX"<<endl;
        }

        else if(sp->name == "variable DECOP"){
            string v1 ="";
            if(((*(sp->adj))[0])->adj->size() == 1){
                string varname=((*(((*(sp->adj))[0])->adj))[0])->name;
                SymbolInfo* s1 =table->LookUp(varname);

                if(s1->soffset == 0){
                    v1 =s1->name;
                }

                else if(s1->soffset > 0){
                    v1 ="[BP-"+inttostr(s1->soffset)+"]";
                }

                else if(s1->soffset < 0){
                    v1 ="[BP+"+inttostr((s1->soffset)*(-1))+"]";
                }
            }

            else{
                string varname = ((*(((*(sp->adj))[0])->adj))[0])->name;
                SymbolInfo* s1 =table->LookUp(varname);
                expcode((*(((*(sp->adj))[0])->adj))[2]);
                icgstream << "\tPOP SI"<<endl;
                icgstream << "\tSHL SI, 1"<<endl;

                if(s1->soffset == 0){
                    v1 =s1->name+"[SI]";
                }

                else if(s1->soffset > 0){
                    icgstream << "\tNEG SI"<<endl;
                    icgstream << "\tADD SI, "<<s1->soffset <<endl;
                    icgstream << "\tNEG SI"<<endl;
                    v1 ="BP[SI]";
                }

                else if(s1->soffset < 0){
                    icgstream << "\tSUB SI, "<<s1->soffset <<endl;
                    v1 ="BP[SI]";
                }
            }

            icgstream << "\tMOV AX, "<<v1<<endl;
            if(isneg){
                icgstream << "\tNEG AX"<<endl;
                isneg=false;
            }
            icgstream << "\tPUSH AX"<<endl;
            icgstream << "\tDEC AX"<<endl;
            icgstream << "\tMOV "<<v1<<", AX"<<endl;
        }

        else if(sp->name == "LPAREN expression RPAREN"){
            expcode((*(sp->adj))[1]);
        }

        else if(sp->name == "ID LPAREN argument_list RPAREN"){
            arglistcode((*(sp->adj))[2]);
            icgstream << "\tCALL "<<((*(sp->adj))[0])->name<<endl;
            icgstream << "\tPUSH AX"<<endl;
        }
    }
void unaryexpcode(SymbolInfo* sp) {
        if(sp->adj->size() == 1){
            factorcode((*(sp->adj))[0]);
        }

        else if(sp->name == "ADDOP unary_expression"){
            if(((*(sp->adj))[0])->name == "-"){
                isneg=true;
            }

            unaryexpcode((*(sp->adj))[1]);
        }

        else if(sp->name == "NOT unary_expression"){
            unaryexpcode((*(sp->adj))[1]);
            string l0= createlabel();
            string l1 = createlabel();
            string nxlabel= createlabel();
            icgstream << "\tPOP AX"<<endl;
            icgstream << "\tCMP AX, 0"<<endl;
            icgstream << "\tJE "<<l1<<endl;
            icgstream << "\tJMP "<<l0<<endl;
            icgstream << l1<<":"<<endl;
            icgstream << "\tMOV AX, 1"<<endl;
            icgstream << "\tPUSH AX"<<endl;
            icgstream << "\tJMP "<<nxlabel<<endl;
            icgstream << l0<<":"<<endl;
            icgstream << "\tMOV AX, 0"<<endl;
            icgstream << "\tPUSH AX"<<endl;
            icgstream << nxlabel<<":"<<endl;

        }
    }
void termcode (SymbolInfo* sp) {
    if ((sp->linecnt).first == 4) {
        //cout << sp->adj->size() << " size now " << (*(sp->adj))[0]->name << endl;
    }
    if(sp->adj->size() == 1){
        unaryexpcode((*(sp->adj))[0]);
    }

    else{
        termcode((*(sp->adj))[0]);
        unaryexpcode((*(sp->adj))[2]);
        icgstream << "\tPOP CX"<<endl;
        icgstream << "\tPOP AX"<<endl;
        icgstream << "\tCWD"<<endl;
        if(((*(sp->adj))[1])->name == "*"){
            icgstream << "\tIMUL CX"<<endl;
            icgstream << "\tPUSH AX"<<endl;
        }

        else if(((*(sp->adj))[1])->name == "/"){
            icgstream << "\tIDIV CX"<<endl;
            icgstream << "\tPUSH AX"<<endl;
        }

        else if(((*(sp->adj))[1])->name == "%"){
            icgstream << "\tIDIV CX"<<endl;
            icgstream << "\tPUSH DX"<<endl;
        }
    }
}
void simpexpcode(SymbolInfo* sp) {
    if ((sp->linecnt).first == 5) {
        cout << sp->name << " hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh in 10 " << sp->adj->size() <<  endl; 
    }
    if(sp->adj->size() == 1) {
        termcode((*(sp->adj))[0]);
    }
    

    else{
        simpexpcode((*(sp->adj))[0]);
        termcode((*(sp->adj))[2]);
        icgstream << "\tPOP DX"<<endl;
        icgstream << "\tPOP AX"<<endl;
        if(((*(sp->adj))[1])->name == "+") {
            icgstream << "\tADD AX, DX"<<endl;
        }

        else{
            icgstream << "\tSUB AX, DX"<<endl;
        }
        icgstream << "\tPUSH AX"<<endl;
    }
}
void relexpcode(SymbolInfo *sp) {
        if ((sp->linecnt).first == 5) cout << sp->name << " name in 5 " << sp->adj->size() << endl;
        if(sp->adj->size() == 1) {
            simpexpcode((*(sp->adj))[0]);
            cout << " after simpexp " << endl;
        }

        else{
            simpexpcode((*(sp->adj))[0]);
            simpexpcode((*(sp->adj))[2]);
            string l0= createlabel();
            string l1 = createlabel();
            string nxlabel= createlabel();
            //labelCreated=true;
            icgstream << "\tPOP DX"<<endl;
            icgstream << "\tPOP AX"<<endl;
            icgstream << "\tCMP AX, DX"<<endl;

            if(((*(sp->adj))[1])->name == "<") {
                icgstream << "\tJL "<<l1<<endl;
            }
            else if(((*(sp->adj))[1])->name == "<=") {
                icgstream << "\tJLE "<<l1<<endl;
            }
            else if(((*(sp->adj))[1])->name == ">") {
                icgstream << "\tJG "<<l1<<endl;
            }
            else if(((*(sp->adj))[1])->name == ">=") {
                icgstream << "\tJGE "<<l1<<endl;
            }
            else if(((*(sp->adj))[1])->name == "==") {
                icgstream << "\tJE "<<l1<<endl;
            }
            else if(((*(sp->adj))[1])->name == "!=") {
                icgstream << "\tJNE "<<l1<<endl;
            }
            icgstream << "\tJMP "<<l0<<endl;
            icgstream << l1<< ":"<<endl;
            icgstream << "\tMOV AX, 1"<<endl;
            icgstream << "\tPUSH AX"<<endl;
            icgstream << "\tJMP "<<nxlabel<<endl;
            icgstream << l0<< ":"<<endl;
            icgstream << "\tMOV AX, 0"<<endl;
            icgstream << "\tPUSH AX"<<endl;
            icgstream << nxlabel<< ":"<<endl;
        }
    }
void logicexpcode(SymbolInfo* sp) {
    if ((sp->linecnt).first == 5) {
        cout << " problem now " << sp->name << " " << sp->adj->size() << endl;
    }
    if(sp->adj->size() == 1) {
        relexpcode((*(sp->adj))[0]);
    }

    else{
        relexpcode((*(sp->adj))[0]);
        
        if ((sp->linecnt).first == 5) {
            cout << " after now " << sp->name << " " << sp->adj->size() << endl;
        }
        string l0= createlabel();
        string l1 = createlabel();
        string nxlabel= createlabel();
        icgstream << "\tPOP AX"<<endl;
        icgstream << "\tCMP AX, 0"<<endl;
        if(((*(sp->adj))[1])->name == "||") {
            icgstream << "\tJNE "<<l1<<endl;
            relexpcode((*(sp->adj))[2]);
            icgstream << "\tPOP AX"<<endl;
            icgstream << "\tCMP AX, 0"<<endl;
            icgstream << "\tJE "<<l0<<endl;
            icgstream << l1<< ":"<<endl;
            icgstream << "\tMOV AX, 1"<<endl;
            icgstream << "\tPUSH AX"<<endl;
            icgstream << "\tJMP "<<nxlabel<<endl;
            icgstream << l0<< ":"<<endl;
            icgstream << "\tMOV AX, 0"<<endl;
            icgstream << "\tPUSH AX"<<endl;
            icgstream << nxlabel<< ":"<<endl;
        }
        else if (((*(sp->adj))[1])->name == "&&") {
            icgstream << "\tJE "<<l0<<endl;
            relexpcode((*(sp->adj))[2]);
            icgstream << "\tPOP AX"<<endl;
            icgstream << "\tCMP AX, 0"<<endl;
            icgstream << "\tJNE "<<l1<<endl;
            icgstream << l0<< ":"<<endl;
            icgstream << "\tMOV AX, 0"<<endl;
            icgstream << "\tPUSH AX"<<endl;
            icgstream << "\tJMP "<<nxlabel<<endl;
            icgstream << l1<< ":"<<endl;
            icgstream << "\tMOV AX, 1"<<endl;
            icgstream << "\tPUSH AX"<<endl;
            icgstream << nxlabel<< ":"<<endl;
        }
    }
}
void ifelsebr(SymbolInfo* sp, string nxlabel) {
    if(sp->name == "IF LPAREN expression RPAREN statement ELSE statement") {
        expcode((*(sp->adj))[2]);
        string l0= createlabel();
        string l1 = createlabel();
        icgstream << "\tPOP AX"<<endl;
        icgstream << "\tCMP AX, 0"<<endl;
        icgstream << "\tJNE "<<l1<<endl;
        icgstream << "\tJMP "<<l0<<endl;
        icgstream << l1<< ":"<<endl;
        stcode((*(sp->adj))[4]);
        icgstream << "\tJMP "<<nxlabel<<endl;
        icgstream << l0<< ":"<<endl;
        ifelsebr((*(sp->adj))[6], nxlabel);
    }

    else if(sp->name == "IF LPAREN expression RPAREN statement") {
        expcode((*(sp->adj))[2]);
        icgstream << "\tPOP AX"<<endl;
        icgstream << "\tCMP AX, 0"<<endl;
        icgstream << "\tJE "<<nxlabel<<endl;
        stcode((*(sp->adj))[4]);
    }

    else{
        stcode(sp);
    }
}
void stcode (SymbolInfo* sp) {
        if(sp->name == "var_declaration") {
            icgstream << "\t\t;Line no " << (sp->linecnt).first << endl;
            vardeccode((*(sp->adj))[0]);
        }
        else if(sp->name == "expression_statement") {
            icgstream << "\t\t;Line no " << (sp->linecnt).first << endl;
            //cout << (*(sp->adj))[0]->name << " curname "<< endl;
            expstcode((*(sp->adj))[0]);
        }
        else if(sp->name == "PRINTLN LPAREN ID RPAREN SEMICOLON") {
            icgstream << "\t\t;Line no "<<(sp->linecnt).first << endl;
            string vname = ((*(sp->adj))[2])->name;
            SymbolInfo* s1 = table->LookUp(vname);
            string v1 = "";

            if(s1->soffset == 0) {
                v1 = s1->name;
            }
            else if(s1->soffset > 0) {
                v1 = "[BP-" + inttostr(s1->soffset) + "]";
            }
            else if(s1->soffset < 0) {
                v1 = "[BP+" + inttostr(-1 * (s1->soffset)) + "]";
            }

            icgstream << "\t\t;calling println function" << endl;
            icgstream << "\tMOV AX, " << v1 << endl;
            icgstream << "\tCALL print_output" << endl;
	        icgstream << "\tCALL new_line" << endl;
        }
        else if (sp->name == "compound_statement") {
            comp((*(sp->adj))[0]);
        }
        else if(sp->name == "RETURN expression SEMICOLON") {
            icgstream << "\t\t;Line no " << (sp->linecnt).first << endl;
            expcode((*(sp->adj))[1]);
            icgstream << "\tPOP AX" << endl;
            icgstream << "\tJMP " << retlabel << endl;
        }
        else if(sp->name == "IF LPAREN expression RPAREN statement") {
            icgstream << "\t\t;Line no " << sp->linecnt.first << endl;
            icgstream << "\t\t;if else statement" << endl;
            expcode((*(sp->adj))[2]);
            string nxlabel = createlabel();
            icgstream << "\tPOP AX" << endl;
            icgstream << "\tCMP AX, 0" << endl;
            icgstream << "\tJE " << nxlabel << endl;
            stcode((*(sp->adj))[4]);
            icgstream << nxlabel << ":" << endl;
        }
        else if(sp->name == "IF LPAREN expression RPAREN statement ELSE statement") {
            icgstream << "\t\t;Line no " << sp->linecnt.first << endl;
            icgstream << "\t\t;if else statement" << endl;
            expcode((*(sp->adj))[2]);
            string l1 = createlabel();
            string l0 = createlabel();
            string nxlabel = createlabel();
            icgstream << "\tPOP AX" << endl;
            icgstream << "\tCMP AX, 0" << endl;
            icgstream << "\tJNE "<<l1<<endl;
            icgstream << "\tJMP "<<l0<<endl;
            icgstream << l1 << ":"<<endl;
            stcode((*(sp->adj))[4]);
            icgstream<< "\tJMP "<<nxlabel<<endl;
            icgstream <<l0<< ":"<<endl;
            ifelsebr((*(sp->adj))[6], nxlabel);
            icgstream <<nxlabel<< ":"<<endl;
        }
        else if(sp->name == "FOR LPAREN expression_statement expression_statement expression RPAREN statement") {
            cout << sp->name << " here sp name " << (sp->linecnt).first << endl;
            icgstream << "\t\t;Line no "<< (sp->linecnt).first <<endl;
            //icgstream << "\t\t;for initialization"<<endl;

            cout <<  (*(sp->adj))[2]->name << " " << endl;
            for (SymbolInfo* cur : getall((*(sp->adj))[2])) cout << cur->name << endl;
            expstcode((*(sp->adj))[2]);
            string beginlabel = createlabel();
            string endlabel = createlabel();
            icgstream <<beginlabel<< ":"<<"\t\t;for loop start"<<endl;
            expstcode((*(sp->adj))[3]);
            icgstream << "\tCMP AX, 0"<<endl;
            icgstream << "\tJE "<< endlabel<<endl;
            stcode((*(sp->adj))[6]);
            expcode((*(sp->adj))[4]);
            icgstream << "\tPOP AX"<<endl;
            icgstream << "\tJMP "<< beginlabel<<endl;
            icgstream << endlabel<< ":"<<endl;
            cout << " till here " << (sp->linecnt).second  << endl;
        }

        else if(sp->name == "WHILE LPAREN expression RPAREN statement") {
            icgstream << "\t\t;Line no "<<(sp->linecnt).first <<endl;
            string beginlabel = createlabel();
            string endlabel = createlabel();
            icgstream << beginlabel << ":"<<"\t\t;while loop start"<<endl;
            expcode((*(sp->adj))[2]);
            icgstream << "\tPOP AX"<<endl;
            icgstream << "\tCMP AX, 0"<<endl;
            icgstream << "\tJE "<<endlabel<<endl;
            stcode((*(sp->adj))[4]);
            icgstream << "\tJMP "<<beginlabel<<endl;
            icgstream <<endlabel<< ":"<<endl;
        }
    }
void statementscode(SymbolInfo* sp) {
    //cout << sp->adj->size() <<  " get line cnt " << (sp->linecnt).first << endl;
    if(sp->adj->size() == 1) {
        stcode((*(sp->adj))[0]);
    }
    else if(sp->adj->size() == 2) {
        statementscode((*(sp->adj))[0]);
        stcode((*(sp->adj))[1]);
    }
}

void comp (SymbolInfo* sp) {
    if(sp->adj->size() == 3) {
        table->EnterScope(30);
        if(parvec.size() != 0) {
            for(int i = 0; i < parvec.size(); i++) {
                table->insert(parvec[i]);
            }
            parvec.clear();
        }
        statementscode((*(sp->adj))[1]);
        table->ExitScope();
    }

    else{
        table->EnterScope(30);
        table->ExitScope();
    }
}
void fundefcode(SymbolInfo* sp) {

    soffset = -2;
    string fname = ((*(sp->adj))[1])->name;
    icgstream << "\t\t;function_definition" << endl;
    icgstream << fname << " PROC" <<endl;
    if (fname == "main") {
        icgstream << "\tMOV AX, @DATA" << endl;
        icgstream << "\tMOV DS, AX" << endl;
    }
    int psize = 0;
    if (sp->adj->size() == 6) {
        lpar = ((*(sp->adj))[3]);
        vector < SymbolInfo* > all = getall(lpar);
        for (SymbolInfo* cur : all) {
            if ((cur->value).type == "ID") {
                parvec.push_back(cur);
                psize++;
                soffset -= 2;
                cur->soffset = soffset;
            }
        }
    }
    //for (SymbolInfo* cur : parvec) {
        //cout << cur->name << " hello " << cur->gettype() << endl;
    //}
    soffset = 0;
    icgstream << "\t\t;base pointer pushing" << endl;
    icgstream << "\tPUSH BP" << endl;
    icgstream << "\tMOV BP, SP" << endl;
    retlabel = createlabel();
    if (sp->adj->size() == 6) {
        comp((*(sp->adj))[5]);
    }
    else comp((*(sp->adj))[4]);
    icgstream << retlabel << ":" << "\t\t; return from function" << endl;
    icgstream <<"\tMOV SP, BP"<<endl;
    icgstream << "\tPOP BP" << endl;
    if(fname == "main") {
        icgstream << "\tMOV AX, 4CH" << endl;
        icgstream << "\tINT 21H" << endl;
    }
    else {
        if (psize > 0) {
            icgstream << "\tRET " << (2 * psize) << endl;
        }
        else {
            icgstream << "\tRET" << endl;
        }
        psize = 0;
    }
    icgstream << fname << " ENDP" << endl;
    soffset = 0;
}


void print(SymbolInfo* sip , vector<SymbolInfo*>& globals, ostream & out = icgstream) {
        out << ".MODEL SMALL\n.STACK 1000H\n.Data\n\tCR EQU 0DH\n\tLF EQU 0AH\n\tnumber DB \"00000$\"" << endl;
        vector<SymbolInfo*> units;
        SymbolInfo* prg = (*(sip->adj))[0];
        while(prg->adj->size() == 2) {
            units.push_back((*(prg->adj))[1]);
            prg = (*(prg->adj))[0];
        }
        units.push_back((*(prg->adj))[0]);
        out << "\t\t;declaring global variables"<<endl;
        for(SymbolInfo* cur: globals) {
            //cout << cur->name << " Here name " << cur->getptr()->isara() << endl;
            if(cur->getptr()->isara()) {
                out << "\t"<<cur->name<<" DW "<<cur->arraysize<<" DUP (0000H)"<<endl;
                //cout << "array size here " << cur->arraysize << endl;
            }

            else{
                out << "\t"<<cur->name<<" DW 1 DUP (0000H)"<<endl;
            }
        }
        out << ".CODE"<<endl;
        for(SymbolInfo* cur: units) {
            if(cur->name == "func_definition") {
                //funcdef(getall($1)[0] , getall($2)[0] , $4);
                fundefcode((*(cur->adj))[0]);
            }
        }

        newlinecode();
        outputcode();
        out << "END main"<<endl;
        ifstream inpcode;
        vector< string > all;
        string iline;
        inpcode.open("icg.asm");
        opout.open("icg_optimized.asm");
        while(getline(inpcode, iline)) {
            all.push_back(iline);
        }

        for(int i = 0;i < all.size(); i++) {
            if(i >= all.size() - 1) {
                
            }
            else if(all[i].substr(1,3) == "ADD" || all[i].substr(1,3) == "SUB") {
                string l1 = all[i].substr(4);
                int cid1 = l1.find(",");
                if(l1.substr(cid1 + 2) == "0"){
                    opout << "\t\t;removed addition with 0" << endl;
                    continue;
                }
            }
            else if(all[i].substr(1,3) == "MUL") {
                
                string l1 = all[i].substr(4);
                int cid1 = l1.find(",");
                if(l1.substr(cid1 + 2) == "1"){
                    opout <<"\t\t;removed multiplication with 1"<<endl;
                    continue;
                }
            }

            else if(all[i].substr(1,4) == "PUSH" && all[i+1].substr(1,3) == "POP") {
                if(all[i].substr(6) == all[i+1].substr(5)) {
                    opout << "\t\t;removed PUSH and POP of the same register in consecutive lines"<<endl;
                    i++;
                    continue;
                }
            }

            else if(all[i].substr(1,3) == "MOV" && all[i+1].substr(1,3) == "MOV") {
                string l1 = all[i].substr(4);
                string l2= all[i+1].substr(4);

                int cid1 =l1.find(",");
                int cid2=l2.find(",");

                if(l1.substr(1,cid1-1) == l2.substr(cid2+2) && l1.substr(cid1+2) == l2.substr(1,cid2-1)) {
                    opout <<all[i]<<endl;
                    opout << "\t\t;removed reduntant MOV instruction"<<endl;
                    i++;
                    continue;
                }
            }

            opout <<all[i]<<endl;
        }

        inpcode.close();
        opout.close();
    }

void addfp(SymbolInfo* p) {
    lpar = p;
}
bool typematch (RT lt, RT rt, string name = "", int ispar = 0, int id = 0) {
    if (lt == rt) return true;
    else if (lt == Float && rt == Int) {
        return true;
    }
    else if (lt == Int && rt == Float) {
        if (ispar) {
            yyerror("Type mismatch for argument " + inttostr(id) + " of '" + name + "'");
        }
        else yyerror("Warning: possible loss of data in assignment of FLOAT to INT");
        return true;
    }
    else return false;
}
bool canparse(FP lp, FP rp, string name = "", int ispar = 1) {
    //cout << yylineno << " cccccccccc can parse " << lp.size() << " " << rp.size() << endl;
    if (lp.size() != rp.size()) return false;
    for (int i = 0; i < lp.size(); i++) {
        //cout << rttostr(lp[i]) << " rrrrrrrrrrtttttttt " << rttostr(rp[i]) << endl;
        if (!typematch(lp[i], rp[i],name, ispar, i + 1)) return false;
    }
    return true;
}
FP getfpfromlist(SymbolInfo* pps) {
    //////cout << " now taking list " << endl;
    FP fp;
    int gotvoid = 0;
    //if (pps == NULL) ////cout << " Null got " << endl;
    if (pps != NULL) {
        vector <SymbolInfo*> lst = getall(pps);
        for (SymbolInfo* ps : lst) {
            //////cout << " in the loop " << endl;
            if (isatype(ps)) {
                if (ps->getptr()->gettype() == "VOID") {
                    gotvoid = 1;
                }
                fp.push_back(strtort(ps->getptr()->gettype()));
            }
        }
    }
    if (fp.size() > 1 && gotvoid == 1) {
        yyerror("'void' must be the only parameter", (pps->linecnt).first);
    }
    else if (gotvoid) fp.clear();
    return fp;
}
void vardec (SymbolInfo* psp, int ispar = 0) {
    if (psp == NULL) return;
    vector < SymbolInfo* > lst = getall(psp);
    int sz = lst.size();
    //////cout << " here size = " << sz << endl;
    if (sz == 0) return;
    RT ts = Error;
    int usedts = 0;
    //////cout << " here psp = " << psp->name << endl;
    for (int i = 0; i < sz; i++) {
        SymbolInfo* sp = lst[i];
       //if (yylineno == 8) ////cout << i << " " << (sp->value).type << "sp name haere in line " << (sp->linecnt).first << " " << (sp->linecnt).second << " " << sp->name << " " << yylineno << endl;
        if (isatype(sp)) {
            //if (yylineno == 8) ////cout << " this is a type " << endl;
            if (ts != Error && usedts == 0 && ts != Void) {
           //if (yylineno == 8) ////cout << " here problem " << rttostr(ts) << endl;
                yyerror("Variable name not found after type specifier" + rttostr(ts) + " in function_declaration", (sp->linecnt).first);
            }
            ts = strtort((sp->value).type);
            usedts = 0;
        }
        if ((sp->value).type == "ID") {
            if (ts == Error || ts == Void) {
                yyerror("Variable or field '" + sp->name + "' declared " + rttostr(ts), (sp->linecnt).first);
            }
            else {
                SymbolInfo* nsp = new SymbolInfo(sp);
                nsp->getptr()->setrt(ts);
                sp->getptr()->setrt(ts);
                usedts = 1;
                SymbolInfo* spnx = NULL;
                if (i + 1 < sz) spnx = lst[i + 1];
                if (spnx && spnx->getptr()->gettype() == "LSQUARE") {
                    //cout << " Here is thisss " << endl;
                    nsp->getptr()->setara();
                    sp->getptr()->setara();
                }
                int ins = table->insert(nsp);
                if (!ins) {
                    SymbolInfo* pp = table->LookUp(nsp->name);
                    if (ispar) {

                        if (getRT(pp) != getRT(nsp)) {
                           yyerror("Type mismatch for argument " + inttostr(i + 1)  + " of '" + sp->name + "'", (sp->linecnt).first);
                        }
                        else {
                           //cout << sp->name << " " << (sp->linecnt).first << " " << (sp->linecnt).second << endl;
                           yyerror("Redefinition of parameter '" + sp->name + "'", (sp->linecnt).first);
                        }
                  }
                  else {
                    if (getRT(pp) != getRT(nsp)) {
                       yyerror("Conflicting types for'" + sp->name + "'", (sp->linecnt).first);
                    }
                    else yyerror("Redefinition of variable '" + sp->name + "'", (sp->linecnt).first);
                  }
                }
            }
        }
    }
    if (ts != Error && usedts == 0 && ts != Void) {
        yyerror("Variable name not found after " + rttostr(ts) + " in function_declaration", (psp->linecnt).second);
    }
}
void fundec(SymbolInfo* rt, SymbolInfo* fname, SymbolInfo* fp) {
    ////cout << "fundec starts " << yylineno << endl;
    FP fptypelist = getfpfromlist(fp);
    ////cout << yylineno << " got the list " << (fname->name)<< endl;
    SymbolInfo* rf = table->LookUp(fname->name);
    if (rf == NULL) {
        ////cout << " this rf is nulll " << endl;
        rf = new SymbolInfo(fname);
        rf->getptr()->setfp(fptypelist);
        rf->getptr()->setrt(strtort((rt->value).type));
        ////cout << rt->name << " " << (rt->value).type << " getting type " << endl;
        rf->getptr()->setfnc();
        table->insert(rf);
    }
    else {
       // ////cout << "here this  is " << rttostr(rf->getptr()->getrt()) << endl;
        if (rf->getptr()->isfunction() == false) {
            yyerror("'" + fname->name + "' redeclared as different kind of ", (fname->linecnt).second);
        }
        else if ((rf->getptr()->getfp() != fptypelist) || (rf->getptr()->getrt()!= strtort((rt->value).type))) {
            yyerror("Conflicting types for '" + fname->name + "'", (fname->linecnt).second);
        }
    }
    //////cout << "Fundec ends" << endl;
}
void funcdef(SymbolInfo* rt, SymbolInfo* fName, SymbolInfo* fp) {
    fundec(rt, fName, fp);
    addfp(fp);
}
RT getvartype(string vname) {
    //////cout << vname << " here is a problem " << endl;
    SymbolInfo* sp = table->LookUp(vname);
    if (sp == NULL) {
        yyerror("Undeclared variable '" + vname + "'");
        return Error;
    }
    else if (sp->getptr()->isfunction()) {
        yyerror("Parameters not used in Function : " + vname);
        return Error;
    }
    else {
        return getRT(sp);
    }
}
RT getaratype(string vname) {
    SymbolInfo* sp = table->LookUp(vname);
    if (sp == NULL) {
        yyerror("Undeclared variable '" + vname + "'");
        return Error;
    }
    else if (sp->getptr()->isara()) {
        return getRT(sp);
    }
    else {
        yyerror("'" + vname + "' is not an array");
        return getRT(sp);
    }
}
RT getrettype(string fname, SymbolInfo* arglist) {
    //cout << " getting rettype " << yylineno << " " << fname << endl;
    FP fp = arglist ? (arglist)->getptr()->getfp() : FP();
    SymbolInfo* rf = table->LookUp(fname);
    RT type = Error;
    //if (rf != NULL) //cout << (rf->getptr()->getfp()).size() << " size " << fp.size() << " " << yylineno << endl;
    if (rf == NULL) {
        yyerror("Undeclared function '" + fname + "'");
    }
    else if ((rf->getptr()->getfp()).size() < fp.size()) {
        yyerror("Too many arguments to function '" + fname + "'");
    }
    else if ((rf->getptr()->getfp()).size() > fp.size()) {
        yyerror("Too few arguments to function '" + fname + "'");
    }
    else if (canparse(rf->getptr()->getfp(), fp, fname) == false) {
        yyerror("Invalid arguments for function call: " + fname);
    }
    if (rf != NULL) {
        type = getRT(rf);
    }
    return type;
}
RT arithtype(RT t1, RT t2) {
    //////cout << " before error " << endl;
    if (t1 == Error || t2 == Error) return Error;
    else if (t1 == Void || t2 == Void) {
        yyerror("Void cannot be used in expression ");
        return Error;
    }
    else if (t1 == Float or t2 == Float) {
        return Float;
    }
    else return Int;
}
void entersc() {
    table->EnterScope(30);
    vardec(lpar, 1);
    lpar = NULL;
}
void exitsc(ostream &os = logstream) {
    table->PrintAllScopeTable(os);
    table->ExitScope();
}
int zeroval(string &s) {
    for (char c : s) {
        if (c != '0')
            if (c != '.') return 0;
    }
    return 1;
}
