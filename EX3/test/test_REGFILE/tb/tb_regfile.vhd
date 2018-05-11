library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.core_pack.all;
use work.op_pack.all;
use work.tb_util_pkg.all;

library std; -- for Printing
use std.textio.all;
use ieee.std_logic_textio.all;

entity tb_regfile is
end entity;

architecture bench of tb_regfile is

	component regfile is
		port (
		clk, reset       : in  std_logic;
		stall            : in  std_logic;
		rdaddr1, rdaddr2 : in  std_logic_vector(REG_BITS-1 downto 0);
		rddata1, rddata2 : out std_logic_vector(DATA_WIDTH-1 downto 0);
		wraddr			 : in  std_logic_vector(REG_BITS-1 downto 0);
		wrdata			 : in  std_logic_vector(DATA_WIDTH-1 downto 0);
		regwrite         : in  std_logic);
	end component;

	signal stall : std_logic;
	signal rdaddr1 : std_logic_vector(REG_BITS-1 downto 0);
	signal rdaddr2 : std_logic_vector(REG_BITS-1 downto 0);
	signal wraddr : std_logic_vector(REG_BITS-1 downto 0);
	signal wrdata : std_logic_vector(DATA_WIDTH-1 downto 0);
	signal regwrite : std_logic;

	signal rddata1 : std_logic_vector(DATA_WIDTH-1 downto 0);
	signal rddata2 : std_logic_vector(DATA_WIDTH-1 downto 0);

	signal clk : std_logic := '0';
	signal reset : std_logic := '1';
	
	constant CLK_PERIOD : time := 20 ns;
	
	file input_file : text;
	file output_ref_file : text;

	signal new_data : std_logic := '0';
	
	function bin_string_to_slv(s : string; width: integer) return std_logic_vector is
	variable value : std_logic_vector(width-1 downto 0);
	begin
		for i in s'length-1 downto 0  loop
			if s(s'high-i) = '1' then
				value(width-(i+1)) := '1';
			else
				value(width-(i+1)) := '0';
			end if;
		end loop;

		return value;
	end function;

	function bin_to_slv(s : string) return std_logic is
	begin
		if s(s'high) = '1' then
			return '1';
		end if;

		return '0';
	end function;

	function to_string ( a: std_logic_vector) return string is
	variable b : string (1 to a'length) := (others => NUL);
	variable stri : integer := 1; 
	begin
	    for i in a'range loop
	        b(stri) := std_logic'image(a((i)))(2);
	    stri := stri+1;
	    end loop;
	return b;
	end function;

begin
	uut : regfile
		port map
		(
			clk => clk,
			reset => reset,
			stall => stall,
			rdaddr1 => rdaddr1,
			rdaddr2 => rdaddr2,
			wraddr => wraddr,
			wrdata => wrdata,
			regwrite => regwrite,
			rddata1 => rddata1,
			rddata2 => rddata2
		);

	clk_gen : process
	begin
		clk <= '0';
		wait for CLK_PERIOD/2;
		clk <= '1';
		wait for CLK_PERIOD/2;
	end process;

	input : process
		-- file io related variables
		variable fstatus: file_open_status;
		variable l : line;
		variable cnt : integer := 0;
	begin
		-- open input file
		file_open(fstatus, input_file,"testdata/input.txt", READ_MODE);
		file_open(fstatus, output_ref_file,"testdata/output.txt", READ_MODE);

		rdaddr1 <= (others => '0');
		rdaddr2 <= (others => '0');
		wraddr <= (others => '0');
		wrdata <= (others => '0');
		regwrite <= '0';
		stall <= '0';

		while not endfile(input_file) loop
			readline(input_file, l); 
			
			--report "stimulus READ: " & l(l'low to l'high) severity note; --print line
			
			if( l(1) = '#' ) then --ignore comment lines 
				next;
			end if;
			stall <= bin_to_slv(l(1 to 1));
			rdaddr1 <= bin_string_to_slv(l(3 to 7),5);
			rdaddr2 <= bin_string_to_slv(l(9 to 13),5);
			wraddr <= bin_string_to_slv(l(15 to 19),5);
			wrdata <= bin_string_to_slv(l(21 to 52),32);
			regwrite <= bin_to_slv(l(54 to 54));

			wait for CLK_PERIOD;

			while not endfile(output_ref_file) loop
				readline(output_ref_file, l);
				cnt := cnt + 1;
				if( l(1) = '#' ) then --ignore comment lines 
					next;
				end if;
				exit;
			end loop;
			
			if (endfile(output_ref_file)) then --nothing left to read 
				exit;
			end if;
			
			--report "READ: " & character_temp severity note;
			assert (rddata1 = bin_string_to_slv(l(1 to 32),32)) report "Line " & integer'image(cnt) & ": rddata1 result " & to_string(rddata1) & " expected " & l(1 to 32) severity error;
			assert (rddata2 = bin_string_to_slv(l(34 to 65),32)) report "Line " & integer'image(cnt) & ": rddata2 result " & to_string(rddata2) & " expected " & l(34 to 65) severity error;
		end loop;
		
		wait;
	end process;

	

end architecture;