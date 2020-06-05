#include <iostream>
#include <fstream>
#include <string>
#include <math.h>

int main(int argc, char** argv)	{

	bool verbose = false;
	int stage = -1;
	if(argc > 1)	{
		for(int i = 1; i < argc; i++)	{
			if(argv[i][0] == '-')	{
				switch(argv[i][1])	{
					case 'v':
						verbose = true;
						break;
					case 'i':
						stage = std::atoi(argv[i] + 3);
						break;
					default:
						break;
				}
			}
		}
	}

	std::ifstream in("output.txt");
	std::ofstream out("results.txt", std::ofstream::out);
	char line[100];
	unsigned angle;
	double a, b;
	char* x;
	char* y;
	double a_check, b_check;
	int bits;
	angle = 0;
	int size = 0;
	while(in.getline(line, 100)) {size++;}
	in.clear();
	in.seekg(0);

	double data[size][5];

	int index = 0;
	double rad;
	while(in.getline(line, 100))	{
		angle = std::strtol(line, &x, 2);
		bits = x - line;
		x++;

		//Take the 2s complement of x if necessary
		if(x[0] == '1')	{
			x[0] = '0';
			for(int i = 1; x[i] != ','; i++)	{
				if(x[i] == '0')	{
					x[i] = '1';
				}
				else if(x[i] == '1')	{
					x[i] = '0';
				}
			}
			a = -1 * (std::strtol(x, &y, 2) + 1);
		}
		else	{
			a = std::strtol(x, &y, 2);
		}
		y++;

		//Take the 2s complement of y if necessary
		if(y[0] == '1')	{
			y[0] = '0';
			for(int i = 1; y[i] != '\0'; i++)	{
				if(y[i] == '0')	{
					y[i] = '1';
				}
				else if(y[i] == '1')	{
					y[i] = '0';
				}
			}
			b = -1 * (std::strtol(y, NULL, 2) + 1);
		}
		else	{
			b = std::strtol(y, NULL, 2);
		}

		a /= pow(2, bits);
		b /= pow(2, bits);
		rad = angle * M_PI / pow(2, bits-1);

		a_check = floor(cosl(rad) * pow(2, bits)) / pow(2, bits);
		b_check = floor(sinl(rad) * pow(2, bits)) / pow(2, bits);
		data[index][0] = rad;
		data[index][1] = a;
		data[index][2] = a_check;
		data[index][3] = b;
		data[index][4] = b_check;
		if(verbose)	{
			out << "----------------------------" << std::endl;
			out << rad << std::endl;
			out << a << "\tfor\t" << a_check << std::endl;
			out << b << "\tfor\t" << b_check << std::endl;
		}
		index++;
	}

	double errorBound = floor((1.0/sqrt(1 + pow(2, 2*stage))) * pow(2, bits)) / pow(2, bits);

	//Data analysis for cos
	double maxAbs[6] = {0, 0, 0, 0, 0, 0};
	double var = 0;
	double errorAbs = 0;
	double exp, val;
	double temp;
	int cosWarnings = 0;
	for(int i = 0; i < size; i++)	{
		val = data[i][1];
		exp = data[i][2];
		var += pow(exp - val, 2);
		temp = abs(exp - val);
		errorAbs += temp;
		if(stage != -1 && temp > errorBound)	{
			if(verbose)	{
				out << "----------------------------" << std::endl;
				out << "Error bound exceeded for angle " << data[i][0] << std::endl;
				out << temp << " > " << errorBound << std::endl;
				out << "----------------------------" << std::endl;
			}
			cosWarnings++;
		}
		if(abs(exp - val) > maxAbs[0])	{
			maxAbs[0] = abs(exp - val);
			for(int j = 0; j < 5; j++)	{
				maxAbs[j+1] = data[i][j];
			}
		}
	}
	var /= size;
	errorAbs /= size;

	out << "----------------------------" << std::endl;
	out << "cos: Standard deviation of " << sqrt(var) << std::endl;
	out << "cos: Mean absolute error of " << errorAbs << std::endl;
	out << "cos: Max absolute error of " << maxAbs[0] << " at angle " << maxAbs[1] << std::endl;
	out << maxAbs[2] << "\tfor\t" << maxAbs[3] << std::endl;
	out << maxAbs[4] << "\tfor\t" << maxAbs[5] << std::endl;
	out << "Cos error warnings: " << cosWarnings << std::endl;

	//Data analysis for sin
	val = 0;
	errorAbs = 0;
	temp = 0;
	for(int i = 0; i < 6; i++) {maxAbs[i] = 0;}

	int sinWarnings = 0;
	for(int i = 0; i < size; i++)	{
		val = data[i][3];
		exp = data[i][4];
		var += pow(exp - val, 2);
		temp = abs(exp - val);
		errorAbs += temp;
		if(stage != -1 && temp > errorBound)	{
			if(verbose)	{
				out << "----------------------------" << std::endl;
				out << "Error bound exceeded for angle " << data[i][0] << std::endl;
				out << temp << " > " << errorBound << std::endl;
				out << "----------------------------" << std::endl;
			}
			sinWarnings++;
		}
		if(abs(exp - val) > maxAbs[0])	{
			maxAbs[0] = abs(exp - val);
			for(int j = 0; j < 5; j++)	{
				maxAbs[j+1] = data[i][j];
			}
		}
	}
	var /= size;
	errorAbs /= size;

	out << "----------------------------" << std::endl;
	out << "sin: Standard deviation of " << sqrt(var) << std::endl;
	out << "sin: Mean absolute error of " << errorAbs << std::endl;
	out << "sin: Max absolute error of " << maxAbs[0] << " at angle " << maxAbs[1] << std::endl;
	out << maxAbs[2] << "\tfor\t" << maxAbs[3] << std::endl;
	out << maxAbs[4] << "\tfor\t" << maxAbs[5] << std::endl;
	out << "Sin error warnings: " << sinWarnings << std::endl;
}