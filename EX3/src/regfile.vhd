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

SUBTYPE word is STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0);  
TYPE reg_type is ARRAY(0 to (2**REG_BITS)-1) OF word; 
signal registers : reg_type := (others=>(others=>'0'));

signal int_rdaddr1, int_rdaddr2 : std_logic_vector(REG_BITS-1 downto 0) := (others => '0');

begin  -- rtl

	process(clk)
	begin
		if reset = '0' then
			int_rdaddr1 <= (others => '0');
			int_rdaddr2 <= (others => '0');
		elsif rising_edge(clk) and stall = '0' then
			int_rdaddr1 <= rdaddr1;
			int_rdaddr2 <= rdaddr2;

			if rdaddr1 = wraddr or rdaddr2 = wraddr then
				if regwrite = '1' and (to_integer(unsigned(wraddr)) /= 0) then
					registers(to_integer(unsigned(wraddr))) <= wrdata;
				end if;
			end if;
		end if;
	end process;

	rddata1 <= registers(to_integer(unsigned(int_rdaddr1)));
	rddata2 <= registers(to_integer(unsigned(int_rdaddr2)));
end rtl;
