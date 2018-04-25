#include <stdio.h>
#include <stdint.h>

int main(int argc, char *argv[]) {
	bool A, B, C, D, E, F, G;
	A = false;
	bool[7] bools;
	for (int i = 0; i < 7; i++) bools[i] = false;
	char nots[7][2];
	for (int i = 0; i < 7; i++) {
		strcpy(nots[i], "");
	}

	char A;

	for (int i = 0; i < 128; i++) {
		//print assign part and first nots/char combination
		A = 'A';
		printf("assign out[%d] = %s%c", i, nots[0], A++);

		//Print out rest of nots/char combos
		for (int j = 1; j < 7; j++) {
			printf(" & %s%c", nots[j], A++;)
		}
		printf(";\n");

		//Update bools
		int modder = 1;
		for (int j = 0; j < 7; j++) {
			if (i % modder == 0) {
				bools[j] = !bools[j];
			}
			modder *= 2;
		}

		//Update nots strings
		for (int j = 0; j < 7; j++) {
			if (bools[j]) strcpy(nots[j], "~");
			else strcpy(nots[j], "");
		}
	}
}