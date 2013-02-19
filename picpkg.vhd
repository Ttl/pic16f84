library IEEE;
use IEEE.STD_LOGIC_1164.all;

package picpkg is

    constant RAM_MEM_SIZE : integer := 2**7;
    constant INST_MEM_SIZE : integer := 2**13;
    constant STACK_SIZE : integer := 8;

    type alu_ctrl is (A_PASSA, A_ADD, A_AND, A_OR, A_XOR, A_NOTA, A_SUBAB, A_RLFA, A_RRFA, A_BITSET, A_BITTST, A_SWAPA);
    type mem_type8 is array (0 to RAM_MEM_SIZE-1) of std_logic_vector(7 downto 0);
    type mem_type14 is array (0 to INST_MEM_SIZE-1) of std_logic_vector(13 downto 0);
    type stack_type13 is array (0 to STACK_SIZE-1) of std_logic_vector(12 downto 0);


end picpkg;

package body picpkg is

 
end picpkg;
