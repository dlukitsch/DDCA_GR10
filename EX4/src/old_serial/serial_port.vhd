
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
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
		
		tx_data : in std_logic_vector(7 downto 0);
		tx_wr : in std_logic;
		tx_full : out std_logic;
		tx_free : out std_logic;
		rx_data : out std_logic_vector(7 downto 0);
		rx_rd : in std_logic;
		rx_data_full : out std_logic;
		rx_data_empty : out std_logic;
		rx : in std_logic;
		tx : out std_logic   
	);
end entity;


architecture beh of serial_port is
	
	--sync declaration-------------------------------------------------------------
	component sync is
		generic (
			SYNC_STAGES : integer range 2 to integer'high;
			RESET_VALUE : std_logic
		);
		
		port (
			clk : in std_logic;
			res_n : in std_logic;
			data_in : in std_logic;
			data_out : out std_logic
		);
	end component;
	
	component fifo_1c1r1w is
		generic (
			MIN_DEPTH : integer;
			DATA_WIDTH : integer;
			FILL_LEVEL_COUNTER : string := "OFF"
		);
		port (
			clk : in std_logic;
			res_n : in std_logic;
			rd_data : out std_logic_vector(DATA_WIDTH -1 downto 0);
			rd : in std_logic;
			wr_data : in std_logic_vector(DATA_WIDTH -1 downto 0);
			wr : in std_logic;
			empty : out std_logic;
			full : out std_logic;
			fill_level : out std_logic_vector(log2c(MIN_DEPTH)-1 downto 0)
		);
	end component;
	
	component serial_port_rx_fsm is
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
  end component;
  
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
	
	signal rx_sync : std_logic;
	signal new_data : std_logic;
	signal data : std_logic_vector(7 downto 0);
	signal tx_data_empty : std_logic;
	signal tx_data_fifo : std_logic_vector(7 downto 0);
	signal rd : std_logic;
	
begin
	tx_free <= not tx_full;

	serial_sync : sync
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
	
	rx_fsm_inst : serial_port_rx_fsm
	generic map (
		CLK_DIVISOR => CLK_FREQ/BAUD_RATE
	)
	port map (
		clk => clk,
		res_n => res_n,
		rx => rx_sync,
		new_data => new_data,
		data => data
	);
	
	rx_fifo_inst : fifo_1c1r1w
	generic map (
		MIN_DEPTH => RX_FIFO_DEPTH,
		DATA_WIDTH => 8
	)
	port map (
		clk => clk,
		res_n => res_n,
		rd => rx_rd,
		wr => new_data,
		wr_data => data,
		empty => rx_data_empty,
		rd_data => rx_data,
		full => rx_data_full,
		fill_level => open
	);
	
	tx_fifo_inst : fifo_1c1r1w
	generic map (
		MIN_DEPTH => TX_FIFO_DEPTH,
		DATA_WIDTH => 8
	)
	port map (
		clk => clk,
		res_n => res_n,
		rd => rd,
		wr => tx_wr,
		wr_data => tx_data,
		empty => tx_data_empty,
		rd_data => tx_data_fifo,
		full => tx_full,
		fill_level => open
	);
	
	tx_fsm_inst : serial_port_tx_fsm
	generic map (
		CLK_DIVISOR => CLK_FREQ/BAUD_RATE
	)
	port map (
		clk => clk,
		res_n => res_n,
		empty => tx_data_empty,
		data => tx_data_fifo,
		rd => rd,
		tx => tx
	);
	
end architecture;


