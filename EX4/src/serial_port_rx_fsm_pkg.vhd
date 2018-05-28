----------------------------------------------------------------------------------
-- Company:      TU Wien                                                        --
-- Engineer:     Stefan Adelmann                                                --
--                                                                              --
-- Create Date:  15.03.2018                                                     --
-- Design Name:  Exercise_1                                                     --
-- Module Name:  serial_port_rx_fsm                                             --
-- Project Name: Exercise_1                                                     --
-- Description:  Serial-port receiver Package                                    --
----------------------------------------------------------------------------------

----------------------------------------------------------------------------------
--                                LIBRARIES                                     --
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

----------------------------------------------------------------------------------
--                                 PACKAGE                                      --
----------------------------------------------------------------------------------

package serial_port_rx_fsm_pkg is

	--------------------------------------------------------------------
	--                          COMPONENT                             --
	--------------------------------------------------------------------

	-- serial connection of flip-flops to avoid latching of metastable inputs at
	-- the analog/digital interface
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
  end component serial_port_rx_fsm;
end package serial_port_rx_fsm_pkg;

--- EOF ---