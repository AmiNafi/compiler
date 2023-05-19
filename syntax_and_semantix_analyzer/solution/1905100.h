#ifndef ADDED_SYMBOLINFO
#define ADDED_SYMBOLINFO

#include <bits/stdc++.h>
using namespace std;
#include "mydata.h"
#define pii pair <int, int>
static unsigned long long SDBMHash(string str) {
    unsigned long long hash = 0;
    unsigned int i = 0;
    unsigned int len = str.length();
    for (i = 0; i < len; i++) {
        hash = (str[i]) + (hash << 6) + (hash << 16) - hash;
    }
    return hash;
}
class SymbolInfo {
public:
    mydata value;
    string name = "";//  = "";
    SymbolInfo *next = NULL, *prev = NULL;
    int val;
    pii linecnt;
    vector < SymbolInfo* >* adj;
    mydata* getptr() {
        return &value;
    }
    string gettype() {
        return value.type;
    }
    SymbolInfo() {
        linecnt = pii(0, 0);
        adj = new vector <SymbolInfo*>();
    }
    SymbolInfo(string nm, string tp, pii p = pii(0, 0)) {
        linecnt = p;
        adj = new vector <SymbolInfo*>();
        name = nm;
        value.type = tp;
    }

    SymbolInfo(SymbolInfo *ref){
        //cout << " in constructor  here " << ref->value<< endl;
        name = ref->name;
        value = ref->value;
        //cout << " there it is " << endl;
        //cout << "next prev" << endl;
        linecnt = pii(0, 0);
        //cout << "before adj" << endl;
        adj = new vector <SymbolInfo*>();
        //cout << " out constructor " << endl;
    }
    void pb(SymbolInfo* nsi) {
        adj->push_back(nsi);
    }

    
};
class ScopeTable {
    public:
    SymbolInfo* hTable;
    int tableSize = 0, id = 0;
    ScopeTable *next;
    ScopeTable(int n, int nid){
        id = nid;
        tableSize = n;
        //cout << "\tScopeTable# "<< id << " created" << endl;
        hTable = new SymbolInfo[tableSize];
        next = NULL;
    }
    SymbolInfo* LookUp(string s) {
        int cur = SDBMHash(s) % tableSize;
        int cnt = 0;
        for(SymbolInfo* tmp = (hTable + cur)->next; tmp != NULL; tmp = tmp->next) {
            cnt++;
            if(tmp->name == s) {
                //cout << "\t'" << s << "' found in ScopeTable# "<< id <<" at position "<< cur + 1 << ", " << cnt << endl;
                return tmp;
            }
        }
        return NULL;
    }
    bool insert(string s, mydata val) {
        int cur = SDBMHash(s) % tableSize;
        cout << " insert " << cur << endl;
        SymbolInfo* nd = new SymbolInfo;
        nd->value = val;
        nd->name = s;
        nd->next = NULL;
        SymbolInfo *tmp = (hTable + cur);
        int cnt = 0;
        while (tmp->next != NULL) {
            if (tmp->name == s) {
                 //cout << "\t'" << s << "' already exists in the current ScopeTable" << endl;
                return false;
            }
            tmp = tmp->next;
            cnt++;
        }
        if (tmp->name == s) {
             //cout << "\t'" << s << "' already exists in the current ScopeTable" << endl;
            return false;
        }
        tmp->next = nd;
        //cout << "\tInserted in ScopeTable# " << id << " at position " << cur + 1 << ", " << cnt + 1 << endl;
        return true;
    }
    bool insert(SymbolInfo* nd) {
        string s = nd->name;
        int cur = SDBMHash(s) % tableSize;
        SymbolInfo *tmp = (hTable + cur);
        int cnt = 0;
        while (tmp->next != NULL) {
            if (tmp->name == s) {
                 //cout << "\t'" << s << "' already exists in the current ScopeTable" << endl;
                return false;
            }
            tmp = tmp->next;
            cnt++;
        }
        if (tmp->name == s) {
             //cout << "\t'" << s << "' already exists in the current ScopeTable" << endl;
            return false;
        }
        tmp->next = nd;
        //cout << "\tInserted in ScopeTable# " << id << " at position " << cur + 1 << ", " << cnt + 1 << endl;
        return true;
    }

