library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.core_pack.all;
use work.tb_util_pkg.all;

library std; -- for Printing
use std.textio.all;
use ieee.std_logic_textio.all;

entity fetch_tb is
end entity;

architecture bench of fetch_tb is

	component fetch is
	    port (
                clk, reset : in  std_logic;
                stall      : in  std_logic;
                pcsrc      : in  std_logic;
                pc_in      : in  std_logic_vector(PC_WIDTH-1 downto 0);
                pc_out     : out std_logic_vector(PC_WIDTH-1 downto 0);
                instr      : out std_logic_vector(INSTR_WIDTH-1 downto 0)
            );
	end component;

	constant CLK_PERIOD : time := 20 ns;	
        
        signal clk, reset, stall, pcsrc : std_logic;
        signal pc_in, pc_out : std_logic_vector(PC_WIDTH-1 downto 0);
        signal instr : std_logic_vector(INSTR_WIDTH-1 downto 0);

	file input_file : text;
	file output_file : text;
	
	function ascii_char_to_slv(c : character) return std_logic_vector is
	begin
		return std_logic_vector(to_unsigned(natural(character'pos(c)), 8));
	end function;

        function char_to_sl(c : character) return std_logic is
            variable sl : std_logic;
        begin
            case c is
                when '0' => sl := '0';
                when '1' => sl := '1';
                when others => sl := '-';
            end case;
            return sl;
        end function;
begin
	UUT : fetch
	port map (
            clk => clk,
            reset => reset,
            stall => stall,
            pcsrc => pcsrc,
            pc_in => pc_in,
            pc_out => pc_out,
            instr => instr 
        );

	stimulus : process

		-- file io related variables
		variable fstatus: file_open_status;
		variable inline : line;
                --variable outline : line;

                variable pc_in_tmp : std_logic_vector(15 downto 0);
	begin
		-- open input file
		file_open(fstatus, input_file,"testdata/input_fetch.txt", READ_MODE);	
		--file_open(fstatus, output_file,"testdata/output_fetch.txt", WRITE_MODE);

                reset <= '0';
                stall <= '0';
                pcsrc <= '0';
                pc_in <= (others => '0');	
                wait for CLK_PERIOD;
                reset <= '1';
	
                report "pc_out: 0x" & slv_to_hex(pc_out) & " instr: 0x" & slv_to_hex(instr);
		
                while not endfile(input_file) loop
			readline(input_file, inline); 
			
			--report "stimulus READ: " & l(l'low to l'high) severity note; --print line
			
			if( inline(1) = '#' ) then --ignore comment lines 
				next;
			end if;
			stall <= char_to_sl(inline(1));
			pcsrc <= char_to_sl(inline(3));
                        pc_in_tmp := hex_to_slv(inline(5 to 8), 16);
                        pc_in <= pc_in_tmp(13 downto 0);
                        wait for CLK_PERIOD;
                        report "pc_out: 0x" & slv_to_hex(pc_out) & " instr: 0x" & slv_to_hex(instr);
                        --write(outline, slv_to_hex(pc_out));
                        --write(outline, " ");
                        --write(outline, slv_to_hex(instr));
                        --writeline(output_file, outline); 
		end loop;
	
                file_close(input_file);
                --file_close(output_file);
	
		wait;
	end process;


--	check_output : process
--		-- file io related variables
--		variable fstatus: file_open_status;
--		variable l : line;
--		variable cnt : integer := 0;
--		variable Z_char, V_char : character;
--	begin 
--		file_open(fstatus, output_ref_file,"testdata/output.txt", READ_MODE);
--		
--		loop
--			loop
--				wait until rising_edge(clk);
--				if(new_data='1') then
--					exit;
--				end if;
--			end loop;
--			--read next reference character from file
--			while not endfile(output_ref_file) loop
--				readline(output_ref_file, l);
--				cnt := cnt + 1;
--				if( l(1) = '#' ) then --ignore comment lines 
--					next;
--				end if;
--				exit;
--			end loop;
--			
--			if (endfile(output_ref_file)) then --nothing left to read 
--				exit;
--			end if;
--			
--			--report "READ: " & character_temp severity note;
--			Z_char := l(10);
--			V_char := l(12);
--			assert (R = hex_to_slv(l(1 to 8), 32)) report "Line " & integer'image(cnt) & ": R calculated " & slv_to_hex(R) & " expected " & l(1 to 8) severity error;
--			assert (Z = std_logic_vector(unsigned(ascii_char_to_slv(z_char)) - 48)) report "Line " & integer'image(cnt) & ": Z calculated " & slv_to_hex(Z(3 downto 0)) & " expected " & z_char severity error;
--			assert (V = std_logic_vector(unsigned(ascii_char_to_slv(v_char)) - 48)) report "Line " & integer'image(cnt) & ": V calculated " & slv_to_hex(V(3 downto 0)) & " expected " & v_char severity error;
--
--		end loop;
--		
--		--report "END" severity note;
--		
--		wait;
--	end process;
	
	generate_clk : process
	begin
		clk <= '0';
		wait for CLK_PERIOD/2;
		clk <= '1';
		wait for CLK_PERIOD/2;
	end process;

end architecture;
