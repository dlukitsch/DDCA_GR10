library ieee;
use ieee.std_logic_1164.all;

use work.core_pack.all;
use work.op_pack.all;

entity pipeline is
	
	port (
		clk, reset : in	 std_logic;
		mem_in     : in  mem_in_type;
		mem_out    : out mem_out_type;
		intr       : in  std_logic_vector(INTR_COUNT-1 downto 0));

end pipeline;

architecture rtl of pipeline is
	
	component fetch is
	port (
		clk, reset : in	 std_logic;
		stall      : in  std_logic;
		pcsrc	   : in	 std_logic;
		pc_in	   : in	 std_logic_vector(PC_WIDTH-1 downto 0);
		pc_out	   : out std_logic_vector(PC_WIDTH-1 downto 0);
		instr	   : out std_logic_vector(INSTR_WIDTH-1 downto 0));

	end component;
	
	component decode is
	port (
		clk, reset : in  std_logic;
		stall      : in  std_logic;
		flush      : in  std_logic;
		pc_in      : in  std_logic_vector(PC_WIDTH-1 downto 0);
		instr	   : in  std_logic_vector(INSTR_WIDTH-1 downto 0);
		wraddr     : in  std_logic_vector(REG_BITS-1 downto 0);
		wrdata     : in  std_logic_vector(DATA_WIDTH-1 downto 0);
		regwrite   : in  std_logic;
		pc_out     : out std_logic_vector(PC_WIDTH-1 downto 0);
		exec_op    : out exec_op_type;
		cop0_op    : out cop0_op_type;
		jmp_op     : out jmp_op_type;
		mem_op     : out mem_op_type;
		wb_op      : out wb_op_type;
		exc_dec    : out std_logic);

	end component;
	
	component exec is
	port (
		clk, reset       : in  std_logic;
		stall      		 : in  std_logic;
		flush            : in  std_logic;
		pc_in            : in  std_logic_vector(PC_WIDTH-1 downto 0);
		op	   	         : in  exec_op_type;
		pc_out           : out std_logic_vector(PC_WIDTH-1 downto 0);
		rd, rs, rt       : out std_logic_vector(REG_BITS-1 downto 0);
		aluresult	     : out std_logic_vector(DATA_WIDTH-1 downto 0);
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
		exc_ovf          : out std_logic);

	end component;
	
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
		exc_store     : out std_logic);

	end component;
	
	component wb is
	port (
		clk, reset : in  std_logic;
		stall      : in  std_logic;
		flush      : in  std_logic;
		op	   : in  wb_op_type;
		rd_in      : in  std_logic_vector(REG_BITS-1 downto 0);
		aluresult  : in  std_logic_vector(DATA_WIDTH-1 downto 0);
		memresult  : in  std_logic_vector(DATA_WIDTH-1 downto 0);
		rd_out     : out std_logic_vector(REG_BITS-1 downto 0);
		result     : out std_logic_vector(DATA_WIDTH-1 downto 0);
		regwrite   : out std_logic);

	end component;
	
	signal pcsrc_fetch : std_logic;
	signal pc_in_fetch, pc_out_fetch : std_logic_vector(PC_WIDTH-1 downto 0);
	signal instr_fetch : std_logic_vector(INSTR_WIDTH-1 downto 0);
	
	signal wraddr_decode : std_logic_vector(REG_BITS-1 downto 0);
	signal wrdata_decode : std_logic_vector(DATA_WIDTH-1 downto 0);
	signal regwrite_decode : std_logic;
	signal pc_out_decode : std_logic_vector(PC_WIDTH-1 downto 0);
	signal exec_op_decode : exec_op_type;
	signal jmp_op_decode : jmp_op_type;
	signal mem_op_decode : mem_op_type;
	signal wb_op_decode : wb_op_type;
	
	signal pc_out_exec, new_pc_exec : std_logic_vector(PC_WIDTH-1 downto 0);
	signal rd_exec: std_logic_vector(REG_BITS-1 downto 0);
	signal aluresult_exec, wrdata_exec : std_logic_vector(DATA_WIDTH-1 downto 0);
	signal zero_exec, neg_exec : std_logic;
	signal memop_out_exec : mem_op_type; 
	signal jmpop_out_exec : jmp_op_type;
	signal wbop_out_exec : wb_op_type;
	
	signal rd_out_mem : std_logic_vector(REG_BITS-1 downto 0);
	signal aluresult_out_mem, memresult_mem : std_logic_vector(DATA_WIDTH-1 downto 0);
	signal wbop_out_mem : wb_op_type;
	
	signal reset_sync : std_logic := '1';
	signal stall_sync : std_logic := '0';
	
