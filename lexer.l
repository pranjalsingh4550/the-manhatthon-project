%option noyywrap
%{
    #include<bits/stdc++.h>
    using namespace std;
%}

keyword "False"|"await"|"else"|"import"|"pass"|"None"|"break"|"except"|"in"|"raise"|"True"|"class"|"finally"|"is"|"return"|"and"|"continue"|"for"|"lambda"|"try"|"as"|"def"|"from"|"nonlocal"|"while"|"assert"|"del"|"global"|"not"|"with"|"async"|"elif"|"if"|"or"|"yield"
operator "+"|"-"|"*"|"**"|"/"|"//"|"%"|"@"|"<<"|">>"|"&"|"|"|"^"|"~"|":="|"<"|">"|"<="|">="|"=="|"!="
delimiter "("|")"|"["|"]"|"{"|"}"|","|":"|"."|";"|"@"|"="|"->"|"+="|"-="|"*="|"/="|"//="|"%="|"@="|"&="|"|="|"^="|">>="|"<<="|"**="
comments #.*\n
identifier [a-zA-Z_][a-zA-Z0-9_]*
number [0-9]+

%%
{keyword} {cout<<"keyword ";}
{operator} {cout<<"operator ";}
{delimiter} {cout<<"delimiter ";}
{comments} {cout<<"comments "<<endl;}
{identifier} {cout<<"identifier ";}
{number} {cout<<"number ";}

%%


