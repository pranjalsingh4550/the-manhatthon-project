#include<bits/stdc++.h>
using namespace std;
#include<unistd.h>
#include<fcntl.h>

int main(){
    int fd=open("input.txt",O_RDONLY);
    close(0);
    dup(fd);
    string s;
    cout<<"\"";
    
}