begin  -- rtl
	
	synchronizer : process(all)
	begin
		if rising_edge(clk) then
			reset_sync <= reset; -- get new data
			stall_sync <= mem_in.busy;
		end if;
	end process;
	
	fetch_inst : fetch
	port map(
		clk => clk,
		reset => reset_sync,
		--stall => stall_sync,
		stall => mem_in.busy,
		pcsrc => pcsrc_fetch,
		pc_in => pc_in_fetch,
		pc_out => pc_out_fetch,
		instr => instr_fetch
	);
	
	decode_inst : decode
	port map(
		clk => clk,
		reset => reset_sync,
		--stall => stall_sync,
	        stall => mem_in.busy,
		flush => '0', -- this pin has to be implemented at exercise 4
		pc_in => pc_out_fetch,
		instr => instr_fetch,
		wraddr => wraddr_decode,
		wrdata => wrdata_decode,
		regwrite => regwrite_decode,
		pc_out => pc_out_decode,
		exec_op => exec_op_decode,
		cop0_op => open, -- this pin has to be implemented at exercise 4
		jmp_op => jmp_op_decode,
		mem_op => mem_op_decode,
		wb_op => wb_op_decode,
		exc_dec => open -- this pin has to be implemented at exercise 4
	);
	
	exec_inst : exec
	port map(
		clk => clk,
		reset => reset_sync,
		--stall => stall_sync,
		stall => mem_in.busy,
		flush => '0', -- this pin has to be implemented at exercise 4
		pc_in => pc_out_decode,
		op => exec_op_decode,
		pc_out => pc_out_exec,
		rd => rd_exec,
		rs => open, -- this pin has to be implemented at exercise 4
		rt => open, -- this pin has to be implemented at exercise 4
		aluresult => aluresult_exec,
		wrdata => wrdata_exec,
		zero => zero_exec,
		neg => neg_exec,
		new_pc => new_pc_exec,
		memop_in => mem_op_decode,
		memop_out => memop_out_exec,
		jmpop_in => jmp_op_decode,
		jmpop_out => jmpop_out_exec,
		wbop_in => wb_op_decode,
		wbop_out => wbop_out_exec,
		forwardA => FWD_NONE, -- following pins have to be implemented at exercise 4
		forwardB => FWD_NONE,
		cop0_rddata => (others => '0'),
		mem_aluresult => (others => '0'),
		wb_result => (others => '0'),
		exc_ovf => open
	);
	
	mem_inst : mem
	port map (
		clk => clk,
		reset => reset_sync,
		--stall => stall_sync,
		stall => mem_in.busy,
		flush => '0', -- this pin has to be implemented at exercise 4
		mem_op => memop_out_exec,
		jmp_op => jmpop_out_exec,
		pc_in => pc_out_exec,
		rd_in => rd_exec,
		aluresult_in => aluresult_exec,
		wrdata => wrdata_exec,
		zero => zero_exec,
		neg => neg_exec,
		new_pc_in => new_pc_exec,
		pc_out => open, -- this pin has to be implemented at exercise 4
		pcsrc => pcsrc_fetch,
		rd_out => rd_out_mem,
		aluresult_out => aluresult_out_mem,
		memresult => memresult_mem,
		new_pc_out => pc_in_fetch,
		wbop_in => wbop_out_exec,
		wbop_out => wbop_out_mem,
		mem_out => mem_out,
		mem_data => mem_in.rddata,
		exc_load => open, -- following pins have to be implemented at exercise 4
		exc_store => open
	);
	
	wb_inst : wb
	port map (
		clk => clk,
		reset => reset_sync,
		--stall => stall_sync,
		stall => mem_in.busy,
		flush => '0', -- this pin has to be implemented at exercise 4
		op => wbop_out_mem,
		rd_in => rd_out_mem,
		aluresult => aluresult_out_mem,
		memresult => memresult_mem,
		rd_out => wraddr_decode,
		result => wrdata_decode,
		regwrite => regwrite_decode
	);
	
end rtl;
