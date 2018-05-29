library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.core_pack.all;
use work.op_pack.all;

entity fwd is
	port (
		ex_rs : in std_logic_vector(REG_BITS-1 downto 0);
		ex_rt : in std_logic_vector(REG_BITS-1 downto 0);
		mem_rd : in std_logic_vector(REG_BITS-1 downto 0);
		wb_rd : in std_logic_vector(REG_BITS-1 downto 0);
		mem_regwrite : in std_logic;
		wb_regwrite : in std_logic;
		forwardA : out fwd_type;
		forwardB : out fwd_type
);
	
end fwd;

architecture rtl of fwd is

	constant zero : std_logic_vector(REG_BITS-1 downto 0) := (others => '0');
	
begin
	
	output : process(all)
	begin
		forwardA <= FWD_NONE;
		forwardB <= FWD_NONE;
		
		if mem_regwrite = '1' and mem_rd = ex_rs and mem_rd /= zero then
			forwardA <= FWD_ALU;
		elsif wb_regwrite = '1' and wb_rd = ex_rs and wb_rd /= zero then
			forwardA <= FWD_WB;
		end if;
		
		if mem_regwrite = '1' and  mem_rd = ex_rt and mem_rd /= zero then
			forwardB <= FWD_ALU;
		elsif wb_regwrite = '1' and wb_rd = ex_rt and wb_rd /= zero then
			forwardB <= FWD_WB;
		end if;
		
	end process;
	
end rtl;
