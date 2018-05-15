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
	signal exec_rd : std_logic_vector(REG_BITS-1 downto 0) := (others => '0');
	signal exec_rs : std_logic_vector(REG_BITS-1 downto 0) := (others => '0');
	signal exec_rt : std_logic_vector(REG_BITS-1 downto 0) := (others => '0');
	signal exec_pc : std_logic_vector(PC_WIDTH-1 downto 0) := (others => '0');
	signal exec_mem : mem_op_type;
	signal exec_wb : wb_op_type;
	signal exec_jmp : jmp_op_type;

	type EXEC_TYPE is (ALU_OP, COP_OP, NO_OP);
	signal state: EXEC_TYPE := NO_OP;

	signal aluop : alu_op_type;
	signal alu_A : std_logic_vector(DATA_WIDTH-1 downto 0);
	signal alu_B : std_logic_vector(DATA_WIDTH-1 downto 0);
	signal alu_R : std_logic_vector(DATA_WIDTH-1 downto 0);
	signal alu_Z : std_logic;
	signal alu_V : std_logic;

	signal result : std_logic_vector(DATA_WIDTH-1 downto 0);

begin  -- rtl
	
	sync : process(all)
	begin
		if reset = '0' or flush = '1' then
			exec_op <= EXEC_NOP;
			state <= NO_OP;

		elsif rising_edge(clk) then

			if stall = '0' then
				exec_op <= op;
				exec_rs <= op.rs;
				exec_rd <= op.rd;
				exec_rt <= op.rt;

				if op.cop0 = '1' then
					state <= COP_OP;
				else 
					state <= ALU_OP;
				end if;

				--pass signals for assignment 4
				exec_pc <= pc_in;
				exec_mem <= memop_in;
				exec_jmp <= jmpop_in;
				exec_wb <= wbop_in;
			end if;
		end if;
	end process;

	rs <= exec_rs;
	rd <= exec_rd;
	rt <= exec_rt;

	pc_out <= exec_pc;
	memop_out <= exec_mem;
	wbop_out <= exec_wb;
	jmpop_out <= exec_jmp;

	--instant of ALU-Unit
	alu_inst : alu
	port map(
		op => aluop,
		A => alu_A,
		B => alu_B,
		R => alu_R,
		Z => alu_Z,
		V => alu_V
	);

	state_machine : process(all)
	begin
		aluresult <= (others => '0');
		wrdata <= (others => '0');
		neg <= '0';
		zero <= '0';
		new_pc <= (others => '0');
		aluop <= ALU_NOP;
		exc_ovf <= '0';
		alu_A <= (others => '0');
		alu_B <= (others => '0');
		
		case state is
			when NO_OP =>
				-- no operation use init values for nop
			when ALU_OP =>
				aluop <= exec_op.aluop;

				if exec_op.ovf = '1' and alu_V = '1' then
					exc_ovf <= '1';
				else
					exc_ovf <= '0';
				end if;

				if exec_op.branch = '1' then
					alu_A <= exec_op.readdata1;
					alu_B <= exec_op.readdata2;
					new_pc <= std_logic_vector(signed(exec_pc) + signed(exec_op.imm(PC_WIDTH-1 downto 0)));

					if exec_op.regdst = '1' then
						result <= exec_op.readdata2;
					end if;

				elsif exec_op.link = '1' then
					new_pc <= exec_pc;

					if exec_op.regdst = '1' then
						alu_A <= exec_op.readdata2;
						result <= alu_R;
					end if;

				else
					if exec_op.useimm = '1' then
						alu_A <= exec_op.readdata1;
						alu_B <= exec_op.imm;
					else
						alu_A <= exec_op.readdata1;
						alu_B <= exec_op.readdata2;
					end if;

					result <= alu_R;

					if exec_op.regdst = '0' then
						wrdata <= alu_R;
					end if;
				end if;
				
				aluresult <= result;
				zero <= alu_Z;
				neg <= alu_R(DATA_WIDTH-1);
				
			when COP_OP =>
				aluresult <= cop0_rddata;
		end case;
	end process;

end rtl;
