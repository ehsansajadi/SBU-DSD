#include <stdio.h>
#include <stdlib.h>

void code(unsigned int* v, unsigned int* k) 
{
	unsigned int y=v[0] ,z=v[1], sum=0, /* set up */
	//delta = 0x79b9,
	delta = 0x9e3779b9, /* a key schedule constant */
	n=32 ;
	while (n-- > 0) 
	{ /* basic cycle start */
		sum += delta ;
		y += ((z<<4)+k[0]) ^ (z+sum) ^ ((z>>5)+k[1]) ;
		z += ((y<<4)+k[2]) ^ (y+sum) ^ ((y>>5)+k[3]) ;
	} /* end cycle */
	v[0]=y ; v[1]=z ; 
}

int main()
{
	unsigned int* v = (unsigned int*) malloc(sizeof(int) * 2);
	unsigned int* k = (unsigned int*) malloc(sizeof(int) * 4);
	v[0] = 0x12345678;
	v[1] = 0x11111111;
	k[0] = 0x87654321;
	k[1] = 0x66666666;
	k[2] = 0x44444444;
	k[3] = 0x22222222;
	code(v, k);
	printf("%x\n%x", v[0], v[1]);
	// v[0]: 9e68c92d
	// v[1]: 7bc0f2c5
	return 0;
}