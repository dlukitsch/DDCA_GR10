------------------------------------------------------
--Author: Jan Nausner <e01614835@student.tuwien.ac.at>
------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.core_pack.all;
use work.op_pack.all;

use work.tb_util_pkg.all;
use work.util_pkg.all;

entity memu_tb is
end entity;

architecture bench of memu_tb is
    
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

    signal op : mem_op_type;
    signal A : std_logic_vector(ADDR_WIDTH-1 downto 0);
    signal W, D, R : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal M : mem_out_type;
    signal XL, XS : std_logic;

    constant CLK_PERIOD : time := 20 ns;

begin

    UUT : memu
    port map (
        op => op,
        A => A,
        W => W,
        D => D,
        M => M,
        R => R,
        XL => XL,
        XS => XS
    );

    test : process
    begin

        op.memread <= '1';
        op.memwrite <= '1';
        op.memtype <= MEM_B;
        A <= "100000000000000000000";
        W <= x"ff00aa55"; 
        D <= x"55aa00ff";

        wait for CLK_PERIOD;
        
        assert (op.memread = M.rd) report "read: expected: " & std_logic'image(op.memread) & " actual: " & std_logic'image(M.rd) severity error; 
        
        assert (op.memwrite = M.wr) report "write: expected: " & std_logic'image(op.memwrite) & " actual: " & std_logic'image(M.wr) severity error; 

        assert (A = M.address) report "address: expected: 0x" & slv_to_hex(A) & " actual: 0x" & slv_to_hex(M.address) severity error; 

        assert (M.byteena = "1000") report "byteena: expected: 0x" & slv_to_hex("1000") & " actual: 0x" & slv_to_hex(M.byteena) severity error; 

        assert (M.wrdata(31 downto 24) = W(7 downto 0)) report "wrdata: expected: 0x" & slv_to_hex(W(7 downto 0)) & " actual: 0x" & slv_to_hex(M.wrdata(31 downto 24)) severity error;

        assert (R = padding(24, D(31)) & D(31 downto 24)) report "R: expected: 0x" & slv_to_hex(padding(24, D(31)) & D(31 downto 24)) & " actual: 0x" & slv_to_hex(R) severity error;

        assert (XL = '0') report "XL error" severity error;
        
        assert (XS = '0') report "XS error" severity error;

        A <= "100000000000000000001";
        
        wait for CLK_PERIOD;
 
        assert (A = M.address) report "address: expected: 0x" & slv_to_hex(A) & " actual: 0x" & slv_to_hex(M.address) severity error; 

        assert (M.byteena = "0100") report "byteena: expected: 0x" & slv_to_hex("0100") & " actual: 0x" & slv_to_hex(M.byteena) severity error; 

        assert (M.wrdata(23 downto 16) = W(7 downto 0)) report "wrdata: expected: 0x" & slv_to_hex(W(7 downto 0)) & " actual: 0x" & slv_to_hex(M.wrdata(23 downto 16)) severity error;

        assert (R = padding(24, D(23)) & D(23 downto 16)) report "R: expected: 0x" & slv_to_hex(padding(24, D(23)) & D(23 downto 16)) & " actual: 0x" & slv_to_hex(R) severity error;

        assert (XL = '0') report "XL error" severity error;
        
        assert (XS = '0') report "XS error" severity error;
        
        A <= "100000000000000000010";
        
        wait for CLK_PERIOD;
         
        assert (A = M.address) report "address: expected: 0x" & slv_to_hex(A) & " actual: 0x" & slv_to_hex(M.address) severity error; 

        assert (M.byteena = "0010") report "byteena: expected: 0x" & slv_to_hex("0010") & " actual: 0x" & slv_to_hex(M.byteena) severity error; 

        assert (M.wrdata(15 downto 8) = W(7 downto 0)) report "wrdata: expected: 0x" & slv_to_hex(W(7 downto 0)) & " actual: 0x" & slv_to_hex(M.wrdata(15 downto 8)) severity error;

        assert (R = padding(24, D(15)) & D(15 downto 8)) report "R: expected: 0x" & slv_to_hex(padding(24, D(15)) & D(15 downto 8)) & " actual: 0x" & slv_to_hex(R) severity error;

        assert (XL = '0') report "XL error" severity error;
        
        assert (XS = '0') report "XS error" severity error;
        
        A <= "100000000000000000011";
        
        wait for CLK_PERIOD;
         
        assert (A = M.address) report "address: expected: 0x" & slv_to_hex(A) & " actual: 0x" & slv_to_hex(M.address) severity error; 

        assert (M.byteena = "0001") report "byteena: expected: 0x" & slv_to_hex("0001") & " actual: 0x" & slv_to_hex(M.byteena) severity error; 

        assert (M.wrdata(7 downto 0) = W(7 downto 0)) report "wrdata: expected: 0x" & slv_to_hex(W(7 downto 0)) & " actual: 0x" & slv_to_hex(M.wrdata(7 downto 0)) severity error;

        assert (R = padding(24, D(7)) & D(7 downto 0)) report "R: expected: 0x" & slv_to_hex(padding(24, D(7)) & D(7 downto 0)) & " actual: 0x" & slv_to_hex(R) severity error;

        assert (XL = '0') report "XL error" severity error;
        
        assert (XS = '0') report "XS error" severity error;

        A <= "100000000000000000000";

        op.memtype <= MEM_H;

        wait for CLK_PERIOD;

        assert (M.byteena = "1100") report "byteena: expected: 0x" & slv_to_hex("1100") & " actual: 0x" & slv_to_hex(M.byteena) severity error; 

        assert (M.wrdata(31 downto 16) = W(15 downto 0)) report "wrdata: expected: 0x" & slv_to_hex(W(15 downto 0)) & " actual: 0x" & slv_to_hex(M.wrdata(31 downto 16)) severity error;

        assert (R = padding(16, D(31)) & D(31 downto 16)) report "R: expected: 0x" & slv_to_hex(padding(16, D(31)) & D(31 downto 16)) & " actual: 0x" & slv_to_hex(R) severity error;

        assert (XL = '0') report "XL error" severity error;
        
        assert (XS = '0') report "XS error" severity error;
        
        A <= "100000000000000000001";

        wait for CLK_PERIOD;

        assert (M.byteena = "1100") report "byteena: expected: 0x" & slv_to_hex("1100") & " actual: 0x" & slv_to_hex(M.byteena) severity error; 

        assert (M.wrdata(31 downto 16) = W(15 downto 0)) report "wrdata: expected: 0x" & slv_to_hex(W(15 downto 0)) & " actual: 0x" & slv_to_hex(M.wrdata(31 downto 16)) severity error;

        assert (R = padding(16, D(31)) & D(31 downto 16)) report "R: expected: 0x" & slv_to_hex(padding(16, D(31)) & D(31 downto 16)) & " actual: 0x" & slv_to_hex(R) severity error;

        assert (XL = '1') report "XL error" severity error;
        
        assert (XS = '1') report "XS error" severity error;
        
        assert (M.rd = '0') report "read error" severity error;
        
        assert (M.wr = '0') report "write error" severity error;

        A <= "100000000000000000010";

        wait for CLK_PERIOD;

        assert (M.byteena = "0011") report "byteena: expected: 0x" & slv_to_hex("0011") & " actual: 0x" & slv_to_hex(M.byteena) severity error; 

        assert (M.wrdata(15 downto 0) = W(15 downto 0)) report "wrdata: expected: 0x" & slv_to_hex(W(15 downto 0)) & " actual: 0x" & slv_to_hex(M.wrdata(15 downto 0)) severity error;

        assert (R = padding(16, D(15)) & D(15 downto 0)) report "R: expected: 0x" & slv_to_hex(padding(16, D(15)) & D(15 downto 0)) & " actual: 0x" & slv_to_hex(R) severity error;

        assert (XL = '0') report "XL error" severity error;
        
        assert (XS = '0') report "XS error" severity error;
        
        A <= "100000000000000000011";

        wait for CLK_PERIOD;

        assert (M.byteena = "0011") report "byteena: expected: 0x" & slv_to_hex("0011") & " actual: 0x" & slv_to_hex(M.byteena) severity error; 

        assert (M.wrdata(15 downto 0) = W(15 downto 0)) report "wrdata: expected: 0x" & slv_to_hex(W(15 downto 0)) & " actual: 0x" & slv_to_hex(M.wrdata(15 downto 0)) severity error;

        assert (R = padding(16, D(15)) & D(15 downto 0)) report "R: expected: 0x" & slv_to_hex(padding(16, D(15)) & D(15 downto 0)) & " actual: 0x" & slv_to_hex(R) severity error;

        assert (XL = '1') report "XL error" severity error;
        
        assert (XS = '1') report "XS error" severity error;
        
        assert (M.rd = '0') report "read error" severity error;
        
        assert (M.wr = '0') report "write error" severity error;
    
        A <= "100000000000000000000";

        op.memtype <= MEM_W;

        wait for CLK_PERIOD;

        assert (M.byteena = "1111") report "byteena: expected: 0x" & slv_to_hex("1111") & " actual: 0x" & slv_to_hex(M.byteena) severity error; 

        assert (M.wrdata = W) report "wrdata: expected: 0x" & slv_to_hex(W) & " actual: 0x" & slv_to_hex(M.wrdata) severity error;

        assert (R = D) report "R: expected: 0x" & slv_to_hex(D) & " actual: 0x" & slv_to_hex(R) severity error;

        assert (XL = '0') report "XL error" severity error;
        
        assert (XS = '0') report "XS error" severity error;
    
        A <= "100000000000000000001";

        wait for CLK_PERIOD;

        assert (M.byteena = "1111") report "byteena: expected: 0x" & slv_to_hex("1111") & " actual: 0x" & slv_to_hex(M.byteena) severity error; 

        assert (M.wrdata = W) report "wrdata: expected: 0x" & slv_to_hex(W) & " actual: 0x" & slv_to_hex(M.wrdata) severity error;

        assert (R = D) report "R: expected: 0x" & slv_to_hex(D) & " actual: 0x" & slv_to_hex(R) severity error;

        assert (XL = '1') report "XL error" severity error;
        
        assert (XS = '1') report "XS error" severity error;
        
        assert (M.rd = '0') report "read error" severity error;
        
        assert (M.wr = '0') report "write error" severity error;
    
        A <= "100000000000000000010";

        wait for CLK_PERIOD;

        assert (M.byteena = "1111") report "byteena: expected: 0x" & slv_to_hex("1111") & " actual: 0x" & slv_to_hex(M.byteena) severity error; 

        assert (M.wrdata = W) report "wrdata: expected: 0x" & slv_to_hex(W) & " actual: 0x" & slv_to_hex(M.wrdata) severity error;

        assert (R = D) report "R: expected: 0x" & slv_to_hex(D) & " actual: 0x" & slv_to_hex(R) severity error;

        assert (XL = '1') report "XL error" severity error;
        
        assert (XS = '1') report "XS error" severity error;
        
        assert (M.rd = '0') report "read error" severity error;
        
        assert (M.wr = '0') report "write error" severity error;

        A <= "100000000000000000011";

        wait for CLK_PERIOD;

        assert (M.byteena = "1111") report "byteena: expected: 0x" & slv_to_hex("1111") & " actual: 0x" & slv_to_hex(M.byteena) severity error; 

        assert (M.wrdata = W) report "wrdata: expected: 0x" & slv_to_hex(W) & " actual: 0x" & slv_to_hex(M.wrdata) severity error;

        assert (R = D) report "R: expected: 0x" & slv_to_hex(D) & " actual: 0x" & slv_to_hex(R) severity error;

        assert (XL = '1') report "XL error" severity error;
        
        assert (XS = '1') report "XS error" severity error;
        
        assert (M.rd = '0') report "read error" severity error;
        
        assert (M.wr = '0') report "write error" severity error;
    
    wait;
    end process;

end architecture;

