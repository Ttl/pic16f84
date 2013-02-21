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

signal z_write, dc_write, c_write, to_write, pd_write : std_logic;
begin

process(instr)
-- ALU A mux: 00 : instr, 01 : ram ,10 : 0, 11 : 1
-- ALU B mux: 0 : W, 1 : 1
alias wf_bit is instr(7);
begin

amux <= "00";
retfie <= '0';
bmux <= '0';
rwmux <= '0';
branch <= '0';
writew <= '0';
aluop <= A_PASSA;
skip <= '0';
retrn <= '0';
pc_push <= '0';

-- Status register update flags
z_write <= '0';
c_write <= '0';
dc_write <= '0';
to_write <= '0';
pd_write <= '0';

case instr(13 downto 8) is
    
    --addwf f,d
    when "000111" =>
        amux <= "01"; -- ram
        writew <= not wf_bit;
        rwmux <= wf_bit;
        aluop <= A_ADD;
        c_write <= '1';
        dc_write <= '1';
        z_write <= '1';
        
    
    -- andwf f,d
    when "000101" =>
        amux <= "01"; -- ram
        writew <= not wf_bit;
        rwmux <= wf_bit;
        aluop <= A_AND;
        z_write <= '1';
    
    -- clrf f/clrw -
    when "000001" =>
        amux <= "10"; -- 0
        writew <= not wf_bit;
        rwmux <= wf_bit;
        aluop <= A_PASSA; -- pass A
        z_write <= '1';
    
    -- comf f,d
    when "001001" =>
        amux <= "01";
        aluop <= A_NOTA; -- NOT A
        writew <= not wf_bit;
        rwmux <= wf_bit;
        z_write <= '1';
    
    -- decf f,d
    when "000011" =>
        amux <= "01";
        writew <= not wf_bit;
        rwmux <= wf_bit;
        z_write <= '1';
        bmux <= '1';
        aluop <= A_SUBAB;

    -- decfsz f,d
    when "001011" =>
        amux <= "01";
        writew <= not wf_bit;
        rwmux <= wf_bit;
        bmux <= '1';
        aluop <= A_SUBAB;
        skip <= '1';

    -- incf f,d
    when "001010" =>
        amux <= "01";
        writew <= not wf_bit;
        rwmux <= wf_bit;
        z_write <= '1';
        bmux <= '1';
        aluop <= A_ADD;

    -- incfsz f,d
    when "001111" =>
        amux <= "01";
        writew <= not wf_bit;
        rwmux <= wf_bit;
        bmux <= '1';
        aluop <= A_ADD;
        skip <= '1';

    -- iorwf f,d
    when "000100" =>
        amux <= "01"; -- ram
        writew <= not wf_bit;
        rwmux <= wf_bit;
        aluop <= A_OR;
        z_write <= '1';
        
    -- movf
    when "001000" =>
        amux <= "01"; -- ram
        writew <= not wf_bit;
        z_write <= '1';
    
    -- nop is in others
    
    -- rlf f,d
    when "001101" =>
        amux <= "01";
        aluop <= A_RLFA;
        writew <= not wf_bit;
        rwmux <= wf_bit;
        c_write <= '1';

    -- rrf f,d
    when "001100" =>
        amux <= "01";
        aluop <= A_RRFA;
        writew <= not wf_bit;
        rwmux <= wf_bit;
        c_write <= '1';
        
    --subwf f,d
    when "000010" =>
        amux <= "01"; -- ram
        writew <= not wf_bit;
        rwmux <= wf_bit;
        aluop <= A_SUBAB;
        c_write <= '1';
        dc_write <= '1';
        z_write <= '1';

    --swapf f,d
    when "001110" =>
        amux <= "01"; -- ram
        writew <= not wf_bit;
        rwmux <= wf_bit;
        aluop <= A_SWAPA;

    -- xorwf f,d
    when "000110" =>
        amux <= "01"; -- ram
        writew <= not wf_bit;
        rwmux <= wf_bit;
        aluop <= A_XOR;
        z_write <= '1';

-- Literal operations
        
    -- addlw, k
    when "111111"|"111110" =>
        writew <= '1';
        aluop <= A_ADD;
        c_write <= '1';
        dc_write <= '1';
        z_write <= '1';

    -- andlw, k
    when "111001" =>
        aluop <= A_AND;
        z_write <= '1';
        writew <= '1';

    -- iorlw, k
    when "111000" =>
        aluop <= A_OR;
        z_write <= '1';
        writew <= '1';

    -- xorlw, k
    when "111010" =>
        aluop <= A_XOR;
        z_write <= '1';
        writew <= '1';
        
    -- sublw, k
    when "111100"|"111101" =>
        writew <= '1';
        aluop <= A_SUBAB;
        c_write <= '1';
        dc_write <= '1';
        z_write <= '1';
    
    -- movlw
    when "110000"|"110001"|"110010"|"110011" =>
        writew <= '1';
        
    -- retlw
    when "110100"|"110101"|"110110"|"110111" =>
        retrn <= '1';
        skip <= '1';
        writew <= '1';

-- Misc operations
    when others =>
        -- goto
        if instr(13 downto 11) = "101" then
            branch <= '1';
        end if;
        
        -- nop
        if instr(13 downto 7) = "0000000" 
         and instr(4 downto 0) = "00000" then
            -- Nothing
        end if;
        
        -- bcf f,b / bsf f,b
        if instr(13 downto 11) = "010" then
            aluop <= A_BITSET;
            amux <= "01"; --ram
            rwmux <= '1';
        end if;
        
        -- bcfsc f,d / bsfss f,d
        if instr(13 downto 11) = "011" then
            aluop <= A_BITTST;
            amux <= "01"; --ram
            skip <= '1';
        end if;
        
        -- call
        if instr(13 downto 11) = "100" then
            branch <= '1';
            pc_push <= '1';
        end if;
        
        -- movwf
        if instr(13 downto 7) = "0000001" then
            amux <= "10"; -- 0
            rwmux <= '1';
            aluop <= A_ADD; -- add
        end if;
        
        -- return 
        if instr = "00000000001000" then
            retrn <= '1';
            skip <= '1';
        end if;
        
        -- retfie
        if instr = "00000000001001" then
            retrn <= '1';
            skip <= '1';
            retfie <= '1';
        end if;
end case;

end process;

status_write <= to_write&pd_write&z_write&dc_write&c_write;
end Behavioral;

