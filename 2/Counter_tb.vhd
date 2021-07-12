LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;

ENTITY counter_tb IS
END counter_tb;

ARCHITECTURE behavioral OF counter_tb IS
	COMPONENT Counter IS
	
		 GENERIC(n : integer := 8);
		 
	    PORT (
        nrst    : IN    std_logic;
        clk     : IN    std_logic;
        mode    : IN    integer;
		  -- 0: up count
        -- 1: down count
		  --start 	 : IN		std_logic_vector(n-1 DOWNTO 0) := (OTHERS => '0');
		  interval : IN	integer := 3;
		  din     : IN    std_logic_vector(n-1 DOWNTO 0);
        dout    : OUT   std_logic_vector(n-1 DOWNTO 0)
			);
	 
	END COMPONENT;
	
	SIGNAL nrst_t    : std_logic;
	SIGNAL clk_t     : std_logic := '0';
	SIGNAL mode_t    : integer := 0;
--	SIGNAL	start_t 	 :	std_logic_vector(7 DOWNTO 0) ;
	SIGNAL  interval_t : integer := 3;
	SIGNAL din_t     : std_logic_vector(7 DOWNTO 0);
	SIGNAL dout_t    : std_logic_vector(7 DOWNTO 0);	
   
BEGIN
		cut: Counter GENERIC MAP (8) PORT MAP (nrst_t, clk_t, mode_t, interval_t, din_t, dout_t);
		

		clk_t <= NOT clk_t AFTER 50 ns;
		nrst_t <= '0' , '1' AFTER 120 ns;
		din_t <= B"00000001" AFTER 140 ns ;
		mode_t <= 2, 0 AFTER 200 ns , 1 AFTER 400 ns, 0 AFTER 500 ns;

END behavioral;