    bool Delete (string s) {
        int cur = SDBMHash(s) % tableSize;
        SymbolInfo* tmp = (hTable + cur)->next;
        SymbolInfo *pre = (hTable + cur);
        int cnt = 0;
        while(tmp != NULL){
            cnt++;
            if(tmp->name==s){
                pre->next = tmp->next;
                int curval = tmp->val;
                //cout << "\tDeleted '" << s << "' from ScopeTable# " << id << " at position "<< cur + 1 << ", " << cnt << endl;
                delete tmp;
                return true;
            }
            pre = tmp;
            tmp = tmp->next;
        }
        //cout << "\tNot found in the current ScopeTable" << endl;
        return false;
    }
    void clear () {
        //cout << "\tScopeTable# " << id << " removed" << endl;
        SymbolInfo *curpos,*tmp;
        for (int i = 0; i < tableSize; i++) {
            curpos = (hTable + i)->next;
            while (curpos != NULL) {
                tmp = curpos;
                curpos = curpos->next;
                delete tmp;
            }
        }
        delete[] hTable;
        tableSize = 0;
    }
    void print(ostream &os) {
        SymbolInfo* tmp;
        os << "\tScopeTable# " << id << endl;
        for(int i = 0; i < tableSize; i++) {
            tmp = (hTable + i);
            tmp = tmp->next;
			if (tmp == NULL) continue;
            os << '\t' << i + 1 << "--> ";
            while (tmp != NULL) {
                os << "<" << tmp->name << "," << tmp->value << "> ";
                tmp = tmp->next;
            }
            os << endl;
        }
    }
    void print() {
        SymbolInfo* tmp;
        cout << "\tScopeTable# " << id << endl;
        for(int i = 0; i < tableSize; i++) {
            tmp = (hTable + i);
            tmp = tmp->next;
            if (tmp == NULL) continue;
            cout<< '\t' << i + 1 << "--> ";
            while (tmp != NULL) {
                cout << "<" << tmp->name << "," << tmp->value << "> ";
                tmp = tmp->next;
            }
            cout << endl;
        }
    }
    ~ScopeTable() {
        clear();
    }
};
class SymbolTable {
public:
    int currentid = 0;
    ScopeTable* current;
    SymbolTable (int tableSize) {
        currentid++;
        current = new ScopeTable(tableSize, currentid);

    }
    void EnterScope (int tableSize) {
        currentid++;
        ScopeTable *tmp = new ScopeTable(tableSize, currentid);
        tmp->next = current;
        current = tmp;
    }
    void ExitScope () {
        if (current->next == NULL) {
            //cout << "\tScopeTable# 1 cannot be removed" << endl;
        }
        else {
            ScopeTable* tmp = current;
            current = tmp->next;
            delete tmp;
        }
    }
    bool insert (string name, mydata val) {
        return current->insert(name, val);
    }
     bool insert (SymbolInfo* sp) {
        return current->insert(sp);
    }
    bool remove (string name) {
        return current->Delete(name);
    }
    SymbolInfo* LookUp (string name) {
        ScopeTable* tmp = current;
        while (tmp != NULL) {
            SymbolInfo* sym = tmp->LookUp(name);
            if (sym != NULL) {
                return sym;
            }
            tmp = tmp->next;
        }
        //cout << "\t'" << name << "' not found in any of the ScopeTables" << endl;
        return NULL;
    }
    void PrintCurrentScopeTable() {
        current->print();
    }
    void PrintAllScopeTable(ostream &os) {
        ScopeTable* tmp = current;
        while (tmp != NULL) {
            tmp->print(os);
            tmp = tmp->next;
        }
    }
    void clear () {
        ScopeTable *pt1, *pt2;
        pt1 = current;
        while(pt1 != NULL) {
            pt2 = pt1;
            pt1 = pt1->next;
            delete pt2;
        }
    }
    ~SymbolTable () {
        clear();
    }
};
/*
int main () {
    // freopen("in.txt", "r", stdin);
    // freopen("out.txt", "w", stdout);
    int n;
    cin >> n;
    SymbolTable table(n);
    mydata val;
    val.settype("Hellotypw");
    table.insert("myname", val);
    table.PrintAllScopeTable(cout);
    char c;
    int cmd = 0;
    return 0;
}
*/
#endif
