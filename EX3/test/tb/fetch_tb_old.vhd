------------------------------------------------------
--Author: Jan Nausner <e01614835@student.tuwien.ac.at>
------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.core_pack.all;
use work.tb_util_pkg.all;

entity fetch_tb is
end entity;

architecture bench of fetch_tb is
    
    component fetch is
    
        port (
            clk, reset : in  std_logic;
            stall      : in  std_logic;
            pcsrc      : in  std_logic;
            pc_in      : in  std_logic_vector(PC_WIDTH-1 downto 0);
            pc_out     : out std_logic_vector(PC_WIDTH-1 downto 0);
            instr      : out std_logic_vector(INSTR_WIDTH-1 downto 0)
        );

    end component;

    signal clk, reset, stall, pcsrc : std_logic;
    signal pc_in, pc_out : std_logic_vector(PC_WIDTH-1 downto 0);
    signal instr : std_logic_vector(INSTR_WIDTH-1 downto 0);

    constant CLK_PERIOD : time := 20 ns;

begin

    UUT : fetch
    port map (
        clk => clk,
        reset => reset,
        stall => stall,
        pcsrc => pcsrc,
        pc_in => pc_in,
        pc_out => pc_out,
        instr => instr
    );

    clk_gen : process
    begin
        clk <= '1';
        wait for CLK_PERIOD/2;
        clk <= '0';
        wait for CLK_PERIOD/2;
    end process;

    test : process
    begin

        stall <= '0';
        pcsrc <= '0';
        pc_in <= "00100110101001";

        reset <= '0';
        wait for CLK_PERIOD;
        assert (unsigned(pc_out) = 0) report "pc_out: expected: 0x0 actual: 0x" & slv_to_hex(pc_out) severity error;
        reset <= '1'; 
        wait for CLK_PERIOD;
        assert (unsigned(pc_out) = 4) report "pc_out: expected: 0x4 actual: 0x" & slv_to_hex(pc_out) severity error;
        wait for CLK_PERIOD; 
        assert (unsigned(pc_out) = 8) report "pc_out: expected: 0x8 actual: 0x" & slv_to_hex(pc_out) severity error;
        stall <= '1';
        wait for CLK_PERIOD;  
        assert (unsigned(pc_out) = 8) report "pc_out: expected: 0x8 actual: 0x" & slv_to_hex(pc_out) severity error;
        stall <= '0'; 
        wait for CLK_PERIOD;
        assert (unsigned(pc_out) = 12) report "pc_out: expected: 0x12 actual: 0x" & slv_to_hex(pc_out) severity error;
        pcsrc <= '1';
        wait for CLK_PERIOD; 
        assert (unsigned(pc_out) = unsigned(pc_in)) report "pc_out: expected: 0x" & slv_to_hex(pc_in) & "  actual: 0x" & slv_to_hex(pc_out) severity error;
        pcsrc <= '0';
        wait for CLK_PERIOD;
        assert (unsigned(pc_out) = unsigned(pc_in)+4) report "pc_out: expected: 0x" & slv_to_hex(std_logic_vector(unsigned(pc_in)+4)) & "  actual: 0x" & slv_to_hex(pc_out) severity error;
    
    wait;
    end process;

end architecture;


