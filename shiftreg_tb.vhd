library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity shiftreg_tb IS
end shiftreg_tb;

architecture test OF shiftreg_tb IS 
	COMPONENT shiftreg IS 

	port(

	clk 		: IN  std_logic;
	nclear 	: IN  std_logic;

	sright 	: IN  std_logic;
	sleft	 	: IN  std_logic;
	
	mode 		: IN std_logic_vector(1 downto 0);
	input		: IN std_logic_vector(3 downto 0);
	output	: OUT std_logic_vector(3 downto 0)

	);

	END COMPONENT;
	
	
	SIGNAL clk_t 		:   std_logic :='0' ;
	SIGNAL nclear_t 	:   std_logic := '0' ;

	SIGNAL sright_t 	:   std_logic := '0';
	SIGNAL sleft_t		:   std_logic := '0';
	
	SIGNAL mode_t 		:  std_logic_vector(1 downto 0);
	SIGNAL input_t		:  std_logic_vector(3 downto 0);
	SIGNAL output_t	:  std_logic_vector(3 downto 0);
	
	
		
BEGIN
    u1: shiftreg PORT MAP ( clk_t, nclear_t, sright_t, sleft_t, mode_t, input_t, output_t);
										
	clk_t <= NOT clk_t after 10 ns ;
	
	nclear_t <= '1' AFTER 40 ns;
	
	input_t <= "0000", "0100" AFTER 50 ns;
	mode_t <= "00", "11" AFTER 100 ns, "10" AFTER 150 ns, "01" AFTER 200 ns;
	sleft_t <= '1' AFTER 150 ns , '0' AFTER 180 ns;
	sright_t <= '1' AFTER 200 ns, '0' AFTER 240 ns;
	
END test;