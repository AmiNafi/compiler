#ifndef MYDATA
#define MYDATA
#include <bits/stdc++.h>
using namespace std;
#include "RT.h"
typedef vector < RT > FP;
class mydata {
    public:
        RT rt;
        bool fnc = false, ara = false;
        string type;
        FP fp;
        mydata() {
            fnc = false;
            ara = false;
        }
        mydata(string s) {
            type = s;
            rt = Error;
        }
        void settype(string s) {
            type = s;
        }
        void setrt(RT r) {
            this->rt = r;
        }
        RT getrt() {
            return rt;
        }
        string gettype() {
            return type;
        }
        void setfp(FP f) {
            this->fp = f;
        }
        FP getfp() {
            return fp;
        }
        FP *getfploc() {
            return &fp;
        }
        bool isfunction() {
            return fnc;
        }
        void setfnc() {
            fnc = true;
        }
        bool isara() {
            return ara;
        }
        void setara() {
            ara = true;
        }
        ~mydata() {
        }
        friend ostream &operator<< (ostream &os, const mydata &d) {
            os << d.type;
            return os;
        }
};
#endif

