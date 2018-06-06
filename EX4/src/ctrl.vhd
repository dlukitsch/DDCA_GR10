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
            pc_in : in std_logic_vector(PC_WIDTH-1 downto 0); --from decode pc_out
            branch : in std_logic; --from mem
            exc_ovf : in std_logic; --from exec
            intr : in std_logic_vector(INTR_COUNT-1 downto 0);
            rddata : out std_logic_vector(DATA_WIDTH-1 downto 0); --to exec cop_rddata
            pcsrc : out std_logic; --to fetch
            pc_out : out std_logic_vector(PC_WIDTH-1 downto 0); --to fetch
            flush_decode : out std_logic;
            flush_exec : out std_logic;
            flush_mem : out std_logic
        );

end ctrl;

architecture rtl of ctrl is

    type COPROCESSOR_REGISTERS is record
        status : std_logic_vector(DATA_WIDTH-1 downto 0);
        cause : std_logic_vector(DATA_WIDTH-1 downto 0);
        epc : std_logic_vector(DATA_WIDTH-1 downto 0);
        npc : std_logic_vector(DATA_WIDTH-1 downto 0);
    end record;

    signal cop_reg, cop_reg_next : COPROCESSOR_REGISTERS;

    alias exc_next : std_logic_vector(3 downto 0) is cop_reg_next.cause(5 downto 2);
    alias pen_next : std_logic_vector(2 downto 0) is cop_reg_next.cause(12 downto 10);
    alias B_next : std_logic is cop_reg_next.cause(31);
    alias I : std_logic is cop_reg.status(0);
    alias I_next : std_logic is cop_reg_next.status(0);

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
        pcsrc <= '0';
        pc_out <= (others => '0');
        rddata <= (others => '0');

        --branch hazard resolution
        flush_decode <= branch;
        flush_exec <= branch;
        
        flush_mem <= '0';

        cop_reg_next <= cop_reg;

        cop_reg_next.npc(PC_WIDTH-1 downto 0) <= pc_in;
        cop_reg_next.epc <= cop_reg.npc;

        --ALU ovf detected
        if exc_ovf = '1' then
            exc_next <= "1100";
            if branch = '1' then --branch delay slot
                B_next <= '1';
            end if;
            --pcsrc <= '1';
            pc_out <= EXCEPTION_PC;
            flush_exec <= '1';
            flush_mem <= '1';
        end if;

        --interrupt detected
        if intr /= "000" and I = '1' then
            exc_next <= "0000";
            pen_next <= intr; 
            if branch = '1' then --branch delay slot
                B_next <= '1';
            end if;
            I_next <= '0'; --disable interrupts
            --pcsrc <= '1';
            pc_out <= EXCEPTION_PC;
            flush_exec <= '1';
            flush_mem <= '1';
        end if;

        --register io multiplex
        case cop0_op.addr is
            when "01100" =>
                if cop_op.wr = '1' then
                    cop_reg_next.status <= wrdata;
                end if;
                rddata <= cop_reg.status;
            when "01101" =>
                if cop_op.wr = '1' then
                    cop_reg_next.cause <= wrdata;
                end if;
                rddata <= cop_reg.cause;
            when "01110" =>
                if cop_op.wr = '1' then
                    cop_reg_next.epc <= wrdata;
                end if;
                rddata <= cop_reg.epc;
            when "01111" =>
                if cop_op.wr = '1' then
                    cop_reg_next.npc <= wrdata;
                end if;
                rddata <= cop_reg.npc;
            when others =>
        end case;

    end process;    

end rtl;
