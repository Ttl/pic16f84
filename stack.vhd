library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.picpkg.all;

entity stack is
    Port ( clk, reset : in  STD_LOGIC;
           push, pop : in  STD_LOGIC;
           pcin : in  STD_LOGIC_VECTOR (12 downto 0);
           pcout : out  STD_LOGIC_VECTOR (12 downto 0);
           full : out  STD_LOGIC);
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
        mem(to_integer(pointer)) <= pcin;
        pointer := pointer + 1;
    elsif pop = '1' then
        pointer := pointer - 1;
    end if;
end if;
    -- Set output, only readable after pop
    pcout <= mem(to_integer(pointer));
    if pointer = 7 then
        full <= '1';
    else
        full <= '0';
    end if;

if reset = '1' then
    pointer := to_unsigned(0,3);
end if;
end process;

end Behavioral;

