library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.core_pack.all;

entity regfile is
	
	port (
		clk, reset       : in  std_logic;
		stall            : in  std_logic;
		rdaddr1, rdaddr2 : in  std_logic_vector(REG_BITS-1 downto 0);
		rddata1, rddata2 : out std_logic_vector(DATA_WIDTH-1 downto 0);
		wraddr			 : in  std_logic_vector(REG_BITS-1 downto 0);
		wrdata			 : in  std_logic_vector(DATA_WIDTH-1 downto 0);
		regwrite         : in  std_logic);

end regfile;

architecture rtl of regfile is
 
TYPE reg_type is ARRAY(0 to (2**REG_BITS)-1) OF STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0); 
signal registers : reg_type;

begin  -- rtl

	registers(0) <= (others => '0');

	process(clk)
	begin
		if reset = '0' then
			rddata1 <= (others => '0');
			rddata2 <= (others => '0');
		elsif rising_edge(clk) and stall = '0' then
			if regwrite = '1' and to_integer(unsigned(wraddr))/=0 then
			  registers(to_integer(unsigned(wraddr))) <= wrdata;
			end if;
			if rdaddr1 = wraddr and regwrite = '1' then
			  rddata1 <= wrdata;
			  rddata2 <= registers(to_integer(unsigned(rdaddr2)));
			elsif rdaddr2 = wraddr and regwrite = '1' then
			  rddata1 <= registers(to_integer(unsigned(rdaddr1)));
			  rddata2 <= wrdata;
			else
			  rddata1 <= registers(to_integer(unsigned(rdaddr1)));
			  rddata2 <= registers(to_integer(unsigned(rdaddr2)));
			end if;
		end if;
	end process;
end rtl;
