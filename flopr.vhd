library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity flopr is
    Generic ( WIDTH : integer);
    Port ( clk,reset : in  STD_LOGIC;
           d : in  STD_LOGIC_VECTOR (WIDTH-1 downto 0);
           q : out  STD_LOGIC_VECTOR (WIDTH-1 downto 0));
end flopr;

architecture Behavioral of flopr is

begin

process(clk, reset)
begin
if rising_edge(clk) then
    if reset = '1' then
        q <= (others => '0');
    else
        q <= d;
    end if;
end if;
end process;

end Behavioral;

