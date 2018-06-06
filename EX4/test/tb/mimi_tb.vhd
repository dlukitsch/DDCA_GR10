------------------------------------------------------
--Author: Jan Nausner <e01614835@student.tuwien.ac.at>
------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.core_pack.all;
use work.op_pack.all;

entity mimi_tb is
end entity;

architecture bench of mimi_tb is
    
	component mimi is
		port (
			clk_pin   : in  std_logic;
			reset_pin : in  std_logic;
			tx  	  : out std_logic;
			rx        : in  std_logic;
			intr_pin  : in  std_logic_vector(INTR_COUNT-1 downto 0));

	end component;

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
	end component;

    constant CLK_PERIOD : time := 20 ns;
    
    signal clk, reset, tx, rx : std_logic;

	signal rx_data : std_logic_vector(7 downto 0);

begin

	UUT : mimi
	port map (
		clk_pin => clk,
		reset_pin => reset,
		tx => tx,
		rx => rx,
		intr_pin => (others => '0')
	);

	test_uart : serial_port
	generic map (
		CLK_FREQ => 50000000,
		BAUD_RATE => 115200,
		SYNC_STAGES => 2,
		TX_FIFO_DEPTH => 4,
		RX_FIFO_DEPTH => 4
	)
	port map (
		clk => clk,
		res_n => reset,
		tx_data => (others => '0'),
		tx_wr => '0',
		tx_full => open,
		tx_free => open,
		rx_data => rx_data,
		rx_rd => '1',
		rx_data_full => open,
		rx_data_empty => open,
		rx => tx,
		tx => open
	);

    stimulus : process
    begin
	rx <= '0';
        reset <= '0';
        wait for 1.5*CLK_PERIOD;
        reset <= '1';
        wait;  
    end process;

    generate_clk : process
    begin
        clk <= '1';
        wait for CLK_PERIOD/2;
        clk <= '0';
        wait for CLK_PERIOD/2;
    end process;

end architecture;

