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
signal tmr0_overflow : std_logic;

signal interrupt, retfie : std_logic;

signal intcon, option_reg : std_logic_vector(7 downto 0);

signal skip_instr : std_logic;
begin

pc_out <= pc;

datapath : entity work.datapath
    port map(
        clk => clk,
        reset => reset,
        instr => instr,
        writedata => writedata,
        readdata => readdata,
        alu_op => alu_op,
        write_en => ram_write_en,
        amux => amux,
        bmux => bmux,
        rwmux => rwmux,
        writew => writew,
        skip_instr => skip_instr,
        status_flags => status_flags,
        status_c_in => status_c
    );

pc_ctrl : entity work.pc_control
    port map( 
        clk => clk,
        reset => reset,
        instr => instr,
        pc => pc,
        pc_ret => stack_out,
        pc_mem => pc_mem,
        intcon => intcon,
        branch => branch,
        skip_next => skip,
        pcl_update => pc_update,
        retrn => retrn,
        alu_z => status_flags(2),
        tmr0_overflow => tmr0_overflow,
        pc_plus1 => stack_in,
        skip_instr => skip_instr,
        interrupt => interrupt
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
    port map( 
        clk => clk,
        a1 => pc,
        d1 => instr,
        wd => (others => '0'),
        we => '0'
    );

io : entity work.memory
    port map( 
        clk => clk,
        reset => reset,
        a1 => instr(6 downto 0),
        d1 => readdata,
        wd => writedata,
        we => ram_write_en,
        status_flags => status_flags,
        status_write => status_write,
        status_c => status_c,
        pc_mem_out => pc_mem,
        pcl_in => pc(7 downto 0),
        porta_inout => porta,
        portb_inout => portb,
        pc_update => pc_update,
        intcon_out => intcon,
        option_reg_out => option_reg,
        interrupt => interrupt,
        retfie => retfie
    );

stack_push <= interrupt or call;

stack : entity work.stack
    port map( 
        clk => clk,
        reset => reset,
        push => stack_push,
        pop => retrn,
        pcin => stack_in,
        pcout => stack_out
    );

tmr0 : entity work.timer
    port map( 
        clk => clk,
        reset => reset,
        option => option_reg,
        porta4 => porta(4),
        tmr0_overflow => tmr0_overflow
    );
              
end Behavioral;

