library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.picpkg.all;

entity stack is
    Port ( clk, reset : in  STD_LOGIC;
           push, pop : in  STD_LOGIC;
           pcin : in  STD_LOGIC_VECTOR (12 downto 0);
           pcout : out  STD_LOGIC_VECTOR (12 downto 0));
end stack;

architecture Behavioral of stack is

signal mem : stack_type13;

begin

process(clk, reset, mem, push, pop, pcin)
variable pointer : unsigned(2 downto 0);
begin

if rising_edge(clk) then
    if push = '1' then
        --Write
        pointer := pointer + 1;
        mem(to_integer(pointer)) <= pcin;
    elsif pop = '1' then
        pointer := pointer - 1;
    end if;
end if;
    -- Set output, only readable after pop
    pcout <= mem(to_integer(pointer));

if reset = '1' then
    pointer := to_unsigned(0,3);
end if;
end process;

end Behavioral;

