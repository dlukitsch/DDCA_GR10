library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.core_pack.all;
use work.op_pack.all;
use work.tb_util_pkg.all;

library std; -- for Printing
use std.textio.all;
use ieee.std_logic_textio.all;

entity dec_exec_tb is
end entity;

architecture bench of dec_exec_tb is

        component decode is
            port (
                clk, reset : in  std_logic;
                stall      : in  std_logic;
                flush      : in  std_logic;
                pc_in      : in  std_logic_vector(PC_WIDTH-1 downto 0);
                instr      : in  std_logic_vector(INSTR_WIDTH-1 downto 0);
                wraddr     : in  std_logic_vector(REG_BITS-1 downto 0);
                wrdata     : in  std_logic_vector(DATA_WIDTH-1 downto 0);
                regwrite   : in  std_logic;
                pc_out     : out std_logic_vector(PC_WIDTH-1 downto 0);
                exec_op    : out exec_op_type;
                cop0_op    : out cop0_op_type;
                jmp_op     : out jmp_op_type;
                mem_op     : out mem_op_type;
                wb_op      : out wb_op_type;
                exc_dec    : out std_logic
            );
        end component;

        component exec is
            port (
                clk, reset       : in  std_logic;
                stall                    : in  std_logic;
                flush            : in  std_logic;
                pc_in            : in  std_logic_vector(PC_WIDTH-1 downto 0);
                op                       : in  exec_op_type;
                pc_out           : out std_logic_vector(PC_WIDTH-1 downto 0);
                rd, rs, rt       : out std_logic_vector(REG_BITS-1 downto 0);
                aluresult            : out std_logic_vector(DATA_WIDTH-1 downto 0);
                wrdata           : out std_logic_vector(DATA_WIDTH-1 downto 0);
                zero, neg        : out std_logic;
                new_pc           : out std_logic_vector(PC_WIDTH-1 downto 0);           
                memop_in         : in  mem_op_type;
                memop_out        : out mem_op_type;
                jmpop_in         : in  jmp_op_type;
                jmpop_out        : out jmp_op_type;
                wbop_in          : in  wb_op_type;
                wbop_out         : out wb_op_type;
                forwardA         : in  fwd_type;
                forwardB         : in  fwd_type;
                cop0_rddata      : in  std_logic_vector(DATA_WIDTH-1 downto 0);
                mem_aluresult    : in  std_logic_vector(DATA_WIDTH-1 downto 0);
                wb_result        : in  std_logic_vector(DATA_WIDTH-1 downto 0);
                exc_ovf          : out std_logic
            );
        end component;

	constant CLK_PERIOD : time := 20 ns;	
        
        signal clk, reset, stall, flush, regwrite : std_logic;
        signal pc_in, pc_out : std_logic_vector(PC_WIDTH-1 downto 0);
        signal instr : std_logic_vector(INSTR_WIDTH-1 downto 0);
        signal wraddr : std_logic_vector(REG_BITS-1 downto 0);
        signal wrdata : std_logic_vector(DATA_WIDTH-1 downto 0);
        signal exec_op : exec_op_type;       
        signal cop0_op : cop0_op_type;
        signal jmp_op : jmp_op_type;
        signal mem_op : mem_op_type;
        signal wb_op : wb_op_type;
 
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

        decode_inst : decode
        port map (
            clk => clk,
            reset => reset,
            stall => stall,
            flush => flush,
            pc_in => pc_in,
            instr => instr,     
            wraddr => wraddr,
            wrdata => wrdata,
            regwrite => regwrite,
            pc_out => pc_out,
            exec_op => exec_op,
            cop0_op => cop0_op,
            jmp_op => jmp_op,
            mem_op => mem_op,
            wb_op => wb_op,
            exc_dec => open
        );

        exec_inst : exec
        port map (
            clk => clk,
            reset => reset,
            stall => stall,
            flush => flush,
            pc_in => pc_out,
            op => exec_op,
            memop_in => mem_op,
            jmpop_in => jmp_op,
            wbop_in => wb_op,
            forwardA => FWD_NONE,
            forwardB => FWD_NONE,
            cop0_rddata => (others => '0'),
            mem_aluresult => (others => '0'),
            wb_result => (others => '0'),
            exc_ovf => open
        );

	stimulus : process

		-- file io related variables
		variable fstatus: file_open_status;
		variable l : line;

                variable pc_in_tmp : std_logic_vector(31 downto 0);
	begin
		-- open input file
		file_open(fstatus, input_file,"testdata/imem.mif", READ_MODE);	

                reset <= '0';
                stall <= '0';
                flush <= '0';
                pc_in <= (others => '0');
                instr <= (others => '0');
                wraddr <= (others => '0');
                wrdata <= (others => '0');
                regwrite <= '0';	
                wait for CLK_PERIOD;
                reset <= '1';
		
                while not endfile(input_file) loop
			readline(input_file, l); 	
			if( l(1) /= HT ) then --ignore non instruction lines 
				next;
			end if;
                        pc_in_tmp := hex_to_slv(l(2 to 9), 32);
                        pc_in <= std_logic_vector(unsigned(pc_in_tmp(13 downto 0))+4);
                        instr <= hex_to_slv(l(13 to 20), 32);
                        report "instr: 0x" & slv_to_hex(instr) severity note;
                        wait for CLK_PERIOD;
		end loop;
	
                file_close(input_file);
	
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
