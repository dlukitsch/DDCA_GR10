----------------------------------------------------------------------------------
-- Company:      TU Wien                                                        --
-- Engineer:     Stefan Adelmann                                                --
--                                                                              --
-- Create Date:  15.03.2018                                                     --
-- Design Name:  Exercise_1                                                     --
-- Module Name:  serial_port                                                    --
-- Project Name: Exercise_1                                                     --
-- Description:  Serial-port  Package                                           --
----------------------------------------------------------------------------------

----------------------------------------------------------------------------------
--                                LIBRARIES                                     --
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

----------------------------------------------------------------------------------
--                                 PACKAGE                                      --
----------------------------------------------------------------------------------

package serial_port_pkg is

	--------------------------------------------------------------------
	--                          COMPONENT                             --
	--------------------------------------------------------------------

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
			rx_data : out std_logic_vector(7 downto 0);
			rx_rd : in std_logic;
			rx_full : out std_logic;
			rx_empty : out std_logic;
			rx : in std_logic;
			tx : out std_logic   
		);
	end component serial_port;
end package serial_port_pkg;

--- EOF ---