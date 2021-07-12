library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity elevator_tb IS
end elevator_tb;

architecture  test OF elevator_tb IS 
	COMPONENT elevator IS 
		generic(n : integer := 4 );
		port(
		come : IN  std_logic_vector(n-1 downto 0);
		switch : IN  std_logic_vector(n-1 downto 0);
		go : IN  std_logic_vector(n-1 downto 0);
		door_open : IN std_logic ;
		door_close : IN std_logic ;
		fanin : IN std_logic ;
		
		clk : IN  std_logic;
		nrst: IN  std_logic;
		
		motor_up : OUT std_logic;
		motor_down : OUT std_logic;
		open_door_motor : OUT std_logic;
		close_door_motor : OUT std_logic;
		fanout : OUT std_logic;
		elevator_state : OUT std_logic_vector(n downto 0)
		);
	
	END COMPONENT;
	
	SIGNAL	come_t					: std_logic_vector(3 downto 0);
	SIGNAL 	switch_t 				: std_logic_vector(3 downto 0);
	SIGNAL	go_t 						: std_logic_vector(3 downto 0);
	SIGNAL	door_open_t 			: std_logic ;
	SIGNAL	door_close_t 			: std_logic ;
	SIGNAL	fanin_t 					: std_logic ;
		
	SIGNAL	clk_t 					: std_logic := '0';
	SIGNAL	nrst_t					: std_logic;
		
	SIGNAL	motor_up_t 				: std_logic;
	SIGNAL	motor_down_t 			: std_logic;
	SIGNAL	open_door_motor_t 	: std_logic;
	SIGNAL	close_door_motor_t 	: std_logic;
	SIGNAL	fanout_t 				: std_logic;
	SIGNAL	elevator_state_t 		: std_logic_vector(4 downto 0);
	
BEGIN
    u1: elevator GENERIC MAP (4) PORT MAP ( come_t, switch_t, go_t, door_open_t , door_close_t , fanin_t , clk_t , nrst_t , motor_up_t , motor_down_t ,
										open_door_motor_t , close_door_motor_t , fanout_t , elevator_state_t);
										
	clk_t <= NOT clk_t after 10 ns ;
	--PROCESS
	--begin
	
		switch_t   <= "0001", "0010" AFTER 70 ns, "0100" AFTER 90 ns , "1000" AFTER 110 ns, "0100" AFTER 210 ns , "0010" AFTER 230 ns;	
		go_t <= 		"0000" , "0010" after 190 ns , "0000" AFTER 250 ns ;
		come_t <= 	"0000" , "1000" after 50 ns , "0000" after 140 ns;	
		
		-- first come to 4 floor
		-- then go 2 floor
		
		fanin_t <= '0' , '1' after 80 ns; -- cheking fanin
		
		door_open_t <= '0' , '1' AFTER 390 ns , '0' AFTER 410 ns;
		door_close_t <= '0' , '1' AFTER 370 ns , '0' AFTER 390 ns;  -- checking door_close and door_open
		nrst_t <= '1';
		
		--go_t <= "0000" ;
		--come_t <= "0000" ;
		--switch_t <= "0001" ; -- floor 1
		
		--wait for 50 ns;
		--come_t <= "0100" ;
		--wait for 20 ns;
		--switch_t <= "0010" ;
		--WAIT FOR 20 ns;
		--switch_t <= "0100";
		
	--END PROCESS;	
END test;