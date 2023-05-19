#include<bits/stdc++.h>
using namespace std;
#include "RT.h"
RT strtort(string s) {
    //cout << " strtort start " << s << endl;
    for (int i = 0; i < (int)(s.length()); i++) {
        if (s[i] >= 'A' && s[i] <= 'Z') s[i] += 'a' - 'A';
    }
        if(s ==  "error")
            return Error;
        else if (s ==  "int")
            return Int;
        else if (s == "float")
            return Float;
        else if (s ==  "void")
            return Void;
        else
            return Error;
}
string rttostr(RT r) {
    if (r == Int) return "int";
    else if (r == Float) return "float";
    else if (r == Error) return "error";
    else if (r == Void) return "void";
    else return "undefined!";
}
