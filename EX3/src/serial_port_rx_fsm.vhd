
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity serial_port_rx_fsm is 

	generic (
		CLK_DIVISOR : integer
	);
	port (
		clk : in std_logic;                       --clock
		res_n : in std_logic;                     --low-active reset
		
		rx : in std_logic;                       --serial input of the parallel input
		
		data : out std_logic_vector(7 downto 0);   --parallel output byte
		new_data : out std_logic       
	);
end entity;


architecture beh of serial_port_rx_fsm is
	type RECEIVER_STATE_TYPE is (IDLE, WAIT_START_BIT, GOTO_MIDDLE_OF_START_BIT, MIDDLE_OF_START_BIT, WAIT_DATA_BIT, MIDDLE_OF_DATA_BIT, WAIT_STOP_BIT, MIDDLE_OF_STOP_BIT);

	signal receiver_state : RECEIVER_STATE_TYPE;
	signal receiver_state_next : RECEIVER_STATE_TYPE; 
	
	signal data_int : std_logic_vector(7 downto 0);
	signal data_out : std_logic_vector(7 downto 0);
	
	signal data_new : std_logic;
	
	--clock cycle counter
	signal clk_cnt : integer range 0 to CLK_DIVISOR;
	signal clk_cnt_next : integer range 0 to CLK_DIVISOR;

	--bit counter
	signal bit_cnt : integer range 0 to 8;
	signal bit_cnt_next : integer range 0 to 8;
	signal data_int_next : std_logic_vector(7 downto 0);
	signal data_out_next : std_logic_vector(7 downto 0);
begin
  --------------------------------------------------------------------
  --                    PROCESS : SYNC                              --
  --------------------------------------------------------------------

	sync : process(res_n, clk)
	begin
		if res_n = '0' then
			receiver_state <= IDLE;
			clk_cnt <= 0;
		elsif rising_edge(clk) then
			receiver_state <= receiver_state_next;
			clk_cnt <= clk_cnt_next;
			bit_cnt <= bit_cnt_next;
			new_data <= data_new;
			data <= data_out;
			data_int <= data_int_next;
			data_out <= data_out_next;
		end if;
	end process;


  --------------------------------------------------------------------
  --                    PROCESS : NEXT_STATE                        --
  --------------------------------------------------------------------

	next_state : process(clk_cnt, bit_cnt, receiver_state, rx)
	begin
		receiver_state_next <= receiver_state; --default
			
		case receiver_state is
			when IDLE =>
				if rx = '1' then 
					receiver_state_next <= WAIT_START_BIT;
				end if;
			
			when WAIT_START_BIT =>
				if rx = '0' then
					receiver_state_next <= GOTO_MIDDLE_OF_START_BIT;
				end if;
				
			when GOTO_MIDDLE_OF_START_BIT => 
				if clk_cnt = CLK_DIVISOR/2 - 2 then 
					receiver_state_next <= MIDDLE_OF_START_BIT;
				end if;
			
			when MIDDLE_OF_START_BIT =>
				receiver_state_next <= WAIT_DATA_BIT;
			
			when WAIT_DATA_BIT =>
				if clk_cnt = CLK_DIVISOR - 2 then
					receiver_state_next <= MIDDLE_OF_DATA_BIT;
				end if;
			
			when MIDDLE_OF_DATA_BIT =>
				if bit_cnt >= 7 then 
					receiver_state_next <= WAIT_STOP_BIT;
				else
					receiver_state_next <= WAIT_DATA_BIT;
				end if;
				
			when WAIT_STOP_BIT =>
				if clk_cnt = CLK_DIVISOR - 2 then
					receiver_state_next <= MIDDLE_OF_STOP_BIT;
				end if;
			
			when MIDDLE_OF_STOP_BIT =>
				if rx = '1' then
					receiver_state_next <= WAIT_START_BIT;
				elsif rx = '0' then
					receiver_state_next <= IDLE;
				end if;
		end case;
	end process;


  --------------------------------------------------------------------
  --                    PROCESS : OUTPUT                            --
  --------------------------------------------------------------------
  
	output : process(clk_cnt, bit_cnt, receiver_state, rx, data_int, data_out)
	begin
		clk_cnt_next <= clk_cnt;
		bit_cnt_next <= bit_cnt;
		data_new <= '0';
		data_out_next <= data_out;
		data_int_next <= data_int;
		
		case receiver_state is
		
			when IDLE =>

			when WAIT_START_BIT =>
				bit_cnt_next <= 0;
				clk_cnt_next <= 0;
				
			when GOTO_MIDDLE_OF_START_BIT =>  
				clk_cnt_next <= clk_cnt + 1;
	
			when MIDDLE_OF_START_BIT =>
				clk_cnt_next <= 0; 
				
			when WAIT_DATA_BIT =>
				clk_cnt_next <= clk_cnt + 1;
			
			when MIDDLE_OF_DATA_BIT =>
				clk_cnt_next <= 0;
				bit_cnt_next <= bit_cnt + 1; 
				data_int_next <= rx & data_int(7 downto 1);
				
			when WAIT_STOP_BIT =>
				clk_cnt_next <= clk_cnt + 1;
			
			when MIDDLE_OF_STOP_BIT =>
				data_new <= '1';
				data_out_next <= data_int;
		end case;
	end process;

end architecture;


