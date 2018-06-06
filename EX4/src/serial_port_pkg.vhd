library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.sync_pkg.all;
use work.math_pkg.all;
use work.ram_pkg.all;

package serial_port_pkg is

	component serial_port is 

		generic (
			CLK_FREQ : integer;
			BAUD_RATE : integer;
			SYNC_STAGES : integer;
			TX_FIFO_DEPTH : integer;
			RX_FIFO_DEPTH : integer
		);
		port (
			clk : in std_logic;                       --clock
			res_n : in std_logic;                     --low-active reset
		
			tx_data : in std_logic_vector(7 downto 0);  --data to transmit to to host
			tx_wr : in std_logic;						--1 if new tx data present
			tx_free : out std_logic;					--1 if internal buffer is full and no new data can be written
			--tx_full : out std_logic;

			rx_data : out std_logic_vector(7 downto 0);	--the byte which was last read from the receiver fifo
			rx_rd : in std_logic;						--1 if next byte from fifo available
			rx_data_full : out std_logic;					--1 if receiver fifo is full and characters may have been lost
			rx_data_empty : out std_logic;					--1 if receiver fifo is empty

			rx : in std_logic;                       --serial input (host -> device)
			tx : out std_logic						 --serial output (device -> host)
		);

	end component;

end package serial_port_pkg;
