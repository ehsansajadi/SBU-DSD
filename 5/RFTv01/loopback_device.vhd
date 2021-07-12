LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_arith.ALL;
USE ieee.std_logic_unsigned.ALL;
ENTITY loopback_Device IS
	PORT (
		nRST 				: IN  STD_LOGIC;
		sys_clk 			: IN  STD_LOGIC;
		nPause 			: IN  STD_LOGIC;
		wren 				: OUT STD_LOGIC;
		tx_data 			: OUT std_logic_vector(7 DOWNTO 0);	 
		rx_data 			: IN  std_logic_vector(7 DOWNTO 0);
		rx_data_ready  : IN  std_logic;
		led_out 			: OUT std_logic_vector(7 DOWNTO 0);
		rx_data_accept : OUT std_logic;
		
		------------------------------------------------
		-- test vector signals should be configured 
		-- corresponding with the design
		-- Should be updated
		------------------------------------------------
		cut_clk  : OUT std_logic;
		cut_nclear	: OUT std_logic;
		cut_sright  	: OUT std_logic;
		cut_sleft  	: OUT std_logic;
		cut_mode  : OUT std_logic_vector(1 DOWNTO 0);
		cut_input  : OUT std_logic_vector(3 DOWNTO 0);
		cut_output	: IN std_logic_vector(3 DOWNTO 0)
	);
END loopback_Device;

ARCHITECTURE behavioral OF loopback_Device IS	
	----------------------------------------------------------------------
	-- Number of input and output bits: 
	-- Should be updated
	----------------------------------------------------------------------
	CONSTANT InputSize  : integer := 10; -- number of input bits
	CONSTANT OutputSize : integer := 4;  -- number of output bits
	----------------------------------------------------------------------
	
	
	CONSTANT CHAR0 : std_logic_vector(7 DOWNTO 0) := "00110000";
	CONSTANT CHAR1 : std_logic_vector(7 DOWNTO 0) := "00110001";
	TYPE reg_file IS ARRAY (0 TO 255) OF std_logic_vector(7 DOWNTO 0);
	TYPE lp_state IS (wait_for_data, wait_one_cycle, send_output);
	
	SIGNAL state 			: lp_state;
	SIGNAL input_reg 		: reg_file;
	SIGNAL output_reg 	: reg_file;
	SIGNAL icntr, ocntr 	: integer RANGE 0 TO 255;
	SIGNAL dout  			: std_logic_vector(7 DOWNTO 0);
	SIGNAL led_out_temp  : std_logic_vector(7 DOWNTO 0);
	SIGNAL led_out_cntr 	: std_logic_vector(7 DOWNTO 0);
	FUNCTION c2s(x : std_logic_vector) RETURN std_logic IS
	BEGIN
		IF x = CHAR0 THEN
			RETURN '0';
		ELSE
			RETURN '1';
		END IF;
	END c2s;
	FUNCTION s2c(x : std_logic) RETURN std_logic_vector IS
	BEGIN
		IF x = '0' THEN
			RETURN CHAR0;
		ELSE
			RETURN CHAR1;
		END IF;
	END s2c;
BEGIN

	led_out <= led_out_cntr;

	seq: PROCESS(sys_clk, nRST)
	BEGIN
		IF nRST = '0' THEN
			tx_data <= (OTHERS => '0');
			wren <= '0';
			rx_data_accept <= '0';
			state <= wait_for_data;
			icntr <= 0;
			ocntr <= 0;
			led_out_temp <= (OTHERS => '0');
			led_out_cntr <= (OTHERS => '0');
		ELSIF sys_clk'EVENT AND sys_clk = '1' THEN
			IF nPause = '1' THEN
				wren <= '0';
				rx_data_accept <= '0';
				CASE state IS
					WHEN wait_for_data =>
						IF rx_data_ready = '1' THEN
							wren <= '1';
							rx_data_accept <= '1';
							IF icntr = InputSize THEN
								tx_data <= X"3D"; --=
								ocntr <= 0;
								state <= send_output;
							ELSE
								input_reg(icntr) <= rx_data;
								tx_data <= rx_data;
								icntr <= icntr + 1;
								state <= wait_one_cycle;
							END IF;		
						END IF;
					WHEN wait_one_cycle =>
						rx_data_accept <= '0';
						wren <= '0';
						state <= wait_for_data;
					WHEN send_output =>
							wren <= '1';
							rx_data_accept <= '1';
						IF ocntr = OutputSize THEN
							tx_data <= X"23"; -- #
							state <= wait_one_cycle;
							icntr <= 0;
						ELSE
							tx_data <= output_reg(OutputSize - ocntr - 1);
							state <= send_output;
							ocntr <= ocntr + 1;
						END IF;
						led_out_cntr <= led_out_cntr + '1';
					WHEN OTHERS =>					
						wren <= '0';
						rx_data_accept <= '0';
						tx_data <= (OTHERS => '0');
						tx_data <= rx_data;
						state <= wait_for_data;
				END CASE;
			END IF;
		END IF;
	END PROCESS seq;

	------------------------------------------
	-- Inteface with CUT: Should be updated
	-- Should be updated
	------------------------------------------

	-- convert input characters to bits
	cut_clk  	<= c2s(input_reg(0));
	cut_nclear		<= c2s(input_reg(1));
	cut_sright  		<= c2s(input_reg(2));
	cut_sleft  <= c2s(input_reg(3));
	cut_mode(1)  <= c2s(input_reg(4));
	cut_mode(0)  <= c2s(input_reg(5));
	cut_input(3)  <= c2s(input_reg(6));
	cut_input(2) <= c2s(input_reg(7));
	cut_input(1) <= c2s(input_reg(8));
	cut_input(0) <= c2s(input_reg(9));

	-- convert output bits to character
	output_reg(3) <= s2c(cut_output(3));
	output_reg(2) <= s2c(cut_output(2));
	output_reg(1) <= s2c(cut_output(1));
	output_reg(0) <= s2c(cut_output(0));
---------------------------------------------	
END behavioral;
