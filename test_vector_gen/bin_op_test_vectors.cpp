#include <iostream>
#include <fstream>
#include <math.h>
#include <stdlib.h>
#include <string>
#include <time.h>

//This is a c++ program designed to generate an input file called
//"input.txt" for use with VHDL test benches. This currently assumes
//two inputs of equal length

std::string print_bits(int num, int bits);

int main(int argc, char** argv)	{

	int bits = 8;
	int cases = 0;

	bool workspace = false;
	bool random = false;
	for(int i = 1; i < argc; i++)	{
		if(argv[i][0] == '-')	{
			switch(argv[i][1])	{
				//The bit switch selects the argument size
				case 'h':
					std::cout << "This program generates an input file of test vectors for binary operation VHDL test benches.\n";
					std::cout << "The following flags are supported:\n";
					std::cout << "-b=SIZE\tSpecify argument size in bits. This defaults to 8\n";
					std::cout << "-r=NUM\tSpecifies random test case selection. Replace NUM with how many random selections should be made for each input\n";
					std::cout << "-w\tAppend an ancillae space and compute the result in it\n";
					exit(0);
					break;
				case 'b':
					bits = std::atoi(argv[i] + 3);
					std::cout << "Using " << bits << "-bit inputs\n";
					break;

				//The workspace switch selects if the quantum algorithm
				//record its operation to a scratch space instead of in
				//place. This appends extra ancillae to the input
				//and assumes the output is on the ancillae and the
				//inputs are unchanged
				case 'w':
					workspace = true;
					std::cout << "Adding workspace\n";
					break;
				//Confirms that the test cases should be randomly selected
				case 'r':
					random = true;
					cases = std::atoi(argv[i] + 3);
					std::cout << "Selecting " << cases*cases << " test cases randomly\n";
					break;
				default:
					break;
			}
		}
	}

	if(cases == 0) cases = pow(2, bits);

	int a, b, s;

	std::ofstream f;
	f.open("input.txt", std::ios::out | std::ios::trunc);

	srand(time(NULL));
	for(int i = 0; i < cases; i++)	{
		for(int j = 0; j < cases; j++)	{
			if(i != 0 || j!= 0)	{
				f << std::endl;
			}

			//Generate random cases if necessary- might have duplicates
			a = (random) ? rand() % cases : i;
			b = (random) ? rand() % cases : i;

			//Variable s is the result of an operation acting on a and b.
			//To test a different binary operation, rewrite the definition
			//of s
			s = a+b;
			if(workspace)	{
				f << print_bits(0, bits);
			}
			f << print_bits(a, bits) << print_bits(b, bits) << ',';
			f << print_bits(a, bits);
			if(workspace)	{
				f << print_bits(b, bits);
			}
			f << print_bits(s, bits);
		}
	}

	f.close();
}

std::string print_bits(int num, int bitCount)	{
	std::string s = "";
	for(int i = 0; i < bitCount; i++)	{
		s.insert(0, ((num >> i) & 1) ? "1" : "0");
	}
	return s;
}