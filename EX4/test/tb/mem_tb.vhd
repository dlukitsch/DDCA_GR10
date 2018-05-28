library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.core_pack.all;
use work.tb_util_pkg.all;

library std; -- for Printing
use std.textio.all;
use ieee.std_logic_textio.all;

entity mem_tb is
end entity;

architecture bench of mem_tb is

	component mem is
            port (
                clk, reset    : in  std_logic;
                stall         : in  std_logic;
                flush         : in  std_logic;
                mem_op        : in  mem_op_type;
                jmp_op        : in  jmp_op_type;
                pc_in         : in  std_logic_vector(PC_WIDTH-1 downto 0);
                rd_in         : in  std_logic_vector(REG_BITS-1 downto 0);
                aluresult_in  : in  std_logic_vector(DATA_WIDTH-1 downto 0);
                wrdata        : in  std_logic_vector(DATA_WIDTH-1 downto 0);
                zero, neg     : in  std_logic;
                new_pc_in     : in  std_logic_vector(PC_WIDTH-1 downto 0);
                pc_out        : out std_logic_vector(PC_WIDTH-1 downto 0);
                pcsrc         : out std_logic;
                rd_out        : out std_logic_vector(REG_BITS-1 downto 0);
                aluresult_out : out std_logic_vector(DATA_WIDTH-1 downto 0);
                memresult     : out std_logic_vector(DATA_WIDTH-1 downto 0);
                new_pc_out    : out std_logic_vector(PC_WIDTH-1 downto 0);
                wbop_in       : in  wb_op_type;
                wbop_out      : out wb_op_type;
                mem_out       : out mem_out_type;
                mem_data      : in  std_logic_vector(DATA_WIDTH-1 downto 0);
                exc_load      : out std_logic;
                exc_store     : out std_logic
            );
	end component;
	
        constant CLK_PERIOD : time := 20 ns;	
        
        signal clk, reset, stall, flush : std_logic;
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
	UUT : mem
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

                variable pc_in_tmp : std_logic_vector(15 downto 0);
	begin
		-- open input file
		file_open(fstatus, input_file,"testdata/input_fetch.txt", READ_MODE);	

                reset <= '0';
                stall <= '0';
                flush <= '0';
                pc_in <= (others => '0');	
                wait for CLK_PERIOD;
                reset <= '1';
	
                report "pc_out: 0x" & slv_to_hex(pc_out) & " instr: 0x" & slv_to_hex(instr);
		
                while not endfile(input_file) loop
			readline(input_file, inline); 
			
			
			if( inline(1) = '#' ) then --ignore comment lines 
				next;
			end if;
			stall <= char_to_sl(inline(1));
			pcsrc <= char_to_sl(inline(3));
                        pc_in_tmp := hex_to_slv(inline(5 to 8), 16);
                        pc_in <= pc_in_tmp(13 downto 0);
                        wait for CLK_PERIOD;
                        report "stall: " & inline(1) & " pcsrc: " & inline(3) & " pc_in: " & inline(5 to 8); 
                        report "pc_out: 0x" & slv_to_hex(pc_out) & " instr: 0x" & slv_to_hex(instr);
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
