------------------------------------------------------
--Author: Jan Nausner <e01614835@student.tuwien.ac.at>
------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.core_pack.all;
use work.op_pack.all;

entity pipeline_tb is
end entity;

architecture bench of pipeline_tb is
    
    component pipeline is
        port (
            clk, reset : in std_logic;
            mem_in     : in mem_in_type;
            mem_out    : out mem_out_type;
            intr       : in std_logic_vector(INTR_COUNT-1 downto 0)
        );
    end component;

    constant CLK_PERIOD : time := 20 ns;

    signal clk, reset : std_logic;
    signal mem_in : mem_in_type;
    signal mem_out : mem_out_type;

begin

    UUT : pipeline
    port map (
        clk => clk,
        reset => reset,
        mem_in => mem_in, --stall
        mem_out => mem_out,
        intr => (others => '0')
    );

    stimulus : process
    begin
        mem_in.busy <= '0';
        mem_in.rddata <= (others => '0');
        reset <= '0';
        wait for 2*CLK_PERIOD;
        reset <= '1';
        mem_in.busy <= '1';
        wait for 1*CLK_PERIOD;
        mem_in.busy <= '0';
        wait for 20*CLK_PERIOD;
        mem_in.busy <= '1';
        wait for 1*CLK_PERIOD;
        mem_in.busy <= '0';
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

