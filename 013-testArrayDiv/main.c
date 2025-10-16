#include <stdint.h>

int array[512];
void setup() {
  for (int x = 0; x < 512; x++) {
    array[x] = 2 * x;
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
int program(int divisor) {
  int acc = 0;
  for (int x = 511; x >= 0; x--) {
    acc += array[x] / divisor;
  }
  return acc;
}
int main() {
  int acc;
  setup();
  acc = program(2);
  if (acc == 130816) {
    haltAndCatchFireButItPassed();
  }
  haltAndCatchFire(acc);
}