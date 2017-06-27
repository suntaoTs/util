#include <stdio.h>

#define A 5
int foo()
{
    int *p = 0;
    *p = 10;
    int a = A;
    int c = 4;
    return 0;
}
int main()
{
    
    int a = 3;
    a = 5;
    foo();
    int c = a+5;
    printf("%d\n", c);
}
