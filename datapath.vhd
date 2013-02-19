library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.picpkg.all;

entity datapath is
    Port ( clk,reset : in  STD_LOGIC;
           pc : out  STD_LOGIC_VECTOR(12 downto 0);
           pc_plus1 : out STD_LOGIC_VECTOR(12 downto 0);
           pc_ret : in  STD_LOGIC_VECTOR(12 downto 0);
           instr : in  STD_LOGIC_VECTOR(13 downto 0);
           writedata : out std_logic_vector(7 downto 0);
           readdata : in std_logic_vector(7 downto 0);
           alu_op : in alu_ctrl;
           write_en : out std_logic;
           bmux,rwmux,branch,writew,retrn : in std_logic;
           amux : in std_logic_vector(1 downto 0);
           skip_next : in std_logic;
           status_flags : out std_logic_Vector(4 downto 0);
           status_c_in : std_logic;
           pc_mem : in std_logic_vector(12 downto 0);
           pcl_update : in std_logic);
end datapath;

architecture Behavioral of datapath is

signal pcnext : std_logic_vector(12 downto 0);
signal wnext, w : std_logic_vector(7 downto 0);
signal alu_z, alu_c, alu_dc : std_logic;
signal amux_out, bmux_out : std_logic_vector(7 downto 0);
signal pc_tmp, pc_plus1_int2, pc_plus1_int : std_logic_vector(12 downto 0);
signal alu_result : std_logic_vector(7 downto 0);

signal skip, skip_tmp : std_logic;
signal retrn_delayed : std_logic;
begin

-- Next address if no branch or untaken conditional branch (skip)
-- Taken conditional otherwise
pcnext <= pc_ret when retrn_delayed = '1' else
          pc_plus1_int when branch = '0' or skip = '1'
          else pc_tmp(12 downto 11)&instr(10 downto 0);

pc_plus1_int2 <= std_logic_vector(unsigned(pc_tmp) + to_unsigned(1,13));
pc_plus1_int <= pc_plus1_int2 when pcl_update = '0' else pc_mem;
pc_plus1 <= pc_plus1_int;

-- Don't write to RAM on skipped instruction       
write_en <= rwmux when skip = '0' else '0';
-- pc_tmp is internal pc for reading, pc is output signal
pc <= pc_tmp;
-- Don't write W when skipping an instruction
wnext <= alu_result when writew = '1' and skip = '0' else w;
-- RAM data in, address comes from instr(6 downto 0)
writedata <= alu_result;
-- Status flags from ALU to IO
status_flags <= "00"&alu_z&alu_dc&alu_c;

-- Skip instruction on taken conditional branch or return
skip <= skip_tmp or retrn_delayed;

skip_delay : process(clk)
begin
if rising_edge(clk) then
    skip_tmp <= skip_next and alu_z;
end if;
end process;

retrn_delay : process(clk)
begin
if rising_edge(clk) then
    retrn_delayed <= retrn;
end if;
end process;

pc_reg : entity work.flopr
    generic map( WIDTH => 13)
    port map(clk => clk,
             reset => reset,
             d => pcnext,
             q => pc_tmp
             );
             
w_reg : entity work.flopr
    generic map( WIDTH => 8)
    port map(clk => clk,
             reset => reset,
             d => wnext,
             q => w
             );
-- ALU A mux             
alua_mux : entity work.mux4
    generic map(WIDTH => 8)
    port map(a => instr(7 downto 0),
             b => readdata,
             c => "00000000",
             d => "00000001",
             s => amux,
             y => amux_out
            );

-- ALU B mux             
alub_mux : entity work.mux2
    generic map(WIDTH => 8)
    port map(a => w,
             b => "00000001",
             c => bmux,
             y => bmux_out
            );
            
alu1 : entity work.alu
    Port map( a => amux_out,
           b => bmux_out,
           ctrl => alu_op,
           bit_clr_set => instr(10),
           bit_sel => instr(9 downto 7),
           status_c => status_c_in,
           r => alu_result,
           z => alu_z,
           c => alu_c,
           dc => alu_dc
           );
           
end Behavioral;

