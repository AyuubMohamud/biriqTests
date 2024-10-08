#include <stdint.h>

unsigned int factorial(unsigned int x) {
    if (x==0) {
        return 1;
    } else {
        return x*factorial(x-1);
    }

}
// will not return
void haltAndCatchFire() {
    *(volatile unsigned int *)(0x80000000) = 0;
    volatile unsigned int wontAssign = *(volatile unsigned int *)(0x80000010);
}

// will not return
void haltAndCatchFireButItPassed() {
    *(volatile unsigned int *)(0x80000000) = 50;
    volatile unsigned int wontAssign = *(volatile unsigned int *)(0x80000010);
}


int main() {
    unsigned int y = factorial(9);
    if (y!=362880) {
        haltAndCatchFire();
    }
    y = factorial(12);
    if (y!=479001600) {
        haltAndCatchFire();
    }
    y = factorial(7);
    if (y!=5040) {
        haltAndCatchFire();
    }
    y = factorial(1);
    if (y!=1) {
        haltAndCatchFire();
    }
    haltAndCatchFireButItPassed();
}