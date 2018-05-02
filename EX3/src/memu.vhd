------------------------------------------------------
--Author: Jan Nausner <e01614835@student.tuwien.ac.at>
------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.core_pack.all;
use work.op_pack.all;
use work.util_pkg.all;

entity memu is
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
end memu;

architecture rtl of memu is

    constant HWORD_WIDTH : natural := 2*BYTE_WIDTH;
 
    signal WA, WB : std_logic_vector(BYTE_WIDTH-1 downto 0); 
    signal DA, DB, DC, DD : std_logic_vector(BYTE_WIDTH-1 downto 0);
    signal DAs, DBs, DCs, DDs : std_logic;

begin  -- rtl
    
    output : process(all)
    begin

        --lowest two bytes of W
        WA <= W(BYTE_WIDTH-1 downto 0);
        WB <= W(2*BYTE_WIDTH-1 downto BYTE_WIDTH);
        
        --all bytes of D, lowest to highest
        DA <= D(BYTE_WIDTH-1 downto 0);
        DB <= D(2*BYTE_WIDTH-1 downto BYTE_WIDTH);
        DC <= D(3*BYTE_WIDTH-1 downto 2*BYTE_WIDTH);
        DD <= D(4*BYTE_WIDTH-1 downto 3*BYTE_WIDTH);

        --sign bits
        DAs <= D(BYTE_WIDTH-1);
        DBs <= D(2*BYTE_WIDTH-1);
        DCs <= D(3*BYTE_WIDTH-1);
        DDs <= D(4*BYTE_WIDTH-1);

        M.address <= A;
        M.rd <= op.memread;
        M.wr <= op.memwrite;
        M.byteena <= (others => '0');
        M.wrdata <= (others => '0');
        R <= (others => '0');

        XL <= '0';
        XS <= '0';

        if op.memread = '1' and A = padding(ADDR_WIDTH, '0') then
            XL <= '1';
        end if;

        if op.memwrite = '1' and A = padding(ADDR_WIDTH, '0') then
            XS <= '1';
        end if;
        
        case op.memtype is

            when MEM_B =>
                case A(1 downto 0) is
                    when "00" =>
                        M.byteena <= "1000";
                        M.wrdata  <= WA & padding(3*BYTE_WIDTH, '0');
                        R         <= padding(3*BYTE_WIDTH, DDs) & DD;
                    when "01" =>
                        M.byteena <= "0100";
                        M.wrdata  <= padding(BYTE_WIDTH, '0') & WA & padding(2*BYTE_WIDTH, '0');
                        R         <= padding(3*BYTE_WIDTH, DCs) & DC;
                    when "10" =>
                        M.byteena <= "0010";
                        M.wrdata  <= padding(2*BYTE_WIDTH, '0') & WA & padding(BYTE_WIDTH, '0');
                        R         <= padding(3*BYTE_WIDTH, DBs) & DB;
                    when "11" =>
                        M.byteena <= "0001";
                        M.wrdata  <= padding(3*BYTE_WIDTH, '0') & WA;
                        R         <= padding(3*BYTE_WIDTH, DAs) & DA;
                    when others =>
                end case;

            when MEM_BU =>
                case A(1 downto 0) is
                    when "00" =>
                        M.byteena <= "1000";
                        M.wrdata  <= WA & padding(3*BYTE_WIDTH, '0');
                        R         <= padding(3*BYTE_WIDTH, '0') & DD;
                    when "01" =>
                        M.byteena <= "0100";
                        M.wrdata  <= padding(BYTE_WIDTH, '0') & WA & padding(2*BYTE_WIDTH, '0');
                        R         <= padding(3*BYTE_WIDTH, '0') & DC;
                    when "10" =>
                        M.byteena <= "0010";
                        M.wrdata  <= padding(2*BYTE_WIDTH, '0') & WA & padding(BYTE_WIDTH, '0');
                        R         <= padding(3*BYTE_WIDTH, '0') & DB;
                    when "11" =>
                        M.byteena <= "0001";
                        M.wrdata  <= padding(3*BYTE_WIDTH, '0') & WA;
                        R         <= padding(3*BYTE_WIDTH, '0') & DA;
                    when others =>
                end case;

            when MEM_H =>
                case A(1 downto 0) is
                    when "00" =>
                        M.byteena <= "1100";
                        M.wrdata  <= WB & WA & padding(HWORD_WIDTH, '0');
                        R         <= padding(HWORD_WIDTH, DDs) & DD & DC;
                    when "01" =>
                        M.byteena <= "1100";
                        M.wrdata  <= WB & WA & padding(HWORD_WIDTH, '0');
                        R         <= padding(HWORD_WIDTH, DDs) & DD & DC;
                        if op.memread = '1' then
                            XL <= '1';
                        end if;
                        if op.memwrite = '1' then
                            XS <= '1';
                        end if;
                    when "10" =>
                        M.byteena <= "0011";
                        M.wrdata  <= padding(HWORD_WIDTH, '0') & WB & WA;
                        R         <= padding(HWORD_WIDTH, DBs) & DB & DA;
                    when "11" =>
                        M.byteena <= "0011";
                        M.wrdata  <= padding(HWORD_WIDTH, '0') & WB & WA;
                        R         <= padding(HWORD_WIDTH, DBs) & DB & DA;
                        if op.memread = '1' then
                            XL <= '1';
                        end if;
                        if op.memwrite = '1' then
                            XS <= '1';
                        end if;
                    when others =>
                end case;
            
            when MEM_HU =>
                case A(1 downto 0) is
                    when "00" =>
                        M.byteena <= "1100";
                        M.wrdata  <= WB & WA & padding(HWORD_WIDTH, '0');
                        R         <= padding(HWORD_WIDTH, '0') & DD & DC;
                    when "01" =>
                        M.byteena <= "1100";
                        M.wrdata  <= WB & WA & padding(HWORD_WIDTH, '0');
                        R         <= padding(HWORD_WIDTH, '0') & DD & DC;
                        if op.memread = '1' then
                            XL <= '1';
                        end if;
                        if op.memwrite = '1' then
                            XS <= '1';
                        end if;
                    when "10" =>
                        M.byteena <= "0011";
                        M.wrdata  <= padding(HWORD_WIDTH, '0') & WB & WA;
                        R         <= padding(HWORD_WIDTH, '0') & DB & DA;
                    when "11" =>
                        M.byteena <= "0011";
                        M.wrdata  <= padding(HWORD_WIDTH, '0') & WB & WA;
                        R         <= padding(HWORD_WIDTH, '0') & DB & DA;
                        if op.memread = '1' then
                            XL <= '1';
                        end if;
                        if op.memwrite = '1' then
                            XS <= '1';
                        end if;
                    when others =>
                end case;

            when MEM_W =>
                M.byteena <= "1111";
                M.wrdata  <= W;
                R         <= D;
                if A(1 downto 0) = "01" or
                   A(1 downto 0) = "10" or
                   A(1 downto 0) = "11" then
                    if op.memread = '1' then
                         XL <= '1';
                    end if;
                    if op.memwrite = '1' then
                         XS <= '1';
                    end if;
                end if;

            when others =>
                    
        end case;

        --disable memory operations if exceptions occur
        if XL = '1' or XS = '1' then
            M.rd <= '0';
            M.wr <= '0';
        end if;

    end process;

end rtl;
