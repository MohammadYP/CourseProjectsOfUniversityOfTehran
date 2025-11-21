#include <stdio.h>
int main() {
    int n=10, i;
    unsigned long long fact = 1;


    // shows error if the user enters a negative integer

        for (i = 1; i <= n; ++i) {
            fact *= i;
        }


    return 0;
}
