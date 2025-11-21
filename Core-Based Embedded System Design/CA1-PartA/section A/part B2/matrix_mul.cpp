// #include <iostream>

int mul(int a, int b)
{
    int s = 0;
    for(int i = 0; i < b; i++)
    {
        s += a;
    }
    return s;
}

int main() {
    int* A = (int*) 0x100000;
    int* B = (int*) 0x100020;
    int* C = (int*) 0x100040;

    A[0] = 1; A[1] = 2;
    A[2] = 3; A[3] = 4;

    B[0] = 5; B[1] = 6;
    B[2] = 7; B[3] = 8;

    for (int i = 0; i < 2; i++) {
        for (int j = 0; j < 2; j++) {
            C[(i << 1) + j] = 0; 
            for (int k = 0; k < 2; k++) {
                C[(i << 1) + j] += mul(A[(i << 1) + k], B[(k << 1) + j]);
            }
        }
    }
    return 0;
}