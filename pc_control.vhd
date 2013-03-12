library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.picpkg.all;

entity pc_control is
    Port ( clk, reset : in  STD_LOGIC;
           instr : in STD_LOGIC_VECTOR(13 downto 0);
           pc : out  STD_LOGIC_VECTOR (12 downto 0);
           pc_ret : in STD_LOGIC_VECTOR (12 downto 0);
           pc_mem : in STD_LOGIC_VECTOR(12 downto 0);
           intcon : in STD_LOGIC_VECTOR(7 downto 0);
           branch, skip_next : in STD_LOGIC;
           fsr_to_pcl : in STD_LOGIC;
           retrn : in STD_LOGIC;
           alu_z : in STD_LOGIC;
           tmr0_overflow : in STD_LOGIC;
           pc_plus1 : out  STD_LOGIC_VECTOR (12 downto 0);
           interrupt_out : out interrupt_type;
           portb_interrupt : in STD_LOGIC;
           portb0_interrupt : in STD_LOGIC;
           skip_dp : out STD_LOGIC
           );
end pc_control;

architecture Behavioral of pc_control is



signal pc_plus1_int, pc_plus1_int2 : std_logic_vector(12 downto 0);
signal pc_tmp : std_logic_vector(12 downto 0);
signal skip_tmp : std_logic;
signal skip : std_logic;
signal pcreg_in : std_logic_vector(12 downto 0);

signal pcl_update, pcl_update_delay : std_logic;

signal interrupt : interrupt_type;

begin

-- Forward the information about PCL update (movwf PCL or movwf INDF and FSR = 0x10)
pcl_update <= '1' when (instr = "00000010000010") or (instr = "00000010000000" and fsr_to_pcl = '1') else '0';

pc_plus1_int2 <= std_logic_vector(unsigned(pc_tmp) + to_unsigned(1,13));
pc_plus1_int <= pc_plus1_int2 when pcl_update = '0' else pc_mem;
pc_plus1 <= pc_plus1_int;

pcreg_in <= std_logic_vector(to_unsigned(4,13)) when interrupt /= I_NONE else
          pc_ret when retrn = '1' else
          pc_mem when pcl_update = '1' else
          pc_plus1_int when branch = '0' or skip = '1'
          else pc_tmp(12 downto 11)&instr(10 downto 0);

pc <= pc_tmp;

skip <= (skip_tmp and alu_z) or pcl_update_delay;
skip_dp <= skip;

-- Skip delay
skip_delay : process(clk)
begin
if rising_edge(clk) then
    pcl_update_delay <= pcl_update;
    skip_tmp <= skip_next;
end if;
end process;

-- Interrupt logic
process(clk, tmr0_overflow, portb_interrupt, intcon, portb0_interrupt, skip)
variable interrupt_hold : interrupt_type := I_NONE;
alias gie is intcon(7);
alias t0ie is intcon(5);
alias rbie is intcon(3);
alias inte is intcon(4);
begin
if rising_edge(clk) then
    interrupt <= I_NONE;
    if gie = '1' and interrupt_hold = I_NONE then
        -- TMR0
        if (tmr0_overflow and t0ie) = '1' then
            interrupt_hold := I_TMR0;
        end if;
        -- PORTB(7 downto 4) changed interrupt
        if (portb_interrupt and rbie) = '1' then
            interrupt_hold := I_RB;
        end if;
        -- PORTB(0)/INR interrupt
        if (portb0_interrupt and inte) = '1' then
            interrupt_hold := I_INT;
        end if;
    end if;
    -- If we are skipping instruction we need to finish executing it
    -- before interrupting, because skip signal is not saved
    -- and otherwise the skipped instruction would be executed on return
    if skip = '0' then
        interrupt <= interrupt_hold;
        interrupt_hold := I_NONE;
    end if;
end if;
end process;
interrupt_out <= interrupt;

pc_reg : entity work.flopr
    generic map( WIDTH => 13)
    port map(clk => clk,
             reset => reset,
             d => pcreg_in,
             q => pc_tmp
             );
             
end Behavioral;

