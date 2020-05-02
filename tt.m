//
//	experimenting nice inc / ntic calc ...
//

#include <stdio.h>
#include <stdlib.h>
#include <math.h>


int topDigit(double in);
int orderOfMag(double finc);

int
main(int ac, char *av[])
{
	double	inVal;
	int		outVal;
    int     i;
    float   col;

	if (ac < 2) {
		printf("tt <in>\n");
//		exit(0);
	}
//	inVal = atof(av[1]);

// test colors
    for (i = 0; i < 20; i++) {
        col = 0.215 * i;
        col -= (int)col;
        printf("col = %f\n", col);
    }
    exit(0);

//	out = topDigit(in);
	outVal = orderOfMag(inVal);
	printf("mag = %d\n", outVal);
	inVal = inVal * pow(10.0, -outVal);
	printf("mag2 = %f\n", inVal);
}

int topDigit(double in)
{
	double	a;
	int		ia;
	int		out;

	a = log10(in);
	ia = floor(a);
	a -= ia;
	out = pow(10, a);

	return out;
}

int orderOfMag(double in) {
	int		out;
	double	a;

	a = log10(in);
	out = floor(a);

	return out;
}
