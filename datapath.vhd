library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.picpkg.all;

entity datapath is
    Port ( clk,reset : in  STD_LOGIC;
           instr10 : in  STD_LOGIC_VECTOR(10 downto 0);
           writedata : out std_logic_vector(7 downto 0);
           readdata : in std_logic_vector(7 downto 0);
           alu_op : in alu_ctrl;
           write_en : out std_logic;
           bmux,rwmux,writew : in std_logic;
           amux : in std_logic_vector(1 downto 0);
           status_flags : out std_logic_Vector(4 downto 0);
           status_c_in : in std_logic;
           skip_ex : in std_logic);
end datapath;

architecture Behavioral of datapath is

signal wnext, w : std_logic_vector(7 downto 0);
signal alu_z, alu_c, alu_dc : std_logic;
signal amux_out, bmux_out : std_logic_vector(7 downto 0);
signal alu_result : std_logic_vector(7 downto 0);

begin

-- If skip_ex is '1' skipped instruction is computed, but not stored

-- Write ALU result to RAM
write_en <= rwmux and not skip_ex;
-- Source of next W value
wnext <= alu_result when writew = '1' and skip_ex = '0' else w;

-- RAM input data is always ALU result
writedata <= alu_result;
-- Status flags from ALU to IO
status_flags <= "00"&alu_z&alu_dc&alu_c;
             
w_reg : entity work.flopr
    generic map( WIDTH => 8)
    port map(clk => clk,
             reset => reset,
             d => wnext,
             q => w
             );

-- ALU A mux 
amux_out <= instr10(7 downto 0) when amux = "00" else
            readdata when amux = "01" else
            "00000000" when amux = "10" else
            "--------";

-- ALU B mux             
bmux_out <= w when bmux = '0' else "00000001";

alu1 : entity work.alu
    Port map( a => amux_out,
           b => bmux_out,
           ctrl => alu_op,
           bit_clr_set => instr10(10),
           bit_sel => instr10(9 downto 7),
           status_c => status_c_in,
           r => alu_result,
           z => alu_z,
           c => alu_c,
           dc => alu_dc
           );
           
end Behavioral;

