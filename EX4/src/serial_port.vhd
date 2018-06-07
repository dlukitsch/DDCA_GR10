library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.sync_pkg.all;
use work.math_pkg.all;
use work.ram_pkg.all;

entity serial_port is 

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
		--tx_full : out std_logic;					--1 if internal buffer is full and no new data can be written
		tx_free : out std_logic;

		rx_data : out std_logic_vector(7 downto 0);	--the byte which was last read from the receiver fifo
		rx_rd : in std_logic;						--1 if next byte from fifo available
		rx_data_full : out std_logic;					--1 if receiver fifo is full and characters may have been lost
		rx_data_empty : out std_logic;					--1 if receiver fifo is empty

		rx : in std_logic;                       --serial input (host -> device)
		tx : out std_logic						 --serial output (device -> host)
	);

end entity;

architecture structure of serial_port is

	signal rd_data : std_logic_vector(7 downto 0);
	signal tx_empty : std_logic;
	signal rd : std_logic;

	signal rx_sync : std_logic;
	signal new_data : std_logic;
	signal wr_data : std_logic_vector(7 downto 0);

	signal tx_full : std_logic;

	component serial_port_tx_fsm is 

		generic (
			CLK_DIVISOR : integer
		);
		port (
			clk : in std_logic;                       --clock
			res_n : in std_logic;                     --low-active reset
		
			tx : out std_logic;                       --serial output of the parallel input
		
			data : in std_logic_vector(7 downto 0);   --parallel input byte
			empty : in std_logic;                     --empty signal from the fifo is connected here
			rd : out std_logic                        --connected to the rd input of the fifo
		);
	end component;

	component serial_port_rx_fsm is 

		generic (
			CLK_DIVISOR : integer
		);
		port (
			clk : in std_logic;                       --clock
			res_n : in std_logic;                     --low-active reset
		
			rx : in std_logic;                       --serial input, don't forget synchronizer!
		
			new_data : out std_logic;				--signify if new data is available 
			data : out std_logic_vector(7 downto 0)   --parallel input byte
		);
	end component;

begin

	tx_free <= not tx_full;

	sys_inst : sync
	generic map (
		SYNC_STAGES => SYNC_STAGES,
		RESET_VALUE => '1'
	)
	port map (
		clk => clk,
		res_n => res_n,
		data_in => rx,
		data_out => rx_sync
	);

	tx_fsm : serial_port_tx_fsm
	generic map (
		CLK_DIVISOR => CLK_FREQ / BAUD_RATE
	)
	port map (
		clk => clk,
		res_n => res_n,
		
		tx => tx,
		
		data => rd_data,
		empty => tx_empty,
		rd => rd
	);

	tx_fifo_inst : fifo_1c1r1w
	generic map (
		MIN_DEPTH => TX_FIFO_DEPTH,
		DATA_WIDTH => 8 
	)
	port map (
		clk => clk,
		res_n => res_n,
		rd_data => rd_data,
		rd => rd,
		wr_data => tx_data,
		wr => tx_wr,
		empty => tx_empty,
		full => tx_full,
		fill_level => open
	);

	rx_fsm : serial_port_rx_fsm
	generic map (
		CLK_DIVISOR => CLK_FREQ / BAUD_RATE
	)
	port map (
		clk => clk,
		res_n => res_n,
		
		rx => rx_sync,
		
		new_data => new_data,
		data => wr_data
	);

	rx_fifo_inst : fifo_1c1r1w
	generic map (
		MIN_DEPTH => RX_FIFO_DEPTH,
		DATA_WIDTH => 8 
	)
	port map (
		clk => clk,
		res_n => res_n,
		rd_data => rx_data,
		rd => rx_rd,
		wr_data => wr_data,
		wr => new_data,
		empty => rx_data_empty,
		full => rx_data_full,
		fill_level => open
	);
	
end architecture;
