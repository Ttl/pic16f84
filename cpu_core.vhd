library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.picpkg.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

entity cpu_core is
    Port ( clk, reset : in  STD_LOGIC;
           porta : inout std_logic_vector(4 downto 0);
           portb : inout std_logic_vector(7 downto 0);
           pc_out : out std_logic_vector(12 downto 0));
end cpu_core;

architecture Behavioral of cpu_core is

signal bmux, rwmux, branch, writew, skip, retrn : std_logic;
signal amux : std_logic_vector(1 downto 0);
signal alu_op : alu_ctrl;
signal ram_write_en : std_logic;
signal instr : std_logic_vector(13 downto 0);
signal pc : std_logic_vector(12 downto 0);
signal writedata, readdata : std_logic_vector(7 downto 0);
signal ram_address : std_logic_vector(6 downto 0);

signal status_c : std_logic;
signal status_write, status_flags : std_logic_vector(4 downto 0);

-- Stack signals
signal stack_push : std_logic;
signal stack_in, stack_out : std_logic_vector(12 downto 0);

signal pc_mem : std_logic_vector(12 downto 0);
signal pc_update : std_logic;

-- Signal for pushing PC to stack from decoder
signal call : std_logic;
-- Signal from TMR0 for pushing the PC to stack
signal tmr0_interrupt : std_logic;

signal interrupt, retfie : std_logic;

signal intcon, option_reg : std_logic_vector(7 downto 0);
begin

pc_out <= pc;

datapath : entity work.datapath
    port map(
    clk => clk,
    reset => reset,
    pc => pc,
    pc_plus1 => stack_in,
    pc_ret => stack_out,
    instr => instr,
    writedata => writedata,
    readdata => readdata,
    alu_op => alu_op,
    write_en => ram_write_en,
    amux => amux,
    bmux => bmux,
    rwmux => rwmux,
    branch => branch,
    writew => writew,
    retrn => retrn,
    skip_next => skip,
    status_flags => status_flags,
    status_c_in => status_c,
    pc_mem => pc_mem,
    pcl_update => pc_update,
    gie => intcon(7),
    tmr0_interrupt => tmr0_interrupt
    );

decoder : entity work.decoder
    port map(
    instr => instr,
    amux => amux,
    bmux => bmux,
    rwmux => rwmux,
    branch => branch,
    writew => writew,
    retrn => retrn,
    pc_push => call,
    skip => skip,
    aluop => alu_op,
    status_write => status_write,
    retfie => retfie
    );

instr_memory : entity work.memory_instruction
    generic map(
           CONTENTS => "scripts/instructions.mif"
                )
    port map( clk => clk,
           a1 => pc,
           d1 => instr,
           wd => (others => '0'),
           we => '0');

io : entity work.memory
    port map( clk => clk,
              reset => reset,
           a1 => instr(6 downto 0),
           d1 => readdata,
           wd => writedata,
           we => ram_write_en,
           status_flags => status_flags,
           status_write => status_write,
           status_c => status_c,
           pc_mem_out => pc_mem,
           pc_in => pc,
           porta_inout => porta,
           portb_inout => portb,
           pc_update => pc_update,
           intcon_out => intcon,
           option_reg_out => option_reg,
           interrupt => interrupt,
           retfie => retfie);

interrupt <= tmr0_interrupt; -- Add missing interrupts
stack_push <= tmr0_interrupt or call;

stack : entity work.stack
    port map( clk => clk,
              reset => reset,
              push => stack_push,
              pop => retrn,
              pcin => stack_in,
              pcout => stack_out,
              full => open);

tmr0 : entity work.timer
    port map( clk => clk,
              reset => reset,
              t0ie => intcon(5),
              option => option_reg,
              porta4 => porta(4),
              tmr0_interrupt => tmr0_interrupt);
              
end Behavioral;

