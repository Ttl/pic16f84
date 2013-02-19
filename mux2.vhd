library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity mux2 is
    Generic (WIDTH : integer);
    Port ( a : in  STD_LOGIC_VECTOR (WIDTH-1 downto 0);
           b : in  STD_LOGIC_VECTOR (WIDTH-1 downto 0);
           c : in  STD_LOGIC;
           y : out  STD_LOGIC_VECTOR (WIDTH-1 downto 0));
end mux2;

architecture Behavioral of mux2 is

begin

y <= a when c = '0' else b;

end Behavioral;

