library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.core_pack.all;
use work.op_pack.all;

entity decode is
	
	port (
		clk, reset : in  std_logic;
		stall      : in  std_logic;
		flush      : in  std_logic;
		
		pc_in      : in  std_logic_vector(PC_WIDTH-1 downto 0);
		instr	     : in  std_logic_vector(INSTR_WIDTH-1 downto 0);
		
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

end decode;

architecture rtl of decode is
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
	
	procedure shift_imm(
		variable data_in  : in std_logic_vector(15 downto 0);
		signal data_out : out std_logic_vector(31 downto 0)
		) is
	begin
		if data_in(15) = '0' then --check for negative or positive value
			data_out(17 downto 0) <= data_in & "00"; -- sll 2 for 18 bit
		else
			data_out(31 downto 18) <= (others => '1');
			data_out(17 downto 0) <= data_in & "00";
		end if;
	end shift_imm;
	
	procedure calc_imm(
		variable data_in  : in std_logic_vector(15 downto 0);
		signal data_out : out std_logic_vector(31 downto 0)
		) is
	begin
		if data_in(15) = '0' then --check for negative or positive value
			data_out(15 downto 0) <= data_in;
		else
			data_out(31 downto 16) <= (others => '1');
			data_out(15 downto 0) <= data_in;
		end if;
	end calc_imm;
	
	signal rddata1, rddata2 : std_logic_vector(DATA_WIDTH-1 downto 0);
	signal rdaddr1, rdaddr2 : std_logic_vector(REG_BITS-1 downto 0);
	
	signal instr_next : std_logic_vector(INSTR_WIDTH-1 downto 0) := (others => '0');
	
begin  -- rtl

	regfile_inst : regfile
	port map (
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
	
	sync : process(all)
	begin
		if reset = '0' then
			-- insert NOPs
			instr_next <= (others => '0');
			pc_out <= (others => '0');
		elsif rising_edge(clk) then
                        if stall = '0' then
                            if flush = '0' then
                                instr_next <= instr;
                                pc_out <= pc_in;
                            else
                                instr_next <= (others => '0');
                                pc_out <= (others => '0');
                            end if;
                        end if;
		end if;
	end process;
	
	output : process(all)
		variable rs, rt, rd_r, rd_i, shamt : std_logic_vector(4 downto 0) := (others => '0');
		variable opcode, func : std_logic_vector(5 downto 0) := (others => '0');
		variable imm : std_logic_vector(15 downto 0) := (others => '0');
		variable address : std_logic_vector(25 downto 0) := (others => '0');
	begin
		opcode := instr_next(31 downto 26);
		rs := instr_next(25 downto 21);
		rt := instr_next(20 downto 16);
		rd_r := instr_next(15 downto 11);
		rd_i := instr_next(20 downto 16);
		shamt := instr_next(10 downto 6);
		func := instr_next(5 downto 0);
		imm := instr_next(15 downto 0);
		address := instr_next(25 downto 0);
		
		exec_op <= EXEC_NOP;
		cop0_op <= COP0_NOP;
		jmp_op <= JMP_NOP;
		mem_op <= MEM_NOP;
		wb_op <= WB_NOP;
		exc_dec <= '0'; --set all to std-value to avoid latches
		
		rdaddr1 <= instr(25 downto 21);
		rdaddr2 <= instr(20 downto 16);
		
		if instr_next = x"00000000" then
			exec_op <= EXEC_NOP;
			cop0_op <= COP0_NOP;
			jmp_op <= JMP_NOP;
			mem_op <= MEM_NOP;
			wb_op <= WB_NOP;
			exc_dec <= '0'; --set all to std-value to avoid latches
		else
			case opcode is
				when "000000" =>
					case func is
						when "000000" => --SLL
							exec_op.aluop <= ALU_SLL;
							exec_op.readdata2 <= rddata2;
							exec_op.readdata1(4 downto 0) <= shamt;
							exec_op.rt <= rt;
							exec_op.rd <= rd_r;
							exec_op.useamt <= '1';
							exec_op.regdst <= '1';
							wb_op.regwrite <= '1'; 
						when "000010" => --SRL
							exec_op.aluop <= ALU_SRL;
							exec_op.readdata2 <= rddata2;
							exec_op.readdata1(4 downto 0) <= shamt;
							exec_op.rt <= rt;
							exec_op.rd <= rd_r;
							exec_op.useamt <= '1';
							exec_op.regdst <= '1';
							wb_op.regwrite <= '1';
						when "000011" => --SRA
							exec_op.aluop <= ALU_SRA;
							exec_op.readdata2 <= rddata2;
							exec_op.readdata1(4 downto 0) <= shamt;
							exec_op.rt <= rt;
							exec_op.rd <= rd_r;
							exec_op.useamt <= '1';
							exec_op.regdst <= '1';
							wb_op.regwrite <= '1';
						when "000100" => --SLLV
							exec_op.aluop <= ALU_SLL;
							exec_op.readdata1(4 downto 0) <= rddata1(4 downto 0);
							exec_op.readdata2 <= rddata2;
							exec_op.rs <= rs;
							exec_op.rt <= rt;
							exec_op.rd <= rd_r;
							exec_op.regdst <= '1';
							wb_op.regwrite <= '1';
						when "000110" => --SRLV
							exec_op.aluop <= ALU_SRL;
							exec_op.readdata1(4 downto 0) <= rddata1(4 downto 0);
							exec_op.readdata2 <= rddata2;
							exec_op.rs <= rs;
							exec_op.rt <= rt;
							exec_op.rd <= rd_r;
							exec_op.regdst <= '1';
							wb_op.regwrite <= '1';
						when "000111" => --SRAV
							exec_op.aluop <= ALU_SRA;
							exec_op.readdata1(4 downto 0) <= rddata1(4 downto 0);
							exec_op.readdata2 <= rddata2;
							exec_op.rs <= rs;
							exec_op.rt <= rt;
							exec_op.rd <= rd_r;
							exec_op.regdst <= '1';
							wb_op.regwrite <= '1';
						when "001000" => --JR
							exec_op.aluop <= ALU_NOP;
							exec_op.readdata1 <= rddata1;
							exec_op.rs <= rs;
							exec_op.link <= '1';
							jmp_op <= JMP_JMP;
						when "001001" => --JALR
							exec_op.aluop <= ALU_NOP;
							exec_op.readdata1 <= rddata1;
							exec_op.rs <= rs;
							exec_op.rd <= rd_r;
							exec_op.regdst <= '1';
							exec_op.link <= '1';
							jmp_op <= JMP_JMP;
							wb_op.regwrite <= '1';
						when "100000" => --ADD
							exec_op.aluop <= ALU_ADD;
							exec_op.readdata1 <= rddata1;
							exec_op.readdata2 <= rddata2;
							exec_op.rs <= rs;
							exec_op.rt <= rt;
							exec_op.rd <= rd_r;
							exec_op.regdst <= '1';
							exec_op.ovf <= '1';
							wb_op.regwrite <= '1';
						when "100001" => --ADDU
							exec_op.aluop <= ALU_ADD;
							exec_op.readdata1 <= rddata1;
							exec_op.readdata2 <= rddata2;
							exec_op.rs <= rs;
							exec_op.rt <= rt;
							exec_op.rd <= rd_r;
							exec_op.regdst <= '1';
							wb_op.regwrite <= '1';
						when "100010" => --SUB
							exec_op.aluop <= ALU_SUB;
							exec_op.readdata1 <= rddata1;
							exec_op.readdata2 <= rddata2;
							exec_op.rs <= rs;
							exec_op.rt <= rt;
							exec_op.rd <= rd_r;
							exec_op.regdst <= '1';
							exec_op.ovf <= '1';
							wb_op.regwrite <= '1';
						when "100011" => --SUBU
							exec_op.aluop <= ALU_SUB;
							exec_op.readdata1 <= rddata1;
							exec_op.readdata2 <= rddata2;
							exec_op.rs <= rs;
							exec_op.rt <= rt;
							exec_op.rd <= rd_r;
							exec_op.regdst <= '1';
							wb_op.regwrite <= '1';
						when "100100" => --AND
							exec_op.aluop <= ALU_AND;
							exec_op.readdata1 <= rddata1;
							exec_op.readdata2 <= rddata2;
							exec_op.rs <= rs;
							exec_op.rt <= rt;
							exec_op.rd <= rd_r;
							exec_op.regdst <= '1';
							wb_op.regwrite <= '1';
						when "100101" => --OR
							exec_op.aluop <= ALU_OR;
							exec_op.readdata1 <= rddata1;
							exec_op.readdata2 <= rddata2;
							exec_op.rs <= rs;
							exec_op.rt <= rt;
							exec_op.rd <= rd_r;
							exec_op.regdst <= '1';
							wb_op.regwrite <= '1';
						when "100110" => --XOR
							exec_op.aluop <= ALU_XOR;
							exec_op.readdata1 <= rddata1;
							exec_op.readdata2 <= rddata2;
							exec_op.rs <= rs;
							exec_op.rt <= rt;
							exec_op.rd <= rd_r;
							exec_op.regdst <= '1';
							wb_op.regwrite <= '1';
						when "100111" => --NOR
							exec_op.aluop <= ALU_NOR;
							exec_op.readdata1 <= rddata1;
							exec_op.readdata2 <= rddata2;
							exec_op.rs <= rs;
							exec_op.rt <= rt;
							exec_op.rd <= rd_r;
							exec_op.regdst <= '1';
							wb_op.regwrite <= '1';
						when "101010" => --SLT
							exec_op.aluop <= ALU_SLT;
							exec_op.readdata1 <= rddata1;
							exec_op.readdata2 <= rddata2;
							exec_op.rs <= rs;
							exec_op.rt <= rt;
							exec_op.rd <= rd_r;
							exec_op.regdst <= '1';
							wb_op.regwrite <= '1';
						when "101011" => --SLTU
							exec_op.aluop <= ALU_SLTU;
							exec_op.readdata1 <= rddata1;
							exec_op.readdata2 <= rddata2;
							exec_op.rs <= rs;
							exec_op.rt <= rt;
							exec_op.rd <= rd_r;
							exec_op.regdst <= '1';
							wb_op.regwrite <= '1';
						when others =>
							exc_dec <= '1';
					end case;
				when "000001" =>
					case rd_i is
						when "00000" => --BLTZ -- not sure because of the pc + 4 from fetch stage
							exec_op.aluop <= ALU_NOP;
							exec_op.readdata1 <= rddata1;
							shift_imm(imm, exec_op.imm);
							exec_op.rs <= rs;
							exec_op.useimm <= '1';
							exec_op.branch <= '1';
							jmp_op <= JMP_BLTZ;
						when "00001" => --BGEZ
							exec_op.aluop <= ALU_NOP;
							exec_op.readdata1 <= rddata1;
							shift_imm(imm, exec_op.imm);
							exec_op.rs <= rs;
							exec_op.useimm <= '1';
							exec_op.branch <= '1';
							jmp_op <= JMP_BGEZ;
						when "10000" => --BLTZAL
							exec_op.aluop <= ALU_NOP;
							exec_op.readdata1 <= rddata1;
							exec_op.rd <= "11111"; --register 31 to store the pc to
							shift_imm(imm, exec_op.imm);
							exec_op.rs <= rs;
							exec_op.useimm <= '1';
							exec_op.branch <= '1';
							exec_op.regdst <= '1';
							jmp_op <= JMP_BLTZ;
							wb_op.regwrite <= '1';
						when "10001" => --BGEZAL
							exec_op.aluop <= ALU_NOP;
							exec_op.readdata1 <= rddata1;
							exec_op.rd <= "11111"; --register 31 to store the pc to
							shift_imm(imm, exec_op.imm);
							exec_op.rs <= rs;
							exec_op.useimm <= '1';
							exec_op.branch <= '1';
							exec_op.regdst <= '1';
							jmp_op <= JMP_BGEZ;
							wb_op.regwrite <= '1';
						when others =>
							exc_dec <= '1';
					end case;
				when "000010" => --J
					exec_op.aluop <= ALU_NOP;
					exec_op.readdata1(27 downto 0) <= address & "00";
					exec_op.link <= '1';
					jmp_op <= JMP_JMP;
				when "000011" => --JAL
					exec_op.aluop <= ALU_NOP;
					exec_op.readdata1(27 downto 0) <= address & "00";
					exec_op.link <= '1';
					exec_op.rd <= "11111"; --register 31 to store the pc to
					exec_op.regdst <= '1';
					jmp_op <= JMP_JMP;
					wb_op.regwrite <= '1';
				when "000100" => --BEQ
					exec_op.aluop <= ALU_SUB;
					exec_op.readdata1 <= rddata1;
					exec_op.readdata2 <= rddata2;
					shift_imm(imm, exec_op.imm);
					exec_op.rs <= rs;
					exec_op.rt <= rd_i;
					exec_op.useimm <= '1';
					exec_op.branch <= '1';
					jmp_op <= JMP_BEQ;
				when "000101" => --BNE
					exec_op.aluop <= ALU_SUB;
					exec_op.readdata1 <= rddata1;
					exec_op.readdata2 <= rddata2;
					shift_imm(imm, exec_op.imm);
					exec_op.rs <= rs;
					exec_op.rt <= rd_i;
					exec_op.useimm <= '1';
					exec_op.branch <= '1';
					jmp_op <= JMP_BNE;
				when "000110" => --BLEZ
					exec_op.aluop <= ALU_NOP;
					exec_op.readdata1 <= rddata1;
					shift_imm(imm, exec_op.imm);
					exec_op.rs <= rs;
					exec_op.useimm <= '1';
					exec_op.branch <= '1';
					jmp_op <= JMP_BLEZ;
				when "000111" => --BGTZ
					exec_op.aluop <= ALU_NOP;
					exec_op.readdata1 <= rddata1;
					shift_imm(imm, exec_op.imm);
					exec_op.rs <= rs;
					exec_op.useimm <= '1';
					exec_op.branch <= '1';
					jmp_op <= JMP_BGTZ;
				when "001000" => --ADDI
					exec_op.aluop <= ALU_ADD;
					exec_op.readdata1 <= rddata1;
					calc_imm(imm, exec_op.imm);
					exec_op.rd <= rd_i;
					exec_op.rs <= rs;
					exec_op.regdst <= '1';
					exec_op.useimm <= '1';
					exec_op.ovf <= '1';
					wb_op.regwrite <= '1';
				when "001001" => --ADDIU
					exec_op.aluop <= ALU_ADD;
					exec_op.readdata1 <= rddata1;
					calc_imm(imm, exec_op.imm);
					exec_op.rd <= rd_i;
					exec_op.rs <= rs;
					exec_op.regdst <= '1';
					exec_op.useimm <= '1';
					wb_op.regwrite <= '1';
				when "001010" => --SLTI
					exec_op.aluop <= ALU_SLT;
					exec_op.readdata1 <= rddata1;
					calc_imm(imm, exec_op.imm);
					exec_op.rd <= rd_i;
					exec_op.rs <= rs;
					exec_op.regdst <= '1';
					exec_op.useimm <= '1';
					wb_op.regwrite <= '1';
				when "001011" => --SLTIU
					exec_op.aluop <= ALU_SLTU;
					exec_op.readdata1 <= rddata1;
					exec_op.imm(15 downto 0) <= imm;
					exec_op.rd <= rd_i;
					exec_op.rs <= rs;
					exec_op.regdst <= '1';
					exec_op.useimm <= '1';
					wb_op.regwrite <= '1';
				when "001100" => --ANDI
					exec_op.aluop <= ALU_AND;
					exec_op.readdata1 <= rddata1;
					exec_op.imm(15 downto 0) <= imm;
					exec_op.rd <= rd_i;
					exec_op.rs <= rs;
					exec_op.regdst <= '1';
					exec_op.useimm <= '1';
					wb_op.regwrite <= '1';
				when "001101" => --ORI
					exec_op.aluop <= ALU_OR;
					exec_op.readdata1 <= rddata1;
					exec_op.imm(15 downto 0) <= imm;
					exec_op.rd <= rd_i;
					exec_op.rs <= rs;
					exec_op.regdst <= '1';
					exec_op.useimm <= '1';
					wb_op.regwrite <= '1';
				when "001110" => --XORI
					exec_op.aluop <= ALU_XOR;
					exec_op.readdata1 <= rddata1;
					exec_op.imm(15 downto 0) <= imm;
					exec_op.rd <= rd_i;
					exec_op.rs <= rs;
					exec_op.regdst <= '1';
					exec_op.useimm <= '1';
					wb_op.regwrite <= '1';
				when "001111" => --LUI
					exec_op.aluop <= ALU_LUI;
					exec_op.readdata2(15 downto 0) <= imm;
					exec_op.rd <= rd_i;
					exec_op.regdst <= '1';
					wb_op.regwrite <= '1';
				when "010000" =>
					case rs is  --> do not forget the forwarding !!!
						when "00000" => --MFC0
                                                    cop0_op.addr <= rd_r;
                                                    exec_op.rd <= rt;
                                                    exec_op.cop0 <= '1';
                                                    exec_op.regdst <= '1';
                                                    wb_op.regwrite <= '1';
						when "00100" => --MTC0
                                                    cop0_op.wr <= '1';
                                                    cop0_op.addr <= rd_r;
                                                    exec_op.readdata2 <= rddata2;
                                                    exec_op.rd <= rd_r;
						when others =>
						    exc_dec <= '1';
					end case;
				when "100000" => --LB
					exec_op.aluop <= ALU_ADD;
					exec_op.readdata1 <= rddata1;
					calc_imm(imm, exec_op.imm);
					exec_op.rd <= rd_i;
					exec_op.rs <= rs;
					exec_op.regdst <= '1';
					exec_op.useimm <= '1';
					wb_op.regwrite <= '1';
					wb_op.memtoreg <= '1';
					mem_op.memread <= '1';
					mem_op.memtype <= MEM_B;
				when "100001" => --LH
					exec_op.aluop <= ALU_ADD;
					exec_op.readdata1 <= rddata1;
					calc_imm(imm, exec_op.imm);
					exec_op.rd <= rd_i;
					exec_op.rs <= rs;
					exec_op.regdst <= '1';
					exec_op.useimm <= '1';
					wb_op.regwrite <= '1';
					wb_op.memtoreg <= '1';
					mem_op.memread <= '1';
					mem_op.memtype <= MEM_H;
				when "100011" => --LW
					exec_op.aluop <= ALU_ADD;
					exec_op.readdata1 <= rddata1;
					calc_imm(imm, exec_op.imm);
					exec_op.rd <= rd_i;
					exec_op.rs <= rs;
					exec_op.regdst <= '1';
					exec_op.useimm <= '1';
					wb_op.regwrite <= '1';
					wb_op.memtoreg <= '1';
					mem_op.memread <= '1';
					mem_op.memtype <= MEM_W;
				when "100100" => --LBU
					exec_op.aluop <= ALU_ADD;
					exec_op.readdata1 <= rddata1;
					calc_imm(imm, exec_op.imm);
					exec_op.rd <= rd_i;
					exec_op.rs <= rs;
					exec_op.regdst <= '1';
					exec_op.useimm <= '1';
					wb_op.regwrite <= '1';
					wb_op.memtoreg <= '1';
					mem_op.memread <= '1';
					mem_op.memtype <= MEM_BU;
				when "100101" => --LHU
					exec_op.aluop <= ALU_ADD;
					exec_op.readdata1 <= rddata1;
					calc_imm(imm, exec_op.imm);
					exec_op.rd <= rd_i;
					exec_op.rs <= rs;
					exec_op.regdst <= '1';
					exec_op.useimm <= '1';
					wb_op.regwrite <= '1';
					wb_op.memtoreg <= '1';
					mem_op.memread <= '1';
					mem_op.memtype <= MEM_HU;
				when "101000" => --SB
					exec_op.aluop <= ALU_ADD;
					exec_op.readdata1 <= rddata1;
					exec_op.readdata2(7 downto 0) <= rddata2(7 downto 0);
					calc_imm(imm, exec_op.imm);
					exec_op.rt <= rd_i;
					exec_op.rs <= rs;
					exec_op.useimm <= '1';
					mem_op.memwrite <= '1';
					mem_op.memtype <= MEM_B;
				when "101001" => --SH
					exec_op.aluop <= ALU_ADD;
					exec_op.readdata1 <= rddata1;
					exec_op.readdata2(15 downto 0) <= rddata2(15 downto 0);
					calc_imm(imm, exec_op.imm);
					exec_op.rt <= rd_i;
					exec_op.rs <= rs;
					exec_op.useimm <= '1';
					mem_op.memwrite <= '1';
					mem_op.memtype <= MEM_H;
				when "101011" => --SW
					exec_op.aluop <= ALU_ADD;
					exec_op.readdata1 <= rddata1;
					exec_op.readdata2 <= rddata2;
					calc_imm(imm, exec_op.imm);
					exec_op.rt <= rd_i;
					exec_op.rs <= rs;
					exec_op.useimm <= '1';
					mem_op.memwrite <= '1';
					mem_op.memtype <= MEM_W;
				when others =>
					exc_dec <= '1';
			end case;
		end if;
	end process;
	
end rtl;
