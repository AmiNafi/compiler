using namespace std;
#include "1905100.h"
#include "mydata.h"
#include "RT.h"
#define pii pair <int, int>
#define getRT(sp) sp->getptr()->getrt()
extern int yylineno;
extern char* yytext;
extern SymbolTable* table;
extern ofstream logstream,parsestream;
extern ofstream errorstream;
extern int ercnt;

SymbolInfo* lpar;
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
    while (x) {
        s += (char)('0' + x % 10);
        x /= 10;
    }
    reverse(s.begin(), s.end());
    return s;
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

void print(SymbolInfo* sip ,int d = 0,  ostream & out = parsestream)
{
    for (int i = 0; i < d; i++) out << " ";
    if ((*(sip->adj)).size() == 0) {
         out << (sip->value).type << " : " << sip->name  << "\t<Line: "<<(sip->linecnt).first<<">"<< endl;   
    }
    else out << sip->name << " \t<Line: "<<(sip->linecnt).first <<"-"<<(sip->linecnt).second<<">" << endl;
    for (SymbolInfo* s : *(sip->adj)) {
        print(s, d + 1);
    }
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
                yyerror("Variable name not found after type specifier" + rttostr(ts) + " in function declaration", (sp->linecnt).first);
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
                usedts = 1;
                SymbolInfo* spnx = NULL;
                if (i + 1 < sz) spnx = lst[i + 1];
                if (spnx && spnx->getptr()->gettype() == "LSQUARE")
                    nsp->getptr()->setara();
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
        yyerror("Variable name not found after " + rttostr(ts) + " in function declaration", (psp->linecnt).second);
    }
}
void fundec(SymbolInfo* rt, SymbolInfo* fname, SymbolInfo* fp) {
    ////cout << "fundec starts " << yylineno << endl;
    FP fptypelist = getfpfromlist(fp);
    ////cout << yylineno <<" got the list " << (fname->name)<< endl;
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
            yyerror("'" + fname->name + "' redeclared as different kind of symbol", (fname->linecnt).second);
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
    cout << " getting rettype " << yylineno << " " << fname << endl;
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
