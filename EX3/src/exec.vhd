library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.core_pack.all;
use work.op_pack.all;

entity exec is
	
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

end exec;

architecture rtl of exec is
	component alu is
	port(
			op   : in  alu_op_type;
			A, B : in  std_logic_vector(DATA_WIDTH-1 downto 0);
			R    : out std_logic_vector(DATA_WIDTH-1 downto 0);
			Z    : out std_logic;
			V    : out std_logic
		);
	end component;

	signal exec_op : exec_op_type;
	signal exec_rd, exec_rs, exec_rt : std_logic_vector(REG_BITS-1 downto 0);

	type EXEC_TYPE is (MEM_OP, ALU_OP, COP_OP, NO_OP);
	signal state: EXEC_TYPE := NO_OP;

begin  -- rtl
	
	sync : process
	begin
		if reset = '0' then
			exec_op <= EXEC_NOP;

		elsif flush = '0' then
			exec_op <= EXEC_NOP; 

		elsif rising_edge(clk) then

			if stall = '0' then
				exec_op <= op;
				exec_rs <= op.rs;
				exec_rd <= op.rd;
				exec_rt <= op.rt;

				if op.cop0 = '1' then
					state <= COP_OP;
				else if then
					state <= ALU_OP;
				end if;
			end if;

		end if;
	end process;

	rs <= exec_rs;
	rd <= exec_rd;
	rt <= exec_rt;

	--pass throuch signals for assignment 4
	pc_out <= pc_in;
	memop_out <= memop_in;
	jmpop_out <= jmpop_in;
	wbop_out <= wbop_in;

	--instant of ALU-Unit
	alu_inst : alu
	port map(
		op => alu_op,
		A => alu_A,
		B => alu_B,
		R => alu_R,
		Z => alu_Z,
		V => alu_V
	);

	state_machine : process
	begin
		case state is
			when NO_OP =>

			when MEM_OP =>

			when ALU_OP =>
				alu_op <= exec_op.alu_op;
				aluresult <= alu_R;
				neg <= alu_R(DATA_WIDTH-1);
				zero <= alu_Z;
				
			when COP_OP =>
				aluresult <= cop0_rddata;
		end case;
	end process;

end rtl;
