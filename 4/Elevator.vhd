library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity elevator IS 
	generic(n : integer := 4 );
	port(

	clk : IN  std_logic;
	nrst: IN  std_logic;
	
	come , go : IN  std_logic_vector(n-1 downto 0);
	switch : IN std_logic_vector(n-1 downto 0);
	
	
	door_open , door_close , fanin : IN std_logic ;	

	motor_up , motor_down , open_door_motor , close_door_motor , fanout , motor_slow : OUT std_logic;
	elevator_state  : OUT std_logic_vector(n downto 0)
	);
end elevator;
	
architecture sm OF elevator IS 
	TYPE state is (	S0 , S1 , S2 , S3 , S4);	-- s0 : door open and stable  / S1 : door close and stable
																--	S2 : moving up / S3 : moving down
																--S4 : MOTOR SLOW ENABLE
	SIGNAL curr_state 	: state := S0;
	SIGNAL next_state 	: state;
	 --SIGNAL to_out       : std_logic_vector(n-1 DOWNTO 0);
	
BEGIN
	comb: PROCESS (curr_state , go , come , switch , door_close , door_open  )
	
		variable moving : std_logic := '0';
	
   
	begin
		
		CASE curr_state IS 
		
			when S0 =>

				IF ( ((switch = come OR switch = go) OR (go = "0000" AND come = "0000")) AND door_close = '0' ) THEN
					next_state <= S0;					-- if there is no command stay in S0 
					motor_down <= '0';
					motor_up <= '0';
					moving := '0';
					motor_slow <= '0';
					close_door_motor <= '0';
					open_door_motor <= '0' ;
						
				ELSE	 
					next_state <= S1;					-- if there is come or go or door_close command
					close_door_motor <= '1';
					open_door_motor <= '0' ;
				END IF;
			
			
			when S1 =>
				close_door_motor <= '0' ;
				IF ((switch < come OR switch < go) AND (go /= "0000" OR come /= "0000")) THEN -- going up
					next_state <= S2;
					motor_up <= '1';
					moving := '1';
				ELSIF ((switch > come OR switch > go) AND (go /= "0000" OR come /= "0000")) THEN --going down
					next_state <= S3;
					motor_down <= '1';
					moving := '1';
				ELSIF ((switch = come OR switch = go) OR (go = "0000" AND come = "0000"))  THEN	--reach floor and open_door
						next_state <= S0;
						motor_down <= '0';
						motor_up <= '0';
						moving := '0';
						motor_slow <= '0';
						open_door_motor <= '1' ;
						
				ELSIF door_open = '1' THEN					-- if door_open enabled
						open_door_motor <='1';
						next_state <= S0;
				ELSE												-- no command and stay S1
					next_state <= S1;
				END IF;
					
			when S2 =>
				
				IF switch < come OR switch < go THEN		-- still going up
					next_state <= S2;		
				ELSIF switch = come OR switch = go THEN		-- near floor and motor_slow should active in S4
					next_state <= S4;
					close_door_motor <= '0';
					--open_door_motor <= '1' ;
					--motor_up <= '0' ;
					--moving := '0';
				END IF;
				
				
			when S3 =>

				IF (switch > come OR switch > go) AND (go = "0000" AND come = "0000") THEN -- still going down
					next_state <= S3;		
				ELSE										-- near floor and motor_slow should active in S4
					next_state <= S4;
					close_door_motor <= '0';
					--open_door_motor <= '1';
					--motor_down <= '0';
					--moving := '0';
				END IF;
				
				when S4 =>			-- motor_slow enable
					
					motor_slow <= '1' ;
					next_state <= S1 ;
					
				
			END CASE;
			
			elevator_state(n-1 downto 0) <= switch;
			elevator_state(n) <= moving;
			
			IF fanin = '1' THEN
			fanout <= '1';
			ELSE
			fanout <= '0';
			END IF;	
	

	end process comb;
	
	seq: PROCESS(clk , nrst)
		begin
			IF nrst = '0' THEN
				curr_state <= S0;
			ELSIF RISING_EDGE(clk) THEN   
			curr_state <= next_state;
			END IF;
	end process seq;

end sm;
	