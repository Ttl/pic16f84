library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.picpkg.all;
use IEEE.NUMERIC_STD.ALL;

-- Decocing unit. Outputs control signals for datapath control.

entity decoder is
    Port ( instr : in  STD_LOGIC_VECTOR(13 downto 0);
           bmux, rwmux, branch, writew, skip, retrn : out  STD_LOGIC;
           pc_push : out STD_LOGIC;
           amux : out std_logic_vector(1 downto 0);
           aluop : out  alu_ctrl;
           status_write : out std_logic_vector(4 downto 0);
           retfie : out std_logic);
end decoder;

architecture Behavioral of decoder is
begin

process(instr)
variable opcode : std_logic_vector(5 downto 0);
-- ALU A mux: 00 : instr, 01 : ram ,10 : 0, 11 : 1
variable alu_mux : std_logic_vector(1 downto 0);
-- ALU B mux: 0 : W, 1 : 1
variable alub_mux, ram_write, branch_mux, writew_en, pc_return : std_logic;
variable call : std_logic;
variable alu_op : alu_ctrl;
variable wf_bit : std_logic; -- W = 0, F = 1
variable file_reg : std_logic_vector(6 downto 0);
variable imm : std_logic_vector(7 downto 0);
variable skip_next : std_logic; -- '1' for conditional skip
variable z_write, dc_write, c_write, to_write, pd_write : std_logic;
begin
opcode := instr(13 downto 8);
wf_bit := instr(7); --0 = W, 1 = f
file_reg := instr(6 downto 0);
imm := instr(7 downto 0);

retfie <= '0';
alu_mux := "00";
alub_mux := '0';
ram_write := '0';
branch_mux := '0';
writew_en := '0';
alu_op := A_PASSA;
skip_next := '0';
pc_return := '0';
call := '0';

-- Status register update flags
z_write := '0';
c_write := '0';
dc_write := '0';
to_write := '0';
pd_write := '0';

case opcode is
    
    --addwf f,d
    when "000111" =>
        alu_mux := "01"; -- ram
        writew_en := not wf_bit;
        ram_write := wf_bit;
        alu_op := A_ADD;
        c_write := '1';
        dc_write := '1';
        z_write := '1';
        
    
    -- andwf f,d
    when "000101" =>
        alu_mux := "01"; -- ram
        writew_en := not wf_bit;
        ram_write := wf_bit;
        alu_op := A_AND;
        z_write := '1';
    
    -- clrf f/clrw -
    when "000001" =>
        alu_mux := "10"; -- 0
        writew_en := not wf_bit;
        ram_write := wf_bit;
        alu_op := A_PASSA; -- pass A
        z_write := '1';
    
    -- comf f,d
    when "001001" =>
        alu_mux := "01";
        alu_op := A_NOTA; -- NOT A
        writew_en := not wf_bit;
        ram_write := wf_bit;
        z_write := '1';
    
    -- decf f,d
    when "000011" =>
        alu_mux := "01";
        writew_en := not wf_bit;
        ram_write := wf_bit;
        z_write := '1';
        alub_mux := '1';
        alu_op := A_SUBAB;

    -- decfsz f,d
    when "001011" =>
        alu_mux := "01";
        writew_en := not wf_bit;
        ram_write := wf_bit;
        alub_mux := '1';
        alu_op := A_SUBAB;
        skip_next := '1';

    -- incf f,d
    when "001010" =>
        alu_mux := "01";
        writew_en := not wf_bit;
        ram_write := wf_bit;
        z_write := '1';
        alub_mux := '1';
        alu_op := A_ADD;

    -- incfsz f,d
    when "001111" =>
        alu_mux := "01";
        writew_en := not wf_bit;
        ram_write := wf_bit;
        alub_mux := '1';
        alu_op := A_ADD;
        skip_next := '1';

    -- iorwf f,d
    when "000100" =>
        alu_mux := "01"; -- ram
        writew_en := not wf_bit;
        ram_write := wf_bit;
        alu_op := A_OR;
        z_write := '1';
        
    -- movf
    when "001000" =>
        alu_mux := "01"; -- ram
        writew_en := not wf_bit;
        z_write := '1';
    
    -- nop is in others
    
    -- rlf f,d
    when "001101" =>
        alu_mux := "01";
        alu_op := A_RLFA;
        writew_en := not wf_bit;
        ram_write := wf_bit;
        c_write := '1';

    -- rrf f,d
    when "001100" =>
        alu_mux := "01";
        alu_op := A_RRFA;
        writew_en := not wf_bit;
        ram_write := wf_bit;
        c_write := '1';
        
    --subwf f,d
    when "000010" =>
        alu_mux := "01"; -- ram
        writew_en := not wf_bit;
        ram_write := wf_bit;
        alu_op := A_SUBAB;
        c_write := '1';
        dc_write := '1';
        z_write := '1';

    --swapf f,d
    when "001110" =>
        alu_mux := "01"; -- ram
        writew_en := not wf_bit;
        ram_write := wf_bit;
        alu_op := A_SWAPA;

    -- xorwf f,d
    when "000110" =>
        alu_mux := "01"; -- ram
        writew_en := not wf_bit;
        ram_write := wf_bit;
        alu_op := A_XOR;
        z_write := '1';

