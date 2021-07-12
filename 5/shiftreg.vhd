library IEEE;
use IEEE.STD_LOGIC_1164.ALL;



entity shiftreg IS 

	port(

	clk 		: IN  std_logic;
	nclear 	: IN  std_logic;

	sright 	: IN  std_logic;
	sleft	 	: IN  std_logic;
	
	mode 		: IN std_logic_vector(1 downto 0);
	input		: IN std_logic_vector(3 downto 0);
	output	: OUT std_logic_vector(3 downto 0)

	);

end shiftreg;


architecture sm OF shiftreg IS 

	SIGNAL q		: std_logic_vector(3 downto 0);

	
BEGIN
	comb: PROCESS (mode, sright, sleft, input, clk, nclear)
   
	begin
		IF nclear = '0' THEN
			q <= "0000";
		ELSIF  RISING_EDGE(clk) THEN 
	
			CASE mode IS
			
				when "00" =>
					q <= q;

				when "01" =>
					q(2 downto 0) <= q(3 downto 1);
					q(3) <= sright;
					
				when "10" =>
					q(3 downto 1) <= q(2 downto 0);
					q(0) <= sleft;
								
				when OTHERS =>
					q <= input;
				
			END CASE;
		END IF;

	END process comb;
		output <= q;
		
END sm;