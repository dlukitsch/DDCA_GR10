library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.core_pack.all;
use work.op_pack.all;

entity ctrl is
	
	port (
            clk : in std_logic;
            reset : in std_logic;
            cop_op : in cop0_op_type; --from decode
            wrdata : in std_logic_vector(DATA_WIDTH-1 downto 0); --from decode exec_op.rddata
            pc : in std_logic_vector(PC_WIDTH-1 downto 0); --from decode pc_out
            pcsrc : in std_logic; --from mem
            exc_ovf : in std_logic; --from exec
            intr : in std_logic_vector(INTR_COUNT-1 downto 0);
            rddata : out std_logic_vector(DATA_WIDTH-1 downto 0); --to exec cop_rddata
            flush_decode : out std_logic;
            flush_exec : out std_logic;
            flush_mem : out std_logic
        );

end ctrl;

architecture rtl of ctrl is

    type reg_type is array(3 downto 0) of std_logic_vector(DATA_WIDTH-1 downto 0);
    signal cop_reg, cop_reg_next : reg_type := (others => x"00000000");
    constant STATUS : integer := 0;
    constant CAUSE : integer := 1;
    constant EPC : integer := 2;
    constant NPC : integer := 3;

    alias exc : std_logic_vector(3 downto 0) is cop_reg_next(CAUSE)(5 downto 2);
    alias pen : std_logic_vector(2 downto 0) is cop_reg_next(CAUSE)(12 downto 10);
    alias B : std_logic is cop_reg_next(CAUSE)(31);
    alias I : std_logic is cop_reg_next(STATUS)(0);

    signal cop0_op : cop0_op_type;

begin  -- rtl

    sync : process(all)
    begin

        if reset = '0' then
            cop_reg <= (others => x"00000000");
        elsif rising_edge(clk) then
            cop_reg <= cop_reg_next;
            cop0_op <= cop_op;
        end if;

    end process;

    output : process(all)
    begin

        flush_decode <= pcsrc;
        flush_exec <= pcsrc;
        flush_mem <= '0';

        cop_reg_next <= cop_reg;

        cop_reg_next(NPC)(PC_WIDTH-1 downto 0) <= pc;
        cop_reg_next(EPC) <= cop_reg(NPC);

        if exc_ovf = '1' then
            exc <= "1100";
            if pcsrc = '1' then --branch delay slot
                B <= '1';
            end if;

            flush_mem <= '1';
        end if;

        if intr /= "000" and I = '1' then
            exc <= "0000";
            pen <= intr; 
            if pcsrc = '1' then --branch delay slot
                B <= '1';
            end if;
            I <= '0'; --disable interrupts
        end if;

        if cop_op.wr = '1' then
            cop_reg_next(to_integer(signed(cop_op.addr))-12) <= wrdata;
        end if;

        if cop0_op.wr = '1' then
            cop_reg_next(to_integer(unsigned(cop0_op.addr))) <= wrdata;
        end if;

        rddata <= cop_reg(to_integer(unsigned(cop0_op.addr)));

    end process;    

end rtl;
