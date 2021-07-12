LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;

ENTITY counter IS
	 GENERIC(n : integer := 8);
	 
    PORT (
        nrst    : IN    std_logic;
        clk     : IN    std_logic;
        mode    : IN    integer;
		  -- 0: up count
        -- 1: down count  
			--start 	 : IN		std_logic_vector(n-1 DOWNTO 0) := (OTHERS => '0');
		  interval : IN	integer := 2;
     
		  din     : IN    std_logic_vector(n-1 DOWNTO 0);
        dout    : OUT   std_logic_vector(n-1 DOWNTO 0)
    );
END counter;

ARCHITECTURE behavioral OF counter IS
    SIGNAL temp : std_logic_vector(n-1 DOWNTO 0) := din;
BEGIN
    PROCESS (clk)
    BEGIN
        IF clk = '1' and clk'EVENT THEN
					IF nrst = '0' THEN
						 temp <= (OTHERS => '0');
					ELSE
						 IF    mode = 0 THEN
							  temp <= temp + interval;
						 ELSIF mode = 1 THEN
							  temp <= temp - interval;
						 ELSE
						 temp <= din;
						 END IF;
					END IF;
        END IF;
		  	 		
    END PROCESS;
	dout <= temp;
END behavioral;