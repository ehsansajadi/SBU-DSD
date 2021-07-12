ENTITY uart IS
	PORT (
	reset 			: IN std_logic; 
	uart_clock 		: IN std_logic; 	 
	tx_data 		: IN std_logic_vector(7 DOWNTO 0);
	tx_wren 		: IN std_logic; 
	reg tx 			: IN std_logic;
	tx_led 			: OUT std_logic;
	tx_accept 		: OUT std_logic;
	rx_clock 		: IN std_logic;
	rx 				: IN std_logic;
	rx_led 			: OUT std_logic;
	rx_data 		: OUT std_logic_vector(7 DOWNTO 0);
	rx_data_ready : OUT std_logic
	);
END uart;
ARCHITECTURE behavioral OF uart IS
	CONSTANT WAIT_DELAY 	: integer := 200;
	CONSTANT RX_CLOCK_MUL 	: integer := 5;
	CONSTANT STOPBITS 		: integer := 1;
	CONSTANT PARITY 		: integer := 0;
	CONSTANT BITSIZE 		: integer := 8;
	CONSTANT TX_INIT 		: integer := 0;
	CONSTANT TX_IDLE 		: integer := 1;
	CONSTANT TX_START_BIT 	: integer := 2;
	CONSTANT TX_SEND_8BIT 	: integer := 3;
	CONSTANT TX_PARITY_BIT 	: integer := 4;
	CONSTANT TX_STOP_BIT 	: integer := 5;
	
	SIGNAL wait_count 	: integer;
	SIGNAL tx_state 	: std_logic_vector(2 DOWNTO 0);	
	SIGNAL tx_bit_count : std_logic_vector(2 DOWNTO 0);	
	SIGNAL tx_bits 		: std_logic_vector(7 DOWNTO 0);	
	SIGNAL tx_stopbits 	: std_logic;
	SIGNAL tx_parity 	: std_logic;
BEGIN
	--tx_led <= (tx_state == TX_START_BIT || tx_state == TX_SEND_8BIT || tx_state == TX_STOP_BIT);
	tx_led <= '1' WHEN tx_state = TX_START_BIT OR tx_state = TX_SEND_8BIT OR tx_state = TX_STOP_BIT ELSE '0';

	PROCESS (uart_clock, reset)
	BEGIN
		IF reset = '1' THEN
			wait_count <= 0;
			tx_state <= TX_INIT;
			tx <= '1';
			tx_accept <= '0';
			tx_bits <= '0';
			tx_bit_count <= 0;
			tx_stopbits <= '0';
			tx_parity <= '0';
		ELSIF clk'EVENT AND clk = '1' THEN
		END IF;
	END PROCESS;
	
	always @(posedge uart_clock or posedge reset)
	begin
		if(reset) begin
			// state
			wait_count <= 'b0;
			tx_state <= TX_INIT;

			// TX
			tx <= 'b1;
			tx_accept <= 'b0;
			tx_bits <= 'b0;
			tx_bit_count <= 0;
			tx_stopbits <= 1'b0;
			tx_parity <= 1'b0;
		
		end else begin
		
			case(tx_state)
				TX_INIT: begin
					tx <= 'b1; // Put the tx pin into idle immediately
					
					// Wait some time sending any data
					if(wait_count == (WAIT_DELAY - 1)) begin
						tx_state <= TX_IDLE;
					end else begin
						wait_count <= wait_count + 1;
					end

				end
				TX_IDLE:	begin
					tx <= 'b1;
					if(tx_wren)
					begin
						tx_bits <= tx_data;
						tx_accept <= 'b1;
						tx_state <= TX_START_BIT;
					end				
				end
				TX_START_BIT: begin
					// For one clock cycle pull tx low to 0 to trigger a start bit
					tx <= 'b0;
					
					// The data input clock goes low in the start_bit so that new data can be prepared asap
					tx_accept <= 'b0;
					
					// Send 8 bits of data...
					tx_bit_count <= 0;
					tx_parity <= 1'b0;
					tx_state <= TX_SEND_8BIT;
				end
				TX_SEND_8BIT: begin
					// Set current output bit and rotate
					tx_parity <= tx_parity ^ tx_bits[0];
					tx <= tx_bits[0];
					tx_bits <= {1'b0, tx_bits[7:1]};
					
					// After BITSIZE bits, send a parity bit or skip to stop bit
					if(tx_bit_count == (BITSIZE - 1)) begin
						tx_stopbits <= 1'b0;
						tx_state <= (PARITY == 1 || PARITY == 2) ? TX_PARITY_BIT : TX_STOP_BIT;
					end else begin
						tx_bit_count <= tx_bit_count + 1;
					end
				end
				TX_PARITY_BIT: begin
					// If there were an odd number of 1s, tx_parity is 1 right now
					// If there were an even number of 1s, tx_parity is 0 right now
					// ODD mode (PARITY==1), wants a 1 if there were an even number of ones
					// EVEN mode (PARITY==2), wants a 1 if there were an odd number of ones
					tx <= (PARITY == 1) ? ~tx_parity : tx_parity;
					tx_state <= TX_STOP_BIT; // Only one bit of parity
				end
				TX_STOP_BIT: begin
					// Send a '1' for the stop bit
					tx <= 'b1;
					
					// If there's 1 stop bit, then proceed to the next byte in one cycle
					// otherwise, for 2 stop bits, wait one extra stop bit cycle before 
					// the next byte
					if((STOPBITS == 1) || ((STOPBITS == 2 && tx_stopbits == 1'b1))) begin
						// If tx_wren is high then there's more data
						if(tx_wren)
						begin
							tx_bits <= tx_data;
							tx_accept <= 'b1;
							tx_state <= TX_START_BIT;
						end else begin
							// If there's no data to transmit, go into IDLE leaving tx high
							tx_state <= TX_IDLE;
						end
					end else begin
						tx_stopbits <= 1'b1;
					end
				end
				default: begin
					tx <= 'b0;
					tx_accept <= 'b1;
					tx_bit_count <= 0;
					tx_state <= TX_IDLE;
				end
			endcase
		end
	end

	localparam RX_START_BIT_SAMPLES = (RX_CLOCK_MUL + 1) / 2;
	localparam RX_IDLE=0, RX_START_BIT=1, RX_SAMPLE_BITS=2, RX_PARITY_BIT=3, RX_STOP_BIT=4;
	
	reg [2:0] rx_state;
	reg [($clog2(RX_CLOCK_MUL)-1):0] rx_counter;
	
	reg [2:0] rx_bit_count;
	reg [7:0] rx_bits;
	
	assign rx_led = (rx_state == RX_START_BIT || rx_state == RX_SAMPLE_BITS || rx_state == RX_STOP_BIT);
	
	reg rx_stopbits;
	reg rx_parity;
	
	always @(posedge rx_clock or posedge reset)
	begin
		if(reset) begin
			rx_counter <= 0;
			rx_bit_count <= 0;
			rx_bits <= 8'b0;
			rx_data <= 8'b0;
			rx_data_ready <= 0;
			rx_state <= RX_IDLE;
			rx_stopbits <= 1'b0;
			rx_parity <= 1'b0;
	
		end else begin
		
			case(rx_state)
				RX_IDLE: begin
					// In idle, wait for rx to go low for a long enough period of time
					if(~rx) begin
						if(rx_counter == (RX_START_BIT_SAMPLES - 1)) begin
							rx_counter <= 0;
							rx_state <= RX_START_BIT;
						end else begin
							rx_counter <= rx_counter + 1;
						end
					end else begin
						rx_counter <= 0;
					end
				end
				RX_START_BIT: begin
					// now wait for a full uart clock cycle before sampling data..
					if(rx_counter == (RX_CLOCK_MUL - 1)) begin
						rx_bit_count <= 0;
						rx_counter <= 0;
						rx_parity <= 1'b0;
						rx_state <= RX_SAMPLE_BITS;
					end else begin
						rx_counter <= rx_counter + 1;
					end
				end
				RX_SAMPLE_BITS: begin
					if(rx_counter == 0) begin
						rx_parity <= rx_parity ^ rx;
						
						if(rx_bit_count == (BITSIZE - 1)) begin
							// On SIZEs < 8, we have to shift bits into position, but this works for 8 too
							rx_bits <= {rx, rx_bits[7:1]} >> (8 - BITSIZE);				
							rx_state <= (PARITY == 1 || PARITY == 2) ? RX_PARITY_BIT : RX_STOP_BIT;
							rx_stopbits <= 1'b0;
							rx_data_ready <= 1'b0;
						end else begin
							rx_bits <= {rx, rx_bits[7:1]};
							rx_bit_count <= rx_bit_count + 1;
						end
					end 
					
					if(rx_counter == (RX_CLOCK_MUL - 1)) begin
						rx_counter <= 0;
					end else begin
						rx_counter <= rx_counter + 1;
					end
				end
				RX_PARITY_BIT: begin
					// counter is at 1 when entering this state
					if(rx_counter == 0) begin
						// If there were an odd number of 1s, tx_parity is 1 right now
						// If there were an even number of 1s, tx_parity is 0 right now
						// ODD mode (PARITY==1), wants a 1 if there were an even number of ones
						// EVEN mode (PARITY==2), wants a 1 if there were an odd number of ones
						if(((PARITY == 1) && (rx == ~rx_parity)) || ((PARITY == 2) && (rx == rx_parity))) begin
							rx_state <= RX_STOP_BIT;
						end else begin
							// The parity bit was incorrect so back to IDLE...TODO: transmission error output signal
							rx_state <= RX_IDLE;
						end
					end

					if(rx_counter == (RX_CLOCK_MUL - 1)) begin
						rx_counter <= 0;
					end else begin
						rx_counter <= rx_counter + 1;
					end					
				end
				RX_STOP_BIT: begin
					// counter is at 1 when entering this state
					if(rx_counter == 0) begin
						if(rx) begin // transmission done
							// Stop bit received
							if((STOPBITS == 1) || ((STOPBITS == 2) && rx_stopbits == 1'b1)) begin
								rx_data <= rx_bits;
								rx_state <= RX_IDLE;
								
								// the system has until the next stop bit to pull the data
								// and must wait for rx_data_ready to go low before the next data
								// is available
								rx_data_ready <= 1'b1; 
							end else begin
								rx_stopbits <= 1'b1;
							end
						end else begin 
							// There's no stop bit, so we assume there's a transmission error
							// For now, ignore the data. TODO: transmission error output signal
							rx_state <= RX_IDLE;
						end
					end 
					
					if(rx_counter == (RX_CLOCK_MUL - 1)) begin
						rx_counter <= 0;
					end else begin
						rx_counter <= rx_counter + 1;
					end										
				end
				default: begin
					rx_counter <= 0;
					rx_bit_count <= 0;
					rx_bits <= 8'b0;
					rx_data <= 8'b0;
					rx_data_ready <= 0;
					rx_state <= RX_IDLE;
				end
			endcase
		end
	end
	
endmodule
	
