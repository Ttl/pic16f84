library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use std.textio.all;
use work.picpkg.all;

entity memory_instruction is
    Generic (
        CONTENTS : string := "scripts/instructions.mif"
        );
    Port ( clk : in  STD_LOGIC;
           a1 : in  STD_LOGIC_VECTOR (12 downto 0);
           d1 : out  STD_LOGIC_VECTOR (13 downto 0);
           wd : in  STD_LOGIC_VECTOR (13 downto 0);
           we : in  STD_LOGIC);
end memory_instruction;

architecture Behavioral of memory_instruction is

impure function init_mem(mif_file_name : in string) return mem_type14 is
    file mif_file : text open read_mode is mif_file_name;
    variable mif_line : line;
    variable temp_bv : bit_vector(13 downto 0);
    variable temp_mem : mem_type14;
    variable i : integer := 0;
begin
    for j in 0 to mem_type14'length-1 loop
        if not endfile(mif_file) then
            readline(mif_file, mif_line);
            -- Xilinx ISE implementation fix, uncomment to enable implementation and lose the last instruction
            --if not endfile(mif_file) then
            read(mif_line, temp_bv);
            temp_mem(j) := to_stdlogicvector(temp_bv);
            --end if;
        else
            temp_mem(j) := (others => '0');
        end if;
    end loop;
    return temp_mem;
end function;


signal mem : mem_type14 := init_mem(CONTENTS);

begin

process(clk, we, a1, mem)
begin

if rising_edge(clk) then
    if we = '1' then
        --Write
        mem(to_integer(unsigned(a1(INST_MEM_SIZE - 1 downto 0)))) <= wd;
    end if;

    -- Set output
    d1 <= mem(to_integer(unsigned(a1(INST_MEM_SIZE - 1 downto 0))));
end if;

end process;

end Behavioral;

