// from musl libc
int isdigit(int c) { return (unsigned)c - '0' < 10; }
int islower(int c) { return (unsigned)c - 'a' < 26; }
int isxdigit(int c) { return isdigit(c) || ((unsigned)c | 32) - 'a' < 6; }
int isspace(int c) { return c == ' ' || (unsigned)c - '\t' < 5; }
int toupper(int c) {
  if (islower(c))
    return c & 0x5f;
  return c;
}
int isupper(int c) { return (unsigned)c - 'A' < 26; }
int tolower(int c) {
  if (isupper(c))
    return c | 32;
  return c;
}
