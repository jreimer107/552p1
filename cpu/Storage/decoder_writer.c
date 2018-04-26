#include <stdio.h>
#include <stdbool.h>
#include <string.h>
#include <math.h>

#define NUM_INPUTS 7

int main(int argc, char *argv[]) {
	bool bools[NUM_INPUTS];
	for (int i = 0; i < NUM_INPUTS; i++) bools[i] = false;
	char nots[NUM_INPUTS][2];


	char A;
	int limit = pow(2, NUM_INPUTS);
	for (int i = 0; i < limit; i++) {
		//Update bools
		int modder = limit / 2;
		for (int j = 0; j < NUM_INPUTS; j++) {
			if (i % modder == 0) {
				bools[j] = !bools[j];
			}
			modder /= 2;
		}

		//Update nots strings
		for (int j = 0; j < NUM_INPUTS; j++) {
			if (bools[j]) strcpy(nots[j], "~");
			else strcpy(nots[j], " ");
		}


		//print assign part and first nots/char combination
		A = 'A';
		printf("assign out[%03d] = %s%c", i, nots[0], A++);

		//Print out rest of nots/char combos
		for (int j = 1; j < NUM_INPUTS; j++) {
			printf(" & %s%c", nots[j], A++);
		}
		printf(";\n");


	}
}