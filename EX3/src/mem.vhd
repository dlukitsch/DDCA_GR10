------------------------------------------------------
--Author: Jan Nausner <e01614835@student.tuwien.ac.at>
------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.core_pack.all;
use work.op_pack.all;

entity mem is
	
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
		exc_store     : out std_logic);

end mem;

architecture rtl of mem is

    component jmpu is
        port (
            op   : in  jmp_op_type;
            N, Z : in  std_logic;
            J    : out std_logic);
    end component;

    component memu is
        port (
            op   : in  mem_op_type;
            A    : in  std_logic_vector(ADDR_WIDTH-1 downto 0);
            W    : in  std_logic_vector(DATA_WIDTH-1 downto 0);
            D    : in  std_logic_vector(DATA_WIDTH-1 downto 0);
            M    : out mem_out_type;
            R    : out std_logic_vector(DATA_WIDTH-1 downto 0);
            XL   : out std_logic;
            XS   : out std_logic
                );
    end component;

    type PASSTHROUGH_REGISTERS is record
        pc         : std_logic_vector(PC_WIDTH-1 downto 0);
        rd         : std_logic_vector(REG_BITS-1 downto 0); 
        aluresult  : std_logic_vector(DATA_WIDTH-1 downto 0);
        new_pc     : std_logic_vector(PC_WIDTH-1 downto 0);
        wbop       : wb_op_type;
    end record;

    type INTERNAL_REGISTERS is record
        mem_op     : mem_op_type;
        jmp_op     : jmp_op_type; 
        wrdata     : std_logic_vector(DATA_WIDTH-1 downto 0);
        zero       : std_logic;
        neg        : std_logic;
    end record;
    
    signal pt_reg, pt_reg_next : PASSTHROUGH_REGISTERS;
    signal int_reg, int_reg_next : INTERNAL_REGISTERS;
    signal memu_op : mem_op_type; 

begin -- rtl

    jump_unit : jmpu
    port map (
        op => int_reg.jmp_op,
        N => int_reg.neg,
        Z => int_reg.zero,
        J => pcsrc 
    );

    memory_unit : memu
    port map (
        op => memu_op,
        A => pt_reg.aluresult(ADDR_WIDTH-1 downto 0),
        W => int_reg.wrdata,
        D => mem_data,
        M => mem_out,
        R => memresult,
        XL => exc_load,
        XS => exc_store 
    );

    sync : process(all)
    begin

        if reset = '0' then
            pt_reg.pc <= (others => '0');
            pt_reg.rd <= (others => '0');
            pt_reg.aluresult <= (others => '0');
            pt_reg.new_pc <= (others => '0');
            pt_reg.wbop <= WB_NOP;
            int_reg.mem_op <= MEM_NOP;
            int_reg.jmp_op <= JMP_NOP;
            int_reg.wrdata <= (others => '0');
            int_reg.zero <= '0';
            int_reg.neg <= '0';
        elsif rising_edge(clk) then
            if stall = '0' then
                pt_reg <= pt_reg_next;
                int_reg <= int_reg_next;
		memu_op <= mem_op;
	    else --ensure that no memory operation is asserted on stall
		memu_op.memread <= '0'; 
		memu_op.memwrite <= '0';
		memu_op.memtype <= int_reg.mem_op.memtype; 
            end if;
        end if;

    end process;

    output : process(all)
    begin

        pt_reg_next.pc          <= pc_in;
        pt_reg_next.rd          <= rd_in;
        pt_reg_next.aluresult   <= aluresult_in;
        pt_reg_next.new_pc      <= new_pc_in;
        pt_reg_next.wbop        <= wbop_in;

        int_reg_next.mem_op <= mem_op;
        int_reg_next.jmp_op <= jmp_op;
        int_reg_next.wrdata <= wrdata;
        int_reg_next.zero <= zero;
        int_reg_next.neg <= neg;
        
        pc_out          <= pt_reg.pc;
        rd_out          <= pt_reg.rd;
        aluresult_out   <= pt_reg.aluresult;
        new_pc_out      <= pt_reg.new_pc;
        wbop_out        <= pt_reg.wbop;

        if flush = '1' then
            pt_reg_next.pc <= (others => '0');
            pt_reg_next.rd <= (others => '0');
            pt_reg_next.aluresult <= (others => '0');
            pt_reg_next.new_pc <= (others => '0');
            pt_reg_next.wbop <= WB_NOP;
        end if;

    end process;

end rtl;
