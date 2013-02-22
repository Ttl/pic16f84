library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity pc_control is
    Port ( clk, reset : in  STD_LOGIC;
           instr : in STD_LOGIC_VECTOR(13 downto 0);
           pc : out  STD_LOGIC_VECTOR (12 downto 0);
           pc_ret : in STD_LOGIC_VECTOR (12 downto 0);
           pc_mem : in STD_LOGIC_VECTOR(12 downto 0);
           intcon : in STD_LOGIC_VECTOR(7 downto 0);
           branch, skip_next : in STD_LOGIC;
           pcl_update : in STD_LOGIC;
           retrn : in STD_LOGIC;
           alu_z : in STD_LOGIC;
           tmr0_overflow : in STD_LOGIC;
           pc_plus1 : out  STD_LOGIC_VECTOR (12 downto 0);
           skip_instr : out STD_LOGIC;
           interrupt : out STD_LOGIC
           );
end pc_control;

architecture Behavioral of pc_control is

alias gie is intcon(7);
alias t0ie is intcon(5);
signal pc_plus1_int, pc_plus1_int2 : std_logic_vector(12 downto 0);
signal pc_tmp : std_logic_vector(12 downto 0);
signal skip_tmp, skip_tmp2 : std_logic;
signal retrn_delayed : std_logic;
signal skip : std_logic;
signal pcreg_in : std_logic_vector(12 downto 0);

begin

pc_plus1_int2 <= std_logic_vector(unsigned(pc_tmp) + to_unsigned(1,13));
pc_plus1_int <= pc_plus1_int2 when pcl_update = '0' else pc_mem;
pc_plus1 <= pc_plus1_int;

pcreg_in <= std_logic_vector(to_unsigned(4,13)) when (gie and tmr0_overflow and t0ie) = '1' else
          pc_ret when retrn = '1' else
          pc_plus1_int when branch = '0' or skip_tmp2 = '1'
          else pc_tmp(12 downto 11)&instr(10 downto 0);

pc <= pc_tmp;

skip_tmp2 <= skip_tmp and alu_z;
-- Skip instruction on taken conditional branch, return or write to PCL
skip <= skip_tmp2 or retrn_delayed or pcl_update;
skip_instr <= skip;

-- Skip delay
skip_delay : process(clk)
begin
if rising_edge(clk) then
    skip_tmp <= skip_next;
end if;
end process;

retrn_delay : process(clk)
begin
if rising_edge(clk) then
    retrn_delayed <= retrn;
end if;
end process;

-- Interrupt logic
interrupt <= (gie and tmr0_overflow and t0ie);

pc_reg : entity work.flopr
    generic map( WIDTH => 13)
    port map(clk => clk,
             reset => reset,
             d => pcreg_in,
             q => pc_tmp
             );
             
end Behavioral;

