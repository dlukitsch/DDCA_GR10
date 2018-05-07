------------------------------------------------------
--Author: Jan Nausner <e01614835@student.tuwien.ac.at>
------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.core_pack.all;
use work.op_pack.all;

entity wb is
	
	port (
		clk, reset : in  std_logic;
		stall      : in  std_logic;
		flush      : in  std_logic;
		op	   	   : in  wb_op_type;
		rd_in      : in  std_logic_vector(REG_BITS-1 downto 0);
		aluresult  : in  std_logic_vector(DATA_WIDTH-1 downto 0);
		memresult  : in  std_logic_vector(DATA_WIDTH-1 downto 0);
		rd_out     : out std_logic_vector(REG_BITS-1 downto 0);
		result     : out std_logic_vector(DATA_WIDTH-1 downto 0);
		regwrite   : out std_logic);

end wb;

architecture rtl of wb is

    type WB_REGISTERS is record
        result   : std_logic_vector(DATA_WIDTH-1 downto 0);
        regwrite : std_logic;
        rd       : std_logic_vector(REG_BITS-1 downto 0); 
    end record;

    signal wb_reg, wb_reg_next : WB_REGISTERS;

begin  -- rtl

    sync : process(all)
    begin

        if reset = '0' then
            wb_reg.result <= (others => '0');
            wb_reg.regwrite <= '0';
            wb_reg.rd <= (others => '0');
        elsif rising_edge(clk) and stall = '0' then
            wb_reg <= wb_reg_next;
        end if;

    end process;

    output : process(all)
    begin

        wb_reg_next.regwrite <= op.regwrite;
        wb_reg_next.rd <= rd_in;

        if op.memtoreg = '1' then
            wb_reg_next.result <= memresult;
        else
            wb_reg_next.result <= aluresult;
        end if; 

        if flush = '1' then
            wb_reg_next.result <= (others => '0');
            wb_reg_next.regwrite <= '0';
            wb_reg_next.rd <= (others => '0');
        end if;

        result <= wb_reg.result;
        regwrite <= wb_reg.regwrite;
        rd_out <= wb_reg.rd;

    end process; 

end rtl;
