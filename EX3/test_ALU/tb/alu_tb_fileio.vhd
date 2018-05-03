library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.core_pack.all;
use work.op_pack.all;
use work.tb_util_pkg.all;

library std; -- for Printing
use std.textio.all;
use ieee.std_logic_textio.all;

entity alu_tb_fileio is
end entity;

architecture bench of alu_tb_fileio is

	component alu is
		port (
			op   : in  alu_op_type;
			A, B : in  std_logic_vector(DATA_WIDTH-1 downto 0);
			R    : out std_logic_vector(DATA_WIDTH-1 downto 0);
			Z    : out std_logic;
			V    : out std_logic
			);
	end component;

	signal op : alu_op_type := ALU_NOP;
	signal A, B, R : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
	signal Z ,V : std_logic_vector(7 downto 0) := "00000000";
	signal new_data : std_logic := '0';
	signal clk : std_logic := '0';
	
	constant CLK_PERIOD : time := 20 ns;
	
	file input_file : text;
	file output_ref_file : text;
	
	function ascii_char_to_slv(c : character) return std_logic_vector is
	begin
		return std_logic_vector(to_unsigned(natural(character'pos(c)), 8));
	end function;
begin
	uut : alu
		port map
		(
			op => op,
			A => A,
			B => B,
			R => R,
			V => V(0),
			Z => Z(0)
		);

	stimulus : process

		-- file io related variables
		variable fstatus: file_open_status;
		variable l : line;
	begin
		-- open input file
		file_open(fstatus, input_file,"testdata/input.txt", READ_MODE);
		
		A <= (others=>'0');
		B <= (others=>'0');
		op <= ALU_NOP;
		new_data <= '0';
		
		while not endfile(input_file) loop
			readline(input_file, l); 
			
			--report "stimulus READ: " & l(l'low to l'high) severity note; --print line
			
			if( l(1) = '#' ) then --ignore comment lines 
				next;
			end if;
			op <= hex_to_op(l(1 to 1));
			A <= hex_to_slv(l(3 to 10), 32);
			B <= hex_to_slv(l(12 to 19), 32);
			new_data <= '1';
			wait for CLK_PERIOD;
			new_data <= '0';
			wait for CLK_PERIOD;
		end loop;
		
		wait;
	end process;


	check_output : process
		-- file io related variables
		variable fstatus: file_open_status;
		variable l : line;
		variable cnt : integer := 0;
		variable Z_char, V_char : character;
	begin 
		file_open(fstatus, output_ref_file,"testdata/output.txt", READ_MODE);
		
		loop
			loop
				wait until rising_edge(clk);
				if(new_data='1') then
					exit;
				end if;
			end loop;
			--read next reference character from file
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
			Z_char := l(10);
			V_char := l(12);
			assert (R = hex_to_slv(l(1 to 8), 32)) report "Line " & integer'image(cnt) & ": R calculated " & slv_to_hex(R) & " expected " & l(1 to 8) severity error;
			assert (Z = std_logic_vector(unsigned(ascii_char_to_slv(z_char)) - 48)) report "Line " & integer'image(cnt) & ": Z calculated " & slv_to_hex(Z(3 downto 0)) & " expected " & z_char severity error;
			assert (V = std_logic_vector(unsigned(ascii_char_to_slv(v_char)) - 48)) report "Line " & integer'image(cnt) & ": V calculated " & slv_to_hex(V(3 downto 0)) & " expected " & v_char severity error;

		end loop;
		
		--report "END" severity note;
		
		wait;
	end process;
	
	generate_clk : process
	begin
		clk <= '0';
		wait for CLK_PERIOD/2;
		clk <= '1';
		wait for CLK_PERIOD/2;
	end process;

end architecture;