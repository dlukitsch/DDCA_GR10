library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.core_pack.all;
use work.op_pack.all;

entity ctrl is
	
	port (
            clk : in std_logic;
            reset : in std_logic;
				stall : in std_logic;
            cop_op : in cop0_op_type; --from decode
            wrdata : in std_logic_vector(DATA_WIDTH-1 downto 0); --from exec
	    pc_in_fetch : in std_logic_vector(PC_WIDTH-1 downto 0);
		pc_in_dec : in std_logic_vector(PC_WIDTH-1 downto 0); --from decode pc_out
	    pc_in_exec : in std_logic_vector(PC_WIDTH-1 downto 0); --from exec pc_out
	    pc_in_mem : in std_logic_vector(PC_WIDTH-1 downto 0); --from mem pc_out
            bds : in std_logic; --from decode, exec_op.branch or exec_op.link
	    pcsrc_in : in std_logic; --from mem
            pc_branch : in std_logic_vector(PC_WIDTH-1 downto 0); --from mem new pc
            exc_ovf : in std_logic; --from exec
			dec_ovf : in std_logic;
            load_ovf : in std_logic;
			store_ovf : in std_logic;
			intr : in std_logic_vector(INTR_COUNT-1 downto 0);
            rddata : out std_logic_vector(DATA_WIDTH-1 downto 0); --to exec cop_rddata
            pcsrc_out : out std_logic; --to fetch
            pc_out : out std_logic_vector(PC_WIDTH-1 downto 0); --to fetch
            flush_decode : out std_logic;
            flush_exec : out std_logic;
            flush_mem : out std_logic;
			flush_wb : out std_logic
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
	 alias pen : std_logic_vector(2 downto 0) is cop_reg.cause(12 downto 10);
    alias B_next : std_logic is cop_reg_next.cause(31);
    alias I : std_logic is cop_reg.status(0);
    alias I_next : std_logic is cop_reg_next.status(0);

    signal cop_op_reg : cop0_op_type;
    signal bds_reg0, bds_reg1, bds_reg2, bds_reg3 : std_logic;
	 signal intr_reg : std_logic_vector(INTR_COUNT-1 downto 0);
	 signal intr_pend, pcsrc_in_reg0, pcsrc_in_reg1, exc_ovf_reg  : std_logic;
	 signal intr_pend_next, dec_ovf_reg, load_ovf_reg, store_ovf_reg : std_logic;
	 signal pc_branch_reg, pc_fetch_reg, pc_mem_reg, pc_mem_reg_old, pc_exec_reg, pc_dec_reg : std_logic_vector(PC_WIDTH-1 downto 0);
begin  -- rtl

    sync : process(all)
    begin

        if reset = '0' then
             cop_reg <= ((0 => '1', others => '0'), (others => '0'), (others => '0'), (others => '0'));
             cop_op_reg <= COP0_NOP;
             bds_reg0 <= '0';
             bds_reg1 <= '0';
			 bds_reg2 <= '0';
			 bds_reg3 <= '0';
             intr_reg <= (others => '0');
             intr_pend <= '0';
             pcsrc_in_reg0 <= '0';
			 pcsrc_in_reg1 <= '0';
			 dec_ovf_reg <= '0';
			 exc_ovf_reg <= '0';
             pc_branch_reg <= (others => '0');
			 pc_fetch_reg <= (others => '0');
			 pc_mem_reg <= (others => '0');
			 pc_mem_reg_old <= (others => '0');
			 pc_exec_reg <= (others => '0');
			 pc_dec_reg <= (others => '0');
			 load_ovf_reg <= '0';
			 store_ovf_reg <= '0';
        elsif rising_edge(clk) then
            if stall = '0' then
                    cop_reg <= cop_reg_next;
                    cop_op_reg <= cop_op;
					
                    bds_reg0 <= bds;
                    bds_reg1 <= bds_reg0;
					bds_reg2 <= bds_reg1;
					bds_reg3 <= bds_reg2;
					
                    pcsrc_in_reg0 <= pcsrc_in;
					pcsrc_in_reg1 <= pcsrc_in_reg0;
					pc_branch_reg <= pc_branch;
					pc_fetch_reg <= pc_in_fetch;
					pc_mem_reg_old <= pc_mem_reg;
					pc_mem_reg <= pc_in_mem;
					load_ovf_reg <= load_ovf;
					store_ovf_reg <= store_ovf;
					exc_ovf_reg <= exc_ovf;
					pc_exec_reg <= pc_in_exec;
					pc_dec_reg <= pc_in_dec;
					
					if dec_ovf = '1' nand pcsrc_in = '1' then -- stall decode-flag, so exception is not processed too early
						dec_ovf_reg <= dec_ovf;
					end if;
            end if;
           
            --don't drop interrupts on stall 
            if intr_pend = '0' then
                    intr_reg <= intr;
            end if;
            intr_pend <= intr_pend_next;        
        end if;

    end process;

    output : process(all)
    begin
        
        --normal branching
        pcsrc_out <= pcsrc_in;
        pc_out <= pc_branch; --new pc after branch

        rddata <= (others => '0');

        --branch hazard resolution
        flush_decode <= pcsrc_in;
        flush_exec <= pcsrc_in;
        flush_mem <= '0';
		flush_wb <= '0';
        
        cop_reg_next <= cop_reg;	
		  
        intr_pend_next <= '0';
        
        --set pend flag so interrupts are not dropped on stall    
        if intr /= "000" then
            intr_pend_next <= '1';
        end if;
	    	
        --register new interrupts and don't discard pending interrupts
        pen_next <= intr_reg or pen;
		
		if dec_ovf_reg = '1' then
			exc_next <= "1010";
			cop_reg_next.epc <= (others => '0');
            cop_reg_next.npc <= (others => '0');
            cop_reg_next.epc(PC_WIDTH-1 downto 0) <= pc_exec_reg;				
            cop_reg_next.npc(PC_WIDTH-1 downto 0) <= pc_dec_reg;
			if pcsrc_in = '1' then
                cop_reg_next.npc(PC_WIDTH-1 downto 0) <= pc_fetch_reg;
			end if;
			B_next <= bds_reg1; --branch delay slot
            I_next <= '0'; --disable interrupts
            pcsrc_out <= '1';
            pc_out <= EXCEPTION_PC;
            flush_decode <= '1';
            flush_exec <= '1';
            flush_mem <= '1';
			
        elsif exc_ovf_reg = '1' then --ALU ovf detected --changed to regitered values
            exc_next <= "1100";
            cop_reg_next.epc <= (others => '0');
            cop_reg_next.npc <= (others => '0');
            cop_reg_next.epc(PC_WIDTH-1 downto 0) <= pc_mem_reg;				
            cop_reg_next.npc(PC_WIDTH-1 downto 0) <= pc_exec_reg;
				
            if pcsrc_in_reg0 = '1' then
                cop_reg_next.npc(PC_WIDTH-1 downto 0) <= pc_branch_reg;
            end if;
				
            B_next <= bds_reg2; --branch delay slot
            I_next <= '0'; --disable interrupts
            pcsrc_out <= '1';
            pc_out <= EXCEPTION_PC;
            flush_decode <= '1';
            flush_exec <= '1';
            flush_mem <= '1';
			
		elsif store_ovf_reg = '1' or load_ovf_reg = '1' then
			if store_ovf_reg = '1' then
				exc_next <= "0101";
			else
				exc_next <= "0100";
			end if;
			
			cop_reg_next.epc <= (others => '0');
            cop_reg_next.npc <= (others => '0');
            cop_reg_next.epc(PC_WIDTH-1 downto 0) <= pc_mem_reg_old;				
            cop_reg_next.npc(PC_WIDTH-1 downto 0) <= pc_mem_reg;
			
			if pcsrc_in_reg1 = '1' then
                cop_reg_next.npc(PC_WIDTH-1 downto 0) <= pc_in_exec;
			end if;
			
			B_next <= bds_reg3; --branch delay slot
            I_next <= '0'; --disable interrupts
            pcsrc_out <= '1';
            pc_out <= EXCEPTION_PC;
            flush_decode <= '1';
            flush_exec <= '1';
            flush_mem <= '1';
			--flush_wb <= '1'; -- not sure about this but lets try
			
        elsif (intr_reg /= "000" or pen /= "000") and I = '1' then --interrupt detected, interrupt pipeline in decode stage, pc in exec points to instr in decode
            exc_next <= "0000";

            cop_reg_next.epc <= (others => '0');
            cop_reg_next.npc <= (others => '0');
            cop_reg_next.epc(PC_WIDTH-1 downto 0) <= pc_in_exec;
            cop_reg_next.npc(PC_WIDTH-1 downto 0) <= pc_in_exec;

            --take care of bds				
            if bds_reg0 = '1' then
                cop_reg_next.epc(PC_WIDTH-1 downto 0) <= pc_in_mem;
                cop_reg_next.npc(PC_WIDTH-1 downto 0) <= pc_in_mem;
            end if;
            --handle interrupts right after branches
            if pcsrc_in = '1' then
                cop_reg_next.npc(PC_WIDTH-1 downto 0) <= pc_branch;
                cop_reg_next.epc(PC_WIDTH-1 downto 0) <= pc_branch;
            end if;
            if pcsrc_in_reg0 = '1' then
                cop_reg_next.npc(PC_WIDTH-1 downto 0) <= pc_branch_reg;
                cop_reg_next.epc(PC_WIDTH-1 downto 0) <= pc_branch_reg;
            end if;
            
            B_next <= bds_reg0;				 
            I_next <= '0'; --disable interrupts
            pcsrc_out <= '1';
            pc_out <= EXCEPTION_PC;
            intr_pend_next <= '0';			
            flush_decode <= '1';
            flush_exec <= '1';
            flush_mem <= bds_reg0; --flush branch instruction

        else --take care of cop0 instrutions 
            case cop_op_reg.addr is --register io multiplex
                when "01100" =>
                    if cop_op_reg.wr = '1' then
                        cop_reg_next.status <= wrdata;
                    end if;
                    rddata <= cop_reg.status;
                when "01101" =>
                    if cop_op_reg.wr = '1' then
                        cop_reg_next.cause <= wrdata;
                    end if;
                    rddata <= cop_reg.cause;
                when "01110" =>
                    if cop_op_reg.wr = '1' then
                        cop_reg_next.epc <= wrdata;
                    end if;
                    rddata <= cop_reg.epc;
                when "01111" =>
                    if cop_op_reg.wr = '1' then
                        cop_reg_next.npc <= wrdata;
                    end if;
                    rddata <= cop_reg.npc;
                when others =>
            end case;
        end if;
    
    end process;    

end rtl;
