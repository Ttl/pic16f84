library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.picpkg.all;

entity timer is
    Port ( clk, reset : in  STD_LOGIC;
           t0ie : in  STD_LOGIC;
           option : in STD_LOGIC_VECTOR(7 downto 0);
           porta4 : in  STD_LOGIC;
           tmr0_interrupt : out  STD_LOGIC);
end timer;

architecture Behavioral of timer is

alias prescale is option(2 downto 0);
-- 1 transition on porta4 edge, 0 internal clock
alias clk_source is option(5);
-- 1 high-to-low, 0 low-to-high increment of RA4;
alias source_edge is option(4);
-- Prescaler assignment
alias psa is option(3);

signal prescaler_out : std_logic;
-- Input signal to TMR0
signal tmr_clk : std_logic;
signal tmr0_overflow : std_logic;
signal porta4_delayed : std_logic;

signal porta4_rising, porta4_falling : std_logic;
begin

porta4_delay: process(clk, porta4)
begin
if rising_edge(clk) then
    porta4_delayed <= porta4;
end if;
end process;

porta4_rising <= not porta4_delayed and porta4;
porta4_falling <= porta4_delayed and not porta4;

prescaler:process(clk, reset, prescale, clk_source, porta4, porta4_delayed)
variable count : unsigned(8 downto 0);
begin
if reset = '1' then
    prescaler_out <= '0';
    count := to_unsigned(0,9);
elsif rising_edge(clk) then
    prescaler_out <= '0';
    -- Rising falling edge and transition source logic
    if (clk_source = '0') or 
     ((not source_edge and porta4_rising) = '1')
     or ((source_edge and porta4_falling) = '1') then
        count := count + 1;
        if count(to_integer(unsigned(prescale))) = '1' then
            -- Overflow
            count := to_unsigned(0,9);
            prescaler_out <= '1';
        end if;
    end if;
end if;
end process;

tmr_clk <= porta4_rising when clk_source = '1' and source_edge = '0' else
           porta4_falling when clk_source = '1' and source_edge = '1' else
            prescaler_out when psa = '0'
           else '-';

process(clk, tmr_clk, reset)
variable count : unsigned(8 downto 0);
begin
if reset = '1' then
    count := to_unsigned(0,9);
elsif rising_edge(clk) then
    tmr0_overflow <= count(8);
    if (psa = '1' or tmr_clk = '1') then
        count := count + 1;
        if count(8) = '1' then
            -- Overflow
            count := to_unsigned(0,9);
            tmr0_overflow <= '1';
        end if;
    end if;
end if;
end process;

tmr0_interrupt <= t0ie and tmr0_overflow;
end Behavioral;