-- Literal operations
        
    -- addlw, k
    when "111111"|"111110" =>
        writew_en := '1';
        alu_op := A_ADD;
        c_write := '1';
        dc_write := '1';
        z_write := '1';

    -- andlw, k
    when "111001" =>
        alu_op := A_AND;
        z_write := '1';
        writew_en := '1';

    -- iorlw, k
    when "111000" =>
        alu_op := A_OR;
        z_write := '1';
        writew_en := '1';

    -- xorlw, k
    when "111010" =>
        alu_op := A_XOR;
        z_write := '1';
        writew_en := '1';
        
    -- sublw, k
    when "111100"|"111101" =>
        writew_en := '1';
        alu_op := A_SUBAB;
        c_write := '1';
        dc_write := '1';
        z_write := '1';
    
    -- movlw
    when "110000"|"110001"|"110010"|"110011" =>
        writew_en := '1';
        
    -- retlw
    when "110100"|"110101"|"110110"|"110111" =>
        pc_return := '1';
        skip_next := '1';
        writew_en := '1';

-- Misc operations
    when others =>
        -- goto
        if instr(13 downto 11) = "101" then
            branch_mux := '1';
        end if;
        
        -- nop
        if instr(13 downto 7) = "0000000" 
         and instr(4 downto 0) = "00000" then
            -- Nothing
        end if;
        
        -- bcf f,b / bsf f,b
        if instr(13 downto 11) = "010" then
            alu_op := A_BITSET;
            alu_mux := "01"; --ram
            ram_write := '1';
        end if;
        
        -- bcfsc f,d / bsfss f,d
        if instr(13 downto 11) = "011" then
            alu_op := A_BITTST;
            alu_mux := "01"; --ram
            skip_next := '1';
        end if;
        
        -- call
        if instr(13 downto 11) = "100" then
            branch_mux := '1';
            call := '1';
        end if;
        
        -- movwf
        if instr(13 downto 7) = "0000001" then
            alu_mux := "10"; -- 0
            ram_write := '1';
            alu_op := A_ADD; -- add
        end if;
        
        -- return 
        if instr = "00000000001000" then
            pc_return := '1';
            skip_next := '1';
        end if;
        
        -- retfie
        if instr = "00000000001001" then
            pc_return := '1';
            skip_next := '1';
            retfie <= '1';
        end if;
end case;

amux <= alu_mux;
bmux <= alub_mux;
rwmux <= ram_write;
branch <= branch_mux;
aluop <= alu_op;
writew <= writew_en;
skip <= skip_next;
retrn <= pc_return;
pc_push <= call;

status_write <= to_write&pd_write&z_write&dc_write&c_write;
end process;

end Behavioral;

