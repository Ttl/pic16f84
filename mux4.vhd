library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity mux4 is
    Generic (WIDTH : integer);
    Port ( a : in  STD_LOGIC_VECTOR (WIDTH-1 downto 0);
           b : in  STD_LOGIC_VECTOR (WIDTH-1 downto 0);
           c : in  STD_LOGIC_VECTOR (WIDTH-1 downto 0);
           d : in  STD_LOGIC_VECTOR (WIDTH-1 downto 0);
           s : in  STD_LOGIC_VECTOR(1 downto 0);
           y : out  STD_LOGIC_VECTOR (WIDTH-1 downto 0));
end mux4;

architecture Behavioral of mux4 is

begin

y <= a when s = "00" else
     b when s = "01" else
     c when s = "10" else
     d;

end Behavioral;

