%option noyywrap
%option yylineno
%{
    #include<bits/stdc++.h>
    using namespace std;
%}

keyword "False"|"await"|"else"|"None"|"break"|"except"|"in"|"raise"|"True"|"class"|"finally"|"is"|"return"|"and"|"continue"|"for"|"lambda"|"try"|"as"|"def"|"from"|"nonlocal"|"while"|"assert"|"del"|"global"|"not"|"with"|"async"|"elif"|"if"|"or"|"yield"
operator "+"|"-"|"*"|"**"|"/"|"//"|"%"|"@"|"<<"|">>"|"&"|"|"|"^"|"~"|"<"|">"|"<="|">="|"=="|"!="
delimiter "("|")"|"["|"]"|"{"|"}"|","|":"|"."|";"|"@"|"="|"->"|"+="|"-="|"*="|"/="|"//="|"%="|"@="|"&="|"|="|"^="|">>="|"<<="|"**="
literal \"[^\"]*\"|'[^']*'
comments #.*\n
identifier [a-zA-Z_][a-zA-Z0-9_]*
number [0-9]+
dunder "__name__"|"__main__"|"__init__"


%%
{keyword} {cout<<"keyword ";}
{operator} {cout<<"operator ";}
{delimiter} {cout<<"delimiter ";}
{comments} {cout<<"comments "<<endl;}
{literal} {cout<<"literal ";}
{identifier} {cout<<"identifier ";}
{number} {cout<<"number ";}
{dunder} {cout<<"dunder ";}
\n {cout<<'\n';}
. {cout<<"token error at line " <<yylineno<<endl;}
%%


