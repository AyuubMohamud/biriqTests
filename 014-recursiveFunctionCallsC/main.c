#include <stdint.h>

unsigned int factorial(unsigned int x) {
    if (x==0) {
        return 1;
    } else {
        return x*factorial(x-1);
    }

}
// will not return
void haltAndCatchFire(unsigned int x) {
    *(volatile unsigned int *)(0x80000000) = x;
    *(volatile unsigned int *)(0x80000010) = 0;
    while(1);
}

// will not return
void haltAndCatchFireButItPassed() {
    *(volatile unsigned int *)(0x80000000) = 50;
    *(volatile unsigned int *)(0x80000010) = 0;
    while(1);
}


int main() {
    unsigned int y = factorial(9);
    if (y!=362880) {
        haltAndCatchFire(1);
    }
    y = factorial(12);
    if (y!=479001600) {
        haltAndCatchFire(2);
    }
    y = factorial(7);
    if (y!=5040) {
        haltAndCatchFire(3);
    }
    y = factorial(1);
    if (y!=1) {
        haltAndCatchFire(4);
    }
    haltAndCatchFireButItPassed();
}