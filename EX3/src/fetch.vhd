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

    type INTERNAL_REGISTERS is record
        pcsrc  : std_logic;
        pc_ext : std_logic_vector(PC_WIDTH-1 downto 0);
        pc     : std_logic_vector(PC_WIDTH-1 downto 0);
    end record;

    signal int_reg, int_reg_next : INTERNAL_REGISTERS;

begin  -- rtl

    imem : imem_altera
    port map (
        address => int_reg_next.pc(PC_WIDTH-1 downto 2),
        clock => clk,
        q => instr
    );

    sync : process(all)
    begin

        if reset = '0' then
            int_reg.pcsrc   <= '0';
            int_reg.pc_ext  <= (others => '0');
            int_reg.pc      <= (others => '0');
        elsif rising_edge(clk) and stall = '0' then
            int_reg <= int_reg_next;
        end if;

    end process;

    output : process(all)
    begin
      
        int_reg_next.pcsrc  <= pcsrc;  
        int_reg_next.pc_ext <= pc_in;
        pc_out <= int_reg.pc;
        
        if int_reg.pcsrc = '1' then
            int_reg_next.pc <= int_reg.pc_ext;
        else
            int_reg_next.pc <= std_logic_vector(unsigned(int_reg.pc) + 4);
        end if;
        
        if reset = '0' then
            int_reg_next.pc <= (others => '0');
        end if;

    end process; 

end rtl;
