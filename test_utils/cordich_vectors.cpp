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

	char mode = 'a';

	bool workspace = false;
	bool random = false;
	bool ctrl = false;
	for(int i = 1; i < argc; i++)	{
		if(argv[i][0] == '-')	{
			switch(argv[i][1])	{
				//The bit switch selects the argument size
				case 'h':
					std::cout << "This program generates an input file of test vectors for the CORDIC algorithm.\n";
					std::cout << "The following flags are supported:\n";
					std::cout << "-b=SIZE\tSpecify argument size in bits. This defaults to 8\n";
					std::cout << "-r=NUM\tSpecifies random test case selection. Replace NUM with how many random selections should be made for each input\n";
					exit(0);
					break;
				case 'b':
					bits = std::atoi(argv[i] + 3);
					std::cout << "Using " << bits << "-bit inputs\n";
					break;

				//Confirms that the test cases should be randomly selected
				case 'r':
					random = true;
					cases = std::atoi(argv[i] + 3);
					break;

				default:
					break;
			}
		}
	}

	//Can only choose values that are decimals (angles are fixed-point)
	if(cases == 0) cases = pow(2, bits-1);

	if(random)	{
		std::cout << "Selecting " << cases << " test cases randomly\n";
	}

	int a, b, s;

	std::ofstream f;
	f.open("input.txt", std::ios::out | std::ios::trunc);

	srand(time(NULL));
	for(int i = 0; i < cases; i++)	{
		if(i != 0)	{
			f << std::endl;
		}

		std::cout << "\r";
		std::cout << "Generating test " << i + 1 << " out of " << cases;

		//Generate random cases if necessary- might have duplicates
		a = (random) ? rand() % (int) pow(2, bits-1) : i;

		//Print inputs
		f << print_bits(a, bits-1);
	}
	std::cout << std::endl;

	f.close();
}

std::string print_bits(int num, int bitCount)	{
	std::string s = "";
	for(int i = 0; i < bitCount; i++)	{
		s.insert(0, ((num >> i) & 1) ? "1" : "0");
	}
	//This is the leading decimal bit
	s.insert(0, ((num >> bitCount) & 1) ? "1" : "0");
	return s;
}