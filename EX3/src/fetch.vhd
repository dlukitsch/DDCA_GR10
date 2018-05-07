------------------------------------------------------
--Author: Jan Nausner <e01614835@student.tuwien.ac.at>
------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.core_pack.all;

entity fetch is
	
	port (
		clk, reset : in	 std_logic;
		stall      : in  std_logic;
		pcsrc	   : in	 std_logic;
		pc_in	   : in	 std_logic_vector(PC_WIDTH-1 downto 0);
		pc_out	   : out std_logic_vector(PC_WIDTH-1 downto 0);
		instr	   : out std_logic_vector(INSTR_WIDTH-1 downto 0));

end fetch;

architecture rtl of fetch is

    component imem_altera is
        port
        (
            address         : IN STD_LOGIC_VECTOR (11 DOWNTO 0);
            clock           : IN STD_LOGIC  := '1';
            q               : OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
        );
    end component;

    signal pc, pc_next : std_logic_vector(PC_WIDTH-1 downto 0);

begin  -- rtl

    imem : imem_altera
    port map (
        address => pc_next(PC_WIDTH-1 downto 2),
        clock => clk,
        q => instr
    );

    sync : process(all)
    begin

        if reset = '0' then
            pc <= (others => '0');
        elsif rising_edge(clk) and stall = '0' then
            pc <= pc_next;
        end if;

    end process;

    output : process(all)
    begin
        
        pc_next <= pc;
        pc_out <= pc_next;
        
        if pcsrc = '1' then
            pc_next <= pc_in;
        else
            pc_next <= std_logic_vector(unsigned(pc) + 4);
        end if;
        
        if reset = '0' then
            pc_next <= (others => '0');
        end if;

    end process; 

end rtl;
