------------------------------------------------------
--Author: Jan Nausner <e01614835@student.tuwien.ac.at>
------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.core_pack.all;
use work.op_pack.all;

entity memu is
	port (
		op   : in  mem_op_type;
		A    : in  std_logic_vector(ADDR_WIDTH-1 downto 0);
		W    : in  std_logic_vector(DATA_WIDTH-1 downto 0);
		D    : in  std_logic_vector(DATA_WIDTH-1 downto 0);
		M    : out mem_out_type;
		R    : out std_logic_vector(DATA_WIDTH-1 downto 0);
		XL   : out std_logic;
		XS   : out std_logic);
end memu;

architecture rtl of memu is

    constant BYTE : natural := 8;
    constant HWORD : natural := 2*BYTE;
    constant WORD : natural := 4*BYTE;
 
    signal WA, WB : std_logic_vector(BYTE-1 downto 0); 
    signal DA, DB, DC, DD : std_logic_vecotr(BYTE-1 downto 0);
    signal DAs, DBs, DCs, DDs : std_logic;

    function padding(size : natural;
                     val  : std_logic)
                    return std_logic_vector is
        variable padding : std_logic_vector(size-1 downto 0);
    begin
        for i in size-1 downto 0 loop
            padding(i) := val;
        end loop;
        return padding;
    end function;

begin  -- rtl
    
    output : process(all)

    begin

        WA <= W(7 downto 0);
        WB <= W(15 downto 9);
        
        DA <= D(7 downto 0);
        DB <= D(15 downto 8);
        DC <= D(23 downto 16);
        DD <= D(31 downto 24);

        DAs <= D(7);
        DBs <= D(15);
        DCs <= D(23);
        DDs <= D(31);

        M.address <= A;
        M.rd <= op.memread;
        M.wr <= op.memwrite;
        M.byteena <= (others => '0');
        M.wrdata <= (others => '0');
        R <= (others => '0');

        XL <= '0';
        XS <= '0';

        if A = padding(ADDR_WIDTH, '0') then
            XL <= op.memread;
        end if;

        if op.memwrite = '1' and A = padding(ADDR_WIDTH, '0') then
            XS <= op.memwrite;
        end if;
        
        case op.memtype is

            when MEM_B =>
                case A(1 downto 0) is
                    when "00" =>
                        M.byteena <= "1000";
                        M.wrdata  <= WA & padding(3*BYTE, '0');
                        R         <= padding(3*BYTE, DDs) & DD;
                    when "01" =>
                        M.byteena <= "0100";
                        M.wrdata  <= padding(BYTE, '0') & WA & padding(2*BYTE, '0');
                        R         <= padding(3*BYTE, DCs) & DC;
                    when "10" =>
                        M.byteena <= "0010";
                        M.wrdata  <= padding(2*BYTE, '0') & WA & padding(BYTE, '0');
                        R         <= padding(3*BYTE, DBs) & DB;
                    when "11" =>
                        M.byteena <= "0001";
                        M.wrdata  <= WA & padding(3*BYTE, '0');
                        R         <= padding(3*BYTE, DAs) & DA;
                    when others =>
                end case;

            when MEM_BU =>
                case A(1 downto 0) is
                    when "00" =>
                        M.byteena <= "1000";
                        M.wrdata  <= WA & padding(3*BYTE, '0');
                        R         <= padding(3*BYTE, '0') & DD;
                    when "01" =>
                        M.byteena <= "0100";
                        M.wrdata  <= padding(BYTE, '0') & WA & padding(2*BYTE, '0');
                        R         <= padding(3*BYTE, '0') & DC;
                    when "10" =>
                        M.byteena <= "0010";
                        M.wrdata  <= padding(2*BYTE, '0') & WA & padding(BYTE, '0');
                        R         <= padding(3*BYTE, '0') & DB;
                    when "11" =>
                        M.byteena <= "0001";
                        M.wrdata  <= WA & padding(3*BYTE, '0');
                        R         <= padding(3*BYTE, '0') & DA;
                    when others =>
                end case;

            when MEM_H =>
                case A(1 downto 0) is
                    when "00" =>
                        M.byteena <= "1100";
                        M.wrdata  <= WB & WA & padding(HWORD, '0');
                        R         <= padding(HWORD, DDs) & DD & DC;
                    when "01" =>
                        M.byteena <= "1100";
                        M.wrdata  <= WB & WA & padding(HWORD, '0');
                        R         <= padding(HWORD, DDs) & DD & DC;
                        XL        <= op.memread;
                        XS        <= op.memwrite;
                    when "10" =>
                        M.byteena <= "0011";
                        M.wrdata  <= padding(HWORD, '0') & WB & WA;
                        R         <= padding(HWORD, DBs) & DB & DA;
                    when "11" =>
                        M.byteena <= "0011";
                        M.wrdata  <= padding(HWORD, '0') & WB & WA;
                        R         <= padding(HWORD, DBs) & DB & DA;
                        XL        <= op.memread;
                        XS        <= op.memwrite;
                    when others =>
                end case;
            
            when MEM_HU =>
                case A(1 downto 0) is
                    when "00" =>
                        M.byteena <= "1100";
                        M.wrdata  <= WB & WA & padding(HWORD, '0');
                        R         <= padding(HWORD, '0') & DD & DC;
                    when "01" =>
                        M.byteena <= "1100";
                        M.wrdata  <= WB & WA & padding(HWORD, '0');
                        R         <= padding(HWORD, '0') & DD & DC;
                        XL        <= op.memread;
                        XS        <= op.memwrite;
                    when "10" =>
                        M.byteena <= "0011";
                        M.wrdata  <= padding(HWORD, '0') & WB & WA;
                        R         <= padding(HWORD, '0') & DB & DA;
                    when "11" =>
                        M.byteena <= "0011";
                        M.wrdata  <= padding(HWORD, '0') & WB & WA;
                        R         <= padding(HWORD, '0') & DB & DA;
                        XL        <= op.memread;
                        XS        <= op.memwrite;
                    when others =>
                end case;

            when MEM_W =>
                M.byteena <= "1111";
                M.wrdata  <= W;
                R         <= D;
                if A(1 downto 0) = "01" or
                   A(1 downto 0) = "10" or
                   A(1 downto 0) = "11" then
                    XL        <= op.memread;
                    XS        <= op.memwrite;
                end if;

            when others =>
                    
        end case;

    end process;

end rtl;
