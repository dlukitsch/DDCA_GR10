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

    constant CLK_PERIOD : time := 20 ns;
    
    signal clk, reset, tx, rx : std_logic;


begin

	UUT : mimi
	port map (
	clk_pin => clk,
	reset_pin => reset,
	tx => tx,
	rx => rx,
	intr_pin => (others => '0')
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

