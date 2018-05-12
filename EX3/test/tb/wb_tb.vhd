library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.core_pack.all;
use work.op_pack.all;
use work.tb_util_pkg.all;

library std; -- for Printing
use std.textio.all;
use ieee.std_logic_textio.all;

entity wb_tb is
end entity;

architecture bench of wb_tb is

	component wb is
	    port (
                clk, reset : in  std_logic;
                stall      : in  std_logic;
                flush      : in  std_logic;
                op         : in  wb_op_type;
                rd_in      : in  std_logic_vector(REG_BITS-1 downto 0);
                aluresult  : in  std_logic_vector(DATA_WIDTH-1 downto 0);
                memresult  : in  std_logic_vector(DATA_WIDTH-1 downto 0);
                rd_out     : out std_logic_vector(REG_BITS-1 downto 0);
                result     : out std_logic_vector(DATA_WIDTH-1 downto 0);
                regwrite   : out std_logic
            );
        end component;

	constant CLK_PERIOD : time := 20 ns;	
        
        signal clk, reset, stall, flush, regwrite : std_logic;
        signal rd_in, rd_out : std_logic_vector(REG_BITS-1 downto 0);
        signal aluresult, memresult, result : std_logic_vector(DATA_WIDTH-1 downto 0);
        signal op : wb_op_type; 

	file input_file : text;
	
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
	UUT : wb
	port map (
            clk => clk,
            reset => reset,
            stall => stall,
            flush => flush,
            op => op,
            rd_in => rd_in,
            aluresult => aluresult,
            memresult => memresult,
            rd_out => rd_out,
            result => result,
            regwrite => regwrite
        );

	stimulus : process

		-- file io related variables
		variable fstatus: file_open_status;
		variable inline : line;

                variable rd_in_tmp : std_logic_vector(7 downto 0);
	begin
		-- open input file
		file_open(fstatus, input_file,"testdata/input_wb.txt", READ_MODE);	

                reset <= '0';
                stall <= '0';
                flush <= '0';
                rd_in <= (others => '0');
                aluresult <= (others => '0');
                memresult <= (others => '0');	
                wait for CLK_PERIOD;
                reset <= '1';
	
                report "regwrite: " & std_logic'image(regwrite) & " rd_out: 0x" & slv_to_hex(rd_out) & " result: 0x" & slv_to_hex(result);
		
                while not endfile(input_file) loop
			readline(input_file, inline); 
			
			
			if( inline(1) = '#' ) then --ignore comment lines 
				report "COMMENT: " & inline(1 to inline'high);
                                next;
			end if;
			stall <= char_to_sl(inline(1));
			flush <= char_to_sl(inline(3));
                        op.memtoreg <= char_to_sl(inline(5));
                        op.regwrite <= char_to_sl(inline(7));
                        rd_in_tmp := hex_to_slv(inline(9 to 10), 8);
                        rd_in <= rd_in_tmp(4 downto 0);
                        aluresult <= hex_to_slv(inline(12 to 19), 32);
                        memresult <= hex_to_slv(inline(21 to 28), 32);
                        wait for CLK_PERIOD;
                        report "stall: " & inline(1) & " flush: " & inline(3) & " op.memtoreg: " & inline(5) & " op.regwrite: " & inline(7) & " rd_in: " & inline(9 to 10) & " aluresult: " & inline(12 to 19) & " memresult: " & inline(21 to 28); 
                        report "regwrite: " & std_logic'image(regwrite) & " rd_out: 0x" & slv_to_hex(rd_out) & " result: 0x" & slv_to_hex(result);
		end loop;
	
                file_close(input_file);
	
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
