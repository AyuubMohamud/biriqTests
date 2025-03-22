#include <stdint.h>

int array[4096];
void setup() {
  for (int x = 0; x < 4096; x++) {
    array[x] = x;
  }
}
// will not return
void haltAndCatchFire(unsigned int x) {
  *(volatile unsigned int *)(0x80000000) = x;
  *(volatile unsigned int *)(0x80000010) = 0;
  while (1)
    ;
}

// will not return
void haltAndCatchFireButItPassed() {
  *(volatile unsigned int *)(0x80000000) = 50;
  *(volatile unsigned int *)(0x80000010) = 0;
  while (1)
    ;
}

int main() {
  setup();
  int acc = 0;
  for (int x = 4095; x >= 0; x--) {
    acc += array[x];
  }
  if (acc == 8386560) {
    haltAndCatchFireButItPassed();
  }
  haltAndCatchFire(acc);
}