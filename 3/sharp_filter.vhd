PACKAGE twoD_array IS
    TYPE array_2d IS ARRAY(NATURAL RANGE <>,NATURAL RANGE <>) OF INTEGER;
END PACKAGE;

LIBRARY ieee;
USE work.twoD_array.ALL;

ENTITY sharp_filter IS
		GENERIC(n : INTEGER := 32;
				m : INTEGER := 64);
		PORT(
		input    : IN  array_2d(0 TO n-1,0 TO m-1);
		output_1 : OUT array_2d(0 TO n-1,0 TO m-1);
		output_2 : OUT array_2d(0 TO n-1,0 TO m-1)		
	);		
END sharp_filter;

ARCHITECTURE concurrent OF sharp_filter IS

SIGNAL A  : array_2d(0 TO 2,0 TO 2) := ((0,1,0),
													 (1,-4,1),
													 (0,1,0));	
													 
SIGNAL B  : array_2d(0 TO 2,0 TO 2) := ((1,1,1),
													 (1,-8,1),
													 (1,1,1));  
													 
SIGNAL out_tmp1 : array_2d(0 TO n-1,0 TO m-1) := ((OTHERS => (OTHERS => 0)));
SIGNAL out_tmp2 : array_2d(0 TO n-1,0 TO m-1) := ((OTHERS => (OTHERS => 0)));


SIGNAL out1 : array_2d(0 TO n-1,0 TO m-1) := ((OTHERS => (OTHERS => 0)));
SIGNAL out2 : array_2d(0 TO n-1,0 TO m-1) := ((OTHERS => (OTHERS => 0)));

BEGIN

L1: FOR i IN 0 TO n-3 GENERATE
	L2: FOR j IN 0 TO m-3 GENERATE

		
		out_tmp1(i,j) <= (input(i,j) * A(0,0)) + (input(i,j+1) * A(0,1)) + (input(i,j+2) * A(0,2)) + 
							  (input(i+1,j) * A(1,0)) + (input(i+1,j+1) * A(1,1)) + (input(i+1,j+2) * A(1,2)) + 
							  (input(i+2,j) * A(2,0)) + (input(i+2,j+1) * A(2,1)) + (input(i+2,j+2) * A(2,2));		
						 
		out1(i,j) <= 0 WHEN (out_tmp1(i,j)<0) 
									  ELSE out_tmp1(i,j);	
			
		out_tmp2(i,j) <= (input(i,j) * B(0,0)) + (input(i,j+1) * B(0,1)) + (input(i,j+2) * B(0,2)) + 
							  (input(i+1,j) * B(1,0)) + (input(i+1,j+1) * B(1,1)) + (input(i+1,j+2) * B(1,2)) + 
							  (input(i+2,j) * B(2,0)) + (input(i+2,j+1) * B(2,1)) + (input(i+2,j+2) * B(2,2));
						 
		out2(i,j) <= 0 WHEN (out_tmp2(i,j)<0) 
									  ELSE out_tmp2(i,j);
						 
    END	GENERATE L2;
END GENERATE L1;

output_1 <= out1;
output_2 <= out2;

END concurrent;
