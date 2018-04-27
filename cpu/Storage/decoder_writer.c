#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <string.h>
#include <math.h>      
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>

struct decoder_t {
	int num_inputs;
	int limit;
	bool *bools;
	char *nots;
};

//Usage: name size1 size2 ... sizen (-f filename)
int main(int argc, char *argv[]) {
	if (argc < 2) {
		printf("Usage: int num_inputs, string file_name.\n");
		exit(1);
	}
	char *filename = NULL;
	int num_decoders = argc - 1;

	//Option for specifying file to output to
	if (!strcmp(argv[argc - 2], "-f")) {
		filename = argv[argc -1];	//filename last
		num_decoders = argc - 3; //name, -f, and filename
		if (!strstr(filename, ".v") && !strstr(filename, ".sv")) {
			printf("Error: Not a verilog or sverilog file.\n");
			exit(1);
		}
	}

	//Create/open file
	char default_filename[20] =  "Decoder_autogen";
	char filedotv[100];
	if (!filename) sprintf(filedotv, "%s.v", default_filename);
	else sprintf(filedotv, "%s", filename);

	FILE *fd = fopen(filedotv, "a");
	if (!fd) {
		printf("Could not open/create file.\n");
		exit(-1);
	}

	//Set up decoder info
	struct decoder_t *decoders = malloc(sizeof(struct decoder_t) * num_decoders);
	for (int i = 0; i < num_decoders; i++) {
		decoders[i].num_inputs = atoi(argv[1]);
		decoders[i].limit = pow(2, decoders[i].num_inputs);
		decoders[i].bools = malloc(sizeof(bool) * decoders[i].num_inputs);
		for (int j = 0; j < decoders[i].num_inputs; j++) decoders[i].bools[j] = false;
		decoders[i].nots = malloc(decoders[i].num_inputs * 2);
	}

	//For each decoder to write
	for (int i = 0; i < num_decoders; i++) {
		//Print title line and input output lines
		fprintf(fd, "module Decoder_%d_%d(in, out);\n", 
			decoders[i].num_inputs, decoders[i].limit);
		fprintf(fd, "\tinput [%d:0] in;\n\toutput [%d:0] out;\n", 
			decoders[i].num_inputs, decoders[i].limit);

		//Print wire declarations
		char A = 'A';
		fprintf(fd, "\n\twire ");
		for (int j = 0; j < decoders[i].num_inputs; j++) {
			fprintf(fd, "%c", A++);
			if (i == decoders[i].num_inputs - 1) {	//Last, print semicolon
				fprintf(fd, ";\n\n");
			}
			else fprintf(fd, ", ");	//Not last, print comma
		}

		//Write each output line
		for (int i = 0; i < decoders[i].limit; i++) {
			//Update bools
			int modder = decoders[i].limit / 2;
			for (int j = 0; j < decoders[i].num_inputs; j++) {
				if (i % modder == 0) {
					decoders[i].bools[j] = !decoders[i].bools[j];
				}
				modder /= 2;
			}				

			//Update nots strings
			for (int j = 0; j < decoders[i].num_inputs; j++) {
				if (decoders[i].bools[j]) strcpy(decoders[i].nots[j], "~");
				else strcpy(decoders[i].nots[j], " ");
			}

			//print assign part and first nots/char combination
			A = 'A';
			fprintf(fd, "\tassign out[%03d] = %s%c", i, decoders[i].nots[0], A++);

			//Print out rest of nots/char combos
			for (int j = 1; j < decoders[i].num_inputs; j++) {
				fprintf(fd, " & %s%c", decoders[i].nots[j], A++);
			}
			fprintf(fd, ";\n");
		}
		fprintf(fd, "endmodule\n\n");
	}

	//Free data sructure
	for (int i = 0; i < num_decoders; i++) {
		free(decoders[i].bools);
		free(decoders[i].nots);
	}
	free(decoders);

	fclose(fd);
	return 0;
}