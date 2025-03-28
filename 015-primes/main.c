
#include <stdint.h>

#define SZ 16
int32_t primes[SZ], sieve[SZ];
int nSieve = 0;
// will not return
void haltAndCatchFire(int x) {
  *(volatile unsigned int *)(0x80000000) = x;
  *(volatile unsigned int *)(0x80000010) = 0;
  while (1)
    ;
}
void haltAndCatchFireButItPassed() {
  *(volatile unsigned int *)(0x80000000) = 50;
  *(volatile unsigned int *)(0x80000010) = 0;
  while (1)
    ;
}
int32_t countPrimes() {
  primes[0] = 2;
  sieve[0] = 4;
  ++nSieve;
  int32_t nPrimes = 1, trial = 3, sqr = 2;
  while (1) {
    while (sqr * sqr <= trial)
      ++sqr;
    --sqr;
    for (int i = 0; i < nSieve; ++i) {
      if (primes[i] > sqr)
        goto found_prime;
      while (sieve[i] < trial)
        sieve[i] += primes[i];
      if (sieve[i] == trial)
        goto try_next;
    }
    break;
  found_prime:
    if (nSieve < SZ) {
      primes[nSieve] = trial;
      sieve[nSieve] = trial * trial;
      ++nSieve;
    }
    ++nPrimes;
  try_next:
    trial += 1;
  }
  return nPrimes;
}
int main() {
  if (countPrimes() == 409)
    haltAndCatchFireButItPassed();
  haltAndCatchFire(1);
}