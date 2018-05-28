library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.core_pack.all;
use work.op_pack.all;

entity alu is
	port (
		op   : in  alu_op_type;
		A, B : in  std_logic_vector(DATA_WIDTH-1 downto 0);
		R    : out std_logic_vector(DATA_WIDTH-1 downto 0);
		Z    : out std_logic;
		V    : out std_logic);

end alu;

architecture rtl of alu is

begin  -- rtl

	process(op, A, B)
	variable R_temp : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
	begin
		case op is
			when ALU_NOP =>
				R_temp := A;
			when ALU_SLT =>
				if signed(A) < signed(B) then
					R_temp := (0 => '1', others => '0');
				else
					R_temp := (others => '0');
				end if;
			when ALU_SLTU =>
				if unsigned(A) < unsigned(B) then
					R_temp := (0 => '1', others => '0'); 
				else
					R_temp := (others => '0');
				end if;
			when ALU_SLL =>
				R_temp := std_logic_vector(unsigned(B) sll to_integer(unsigned(A(DATA_WIDTH_BITS-1 downto 0))));
			when ALU_SRL =>
				R_temp := std_logic_vector(unsigned(B) srl to_integer(unsigned(A(DATA_WIDTH_BITS-1 downto 0))));
			when ALU_SRA =>
				R_temp := to_stdlogicvector(to_bitvector(B) sra to_integer(unsigned(A(DATA_WIDTH_BITS-1 downto 0))));
			when ALU_ADD =>
				R_temp := std_logic_vector(signed(A) + signed(B));
			when ALU_SUB =>
				R_temp := std_logic_vector(signed(A) - signed(B));
			when ALU_AND =>
				R_temp := A and B; 
			when ALU_OR =>
				R_temp := A or B;
			when ALU_XOR =>
				R_temp := A xor B;
			when ALU_NOR =>
				R_temp := not (A or B);
			when ALU_LUI =>
				R_temp := std_logic_vector(unsigned(B) sll 16);
			when others =>
				R_temp := A;
		end case;
		
		if (op = ALU_SUB and A = B) or (op /= ALU_SUB and unsigned(A) = 0) then
			Z <= '1';
		else
			Z <= '0';
		end if;
		
		if (op = ALU_ADD and signed(A) >= 0 and signed(B) >= 0 and signed(R_temp) < 0) then
			V <= '1';
		elsif (op = ALU_ADD and signed(A) < 0 and signed(B) < 0 and signed(R_temp) >= 0) then
			V <= '1';
		elsif (op = ALU_SUB and signed(A) >= 0 and signed(B) < 0 and signed(R_temp) < 0) then
			v <= '1';
		elsif (op = ALU_SUB and signed(A) < 0 and signed(B) >= 0 and signed(R_temp) >= 0) then
			v <= '1';
		else
			V <= '0';
		end if;
		R <= R_temp;
	end process;

end rtl;
