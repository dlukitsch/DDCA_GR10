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
		op	   : in  wb_op_type;
		rd_in      : in  std_logic_vector(REG_BITS-1 downto 0);
		aluresult  : in  std_logic_vector(DATA_WIDTH-1 downto 0);
		memresult  : in  std_logic_vector(DATA_WIDTH-1 downto 0);
		rd_out     : out std_logic_vector(REG_BITS-1 downto 0);
		result     : out std_logic_vector(DATA_WIDTH-1 downto 0);
		regwrite   : out std_logic);

end wb;

architecture rtl of wb is

    type WB_REGISTERS is record
        op        : wb_op_type;
        aluresult : std_logic_vector(DATA_WIDTH-1 downto 0);
        memresult : std_logic_vector(DATA_WIDTH-1 downto 0);
        rd        : std_logic_vector(REG_BITS-1 downto 0); 
    end record;

    signal wb_reg, wb_reg_next : WB_REGISTERS := (WB_NOP, (others => '0'), (others => '0'),(others => '0'));

begin  -- rtl

    sync : process(all)
    begin

        if reset = '0' then
            wb_reg <= (WB_NOP, (others => '0'), (others => '0'), (others => '0'));
        elsif rising_edge(clk) then
            if stall = '0' then
                if flush = '0' then
                    wb_reg <= wb_reg_next;
                else
                    wb_reg <= (WB_NOP, (others => '0'), (others => '0'), (others => '0'));
                end if;
            end if;
        end if;

    end process;

    output : process(all)
    begin

        wb_reg_next.op <= op;
        wb_reg_next.aluresult <= aluresult;
        wb_reg_next.memresult <= memresult;
        wb_reg_next.rd <= rd_in;

        --determine if result from alu or memory
        if wb_reg.op.memtoreg = '1' then
            result <= wb_reg.memresult;
        else
            result <= wb_reg.aluresult;
        end if; 

        regwrite <= wb_reg.op.regwrite;
        rd_out <= wb_reg.rd;

    end process; 

end rtl;
