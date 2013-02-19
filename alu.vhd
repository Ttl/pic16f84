library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.picpkg.all;

entity alu is
    Port ( a : in  STD_LOGIC_VECTOR (7 downto 0);
           b : in  STD_LOGIC_VECTOR (7 downto 0);
           ctrl : in  alu_ctrl;
           bit_clr_set : in std_logic;
           bit_sel : in std_logic_vector(2 downto 0);
           status_c : in std_logic;
           r : out  STD_LOGIC_VECTOR (7 downto 0);
           z : out  STD_LOGIC;
           c : out  STD_LOGIC;
           dc : out  STD_LOGIC);
end alu;

-- Main computing unit of the microprocessor.
-- a and b are inputs, others are control signals
-- cit_clr_set if instr(10), it's 0 for bit clear and 1 for bit set
-- using this signal decrease amount of ctrl signals when clear and set
-- can be combined to one control signal

-- bit_sel is bit selection for bit set and clear instructions

-- status_c is current carry flag, used for shfits

-- r = result

-- flags: z = zero, c = carry, dc = digit carry (used for BCD)

architecture Behavioral of alu is

begin

process(a,b,ctrl,bit_clr_set,status_c)

variable tmp : std_logic_vector(8 downto 0);
begin

-- Default values
tmp := '0'&a;
z <= '0';
c <= '0';
dc <= '0';

case ctrl is


    when A_PASSA => -- PASS A
        tmp := "0"&a;
        if unsigned(tmp(7 downto 0)) = 0 then
            z <= '1';
        else
            z <= '0';
        end if;
 
        
    when A_ADD => --ADD
        tmp := std_logic_vector(unsigned('0'&a)+unsigned('0'&b));
        if unsigned(tmp(7 downto 0)) = 0 then
            z <= '1';
        else
            z <= '0';
        end if;
        c <= tmp(8);
        -- VERIFY CORRECTNESS
        dc <= (a(4) and b(4));     
    
    when A_SUBAB => -- SUB A-B
        tmp := std_logic_vector(unsigned('0'&a)-unsigned('0'&b));
        if unsigned(tmp(7 downto 0)) = 0 then
            z <= '1';
        else
            z <= '0';
        end if;
        c <= tmp(8);
        -- VERIFY CORRECTNESS
        dc <= (a(4) and b(4));    
        
    when A_AND => -- AND
        tmp := '0'&(a and b);

    when A_OR =>  -- OR
        tmp := '0'&(a or b);
    
    when A_XOR =>  -- XOR
        tmp := '0'&(a xor b);
 
    when A_NOTA => -- NOT A
        tmp := '0'&(not A);

    when A_BITSET => -- Set bit 'bit_sel' of A to 'bit_clr_set'
        for I in 0 to 7 loop
            if to_integer(unsigned(bit_sel)) = I then
                if I = 7 then
                    tmp := '0'&bit_clr_set&a(6 downto 0);
                elsif I = 0 then
                    tmp := '0'&a(7 downto 1)&bit_clr_set;
                else
                    tmp := '0'&a(7 downto I+1)&bit_clr_set&a(I-1 downto 0);
                end if;
            end if;
        end loop;
    
    when A_BITTST => -- Test if bit 'bit_sel' of A is 'bit_clr_set'
        for I in 0 to 7 loop
            if to_integer(unsigned(bit_sel)) = I then
                z <= (bit_clr_set xnor a(I)); -- Equals
            end if;
        end loop;
        
    when A_SWAPA => -- Swap nibbles in A
        tmp := '0'&a(3 downto 0)&a(7 downto 4);
    
    when A_RLFA => -- Rotate A left through carry
        tmp := '0'&a(6 downto 0)&status_c;
        c <= a(7);
        
    when A_RRFA => -- Rotate A right through carry
        tmp := '0'&status_c&a(7 downto 1);
        c <= a(0);
        
    when others => 
        tmp := '0'&a;
        z <= '0';
        c <= '0';
        dc <= '0';
        
end case;
r <= tmp(7 downto 0);
end process;

end Behavioral;

