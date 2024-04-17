#include <stdio.h>

int main() {
	char out[] = "cs335 course\n";
	printf ("%s wordd\n", out);

	long h;
	printf ("%d\n", 971);
	printf ("%d\n\n\n\n\n\n\n", 971);
	printf ("%d %d\n\n\n\n\n\n\n", 971, 1020);
	long i = h & 8;
	if (h|i)
		h = 55;
	else if (h = ~i)
		h = 66;
	else {
		h = 77;
		h = h || i;
	}
	if (h ^ i)
		h = 5;
	if (h << i)
		h = 6;
	if  (h >> i)
		h=7;
	if (!h)
		h=8;

	i <<=60;
	h = h|i;
	h = h && i;

	return 44;
}
