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

    component ocram_altera is
        PORT
        (
            address         : IN STD_LOGIC_VECTOR (9 DOWNTO 0);
            byteena         : IN STD_LOGIC_VECTOR (3 DOWNTO 0) :=  (OTHERS => '1');
            clock           : IN STD_LOGIC  := '1';
            data            : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
            wren            : IN STD_LOGIC ;
            q               : OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
        );
    end component;

    constant CLK_PERIOD : time := 20 ns;
    
    signal clk, reset, ocram_wr : std_logic;
    signal mem_in : mem_in_type;
    signal mem_out : mem_out_type;
    signal ocram_data : std_logic_vector(DATA_WIDTH-1 downto 0);

	type mux_type is (MUX_OCRAM, MUX_UART);
	signal mux : mux_type;

begin

    UUT : pipeline
    port map (
        clk => clk,
        reset => reset,
        mem_in => mem_in, --stall
        mem_out => mem_out,
        intr => (others => '0')
    );

    ram : ocram_altera
    port map (
        clock => clk,
        address => mem_out.address(11 downto 2),
        byteena => mem_out.byteena,
        data => mem_out.wrdata,
        wren => ocram_wr,
        q => ocram_data
    );

    mem_in.busy <= mem_out.rd;

    iomux : process(all)
    begin
        
        --mem_in.busy <= '0';
        mem_in.rddata <= (others => '0');
        ocram_wr <= '0';
        if mem_out.address(ADDR_WIDTH-1 downto ADDR_WIDTH-2) = "00" then
            mem_in.rddata <= ocram_data;
            ocram_wr <= mem_out.wr;
        end if;
 
    end process;

    stimulus : process
    begin
--        mem_in.busy <= '0';
--        mem_in.rddata <= (others => '0');
        reset <= '0';
        wait for 2*CLK_PERIOD;
        reset <= '1';
--        mem_in.rddata <= ocram_data;
--        mem_in.busy <= '1';
--        wait for 2*CLK_PERIOD;
--        mem_in.busy <= '0';
--        wait for 45.5*CLK_PERIOD;
--        mem_in.busy <= '1';
--        wait for 1*CLK_PERIOD;
--        mem_in.busy <= '0';
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

