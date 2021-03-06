library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use std.textio.all;
use work.picpkg.all;

entity memory is
    Port ( clk : in  STD_LOGIC;
           reset : in STD_LOGIC;
           a1 : in  STD_LOGIC_VECTOR (6 downto 0);
           d1 : out  STD_LOGIC_VECTOR (7 downto 0);
           wd : in  STD_LOGIC_VECTOR (7 downto 0);
           we : in  STD_LOGIC;
           status_flags : in std_logic_vector(4 downto 0);
           status_write : in std_logic_vector(4 downto 0);
           status_c : out std_logic;
           pc_mem_out : out std_logic_vector(12 downto 0);
           pcl_in : in std_logic_vector(7 downto 0);
           porta_inout : inout std_logic_vector(4 downto 0);
           portb_inout : inout std_logic_vector(7 downto 0);
           fsr_to_pcl : out std_logic;
           intcon_out : out std_logic_vector(7 downto 0);
           option_reg_out : out std_logic_vector(7 downto 0);
           interrupt : in interrupt_type;
           retfie : in STD_LOGIC;
           portb_interrupt : out STD_LOGIC;
           portb0_interrupt : out STD_LOGIC);
end memory;

architecture Behavioral of memory is

type fsr_type is array(0 to 13) of std_logic_vector(7 downto 0);

-- Two different banks
-- Access is decided by status(5) bit
signal mem_b0, mem_b1 : mem_type8 := (others => (others => '0'));

-- Special function register
signal sfr : fsr_type;

-- SFR fields
alias TMR0 is sfr(0);
alias OPTION_REG is sfr(1);
-- PCL
alias STATUS is sfr(2);
alias FSR is sfr(3);
alias PORTA is sfr(4);
alias TRISA is sfr(5);
alias PORTB is sfr(6);
alias TRISB is sfr(7);
alias EEDATA is sfr(8);
alias EECON1 is sfr(9);
alias EEADR is sfr(10);
alias EECON2 is sfr(11);
alias PCLATH is sfr(12);
alias INTCON is sfr(13);

alias bank is sfr(2)(5);

signal portb0_delayed : std_logic;
signal portb0_rising, portb0_falling : std_logic;

begin



-- Memory
process(clk, reset, we, a1, mem_b0, mem_b1, sfr, bank, pcl_in, porta_inout, portb_inout, trisa, trisb)
variable addr : std_logic_vector(6 downto 0);
variable portb_prev : std_logic_vector(7 downto 4);
begin

-- Indirect addressing
if a1 = "0000000" then
    addr := fsr(6 downto 0);
else
    addr := a1;
end if;


    
if rising_edge(clk) then
    for I in 0 to 4 loop
        if status_write(I) = '1' then
            status(I) <= status_flags(I);
        end if;
    end loop;
    
    portb_interrupt <= '0';
    -- INTCON(0), RBIF bit. PORTB[4:7] has changed state, must be cleared in software
    -- and with TRISB to compare only input pins
    if (portb_prev(7 downto 4) and trisb(7 downto 4)) /= (portb_inout(7 downto 4) and trisb(7 downto 4)) then
        portb_interrupt <= '1';
    end if;
    portb_prev := portb_inout(7 downto 4);
    
    portb0_interrupt <= '0';
    -- OPTION(6) is interrupt edge direction, 1 = rising edge
    if option_reg(6) = '1' and portb0_rising = '1' then
        portb0_interrupt <= '1';
    end if;
    
    if option_reg(6) = '0' and portb0_falling = '1' then
        portb0_interrupt <= '1';
    end if;

    -- Set RB interrupt bit (RBIF)
    if interrupt = I_RB then
        intcon(0) <= '1';
    end if;
    
    -- Set PORTB(0)/INT interrupt bit (INTF)
    if interrupt = I_INT then
        intcon(1) <= '1';
    end if;
    
    -- Set TMR0 overflow bit (T0IF)
    if interrupt = I_TMR0 then
        intcon(2) <= '1';
    end if;
    
    -- On interrupt INTCON(7) GIE is cleared
    if interrupt /= I_NONE then
        intcon(7) <= '0';
    end if;
    
    -- On return from interrupt (retfie) GIE is set
    if retfie = '1' then
        intcon(7) <= '1';
    end if;
    
    if we = '1' then
        --Write
        case to_integer(unsigned(addr)) is
            -- Indirect addressing
            when 0 =>
                -- Pointer pointing to itself ?
            
            -- TMR0/OPTION_REG
            when 1 =>
                if bank = '0' then
                    tmr0 <= wd;
                else
                    option_reg <= wd;
                end if;
                
            -- PCL
            when 2 =>
                --Handled by pc_control
                 
            -- STATUS
            when 3 => 
                status <= "00"&wd(5 downto 0);
            
            -- FSR
            when 4 =>
                fsr <= wd;
                
            -- PORTA/TRISA
            when 5 =>
                if bank = '0' then
                    -- PORTA
                    porta <= wd;
                else
                    -- TRISA
                    trisa <= "111"&wd(4 downto 0);
                end if;

            -- PORTB/TRISB
            when 6 =>    
                if bank = '0' then
                    -- PORTB
                    portb <= wd;
                else
                    -- TRISB
                    trisb <= wd;
                end if;
            
            -- Not implemented
            when 7 =>
            
            -- EEDATA/EECON1
            when 8 =>
                if bank = '0' then
                    eedata <= wd;
                else
                    eecon1 <= wd;
                end if;
            
            -- EADR/EECON2
            when 9 =>
                if bank = '0' then
                    eeadr <= wd;
                else
                    eecon2 <= wd;
                end if;
            
            -- PCLATH
            when 10 =>
                pclath <= "000"&wd(4 downto 0);
            
            -- INTCON
            when 11 =>
                intcon <= wd;
                
            when others =>
                    if bank = '0' then
                        mem_b0(to_integer(unsigned(addr))) <= wd;
                    else
                        mem_b1(to_integer(unsigned(addr))) <= wd;
                    end if;
        end case;
    end if;
end if;

-- Set output
case to_integer(unsigned(addr)) is
    
    -- Read from pointer that points to itself
    when 0 =>
        d1 <= "XXXXXXXX";
    
    -- TMR0/OPTION_REG
    when 1 =>
        if bank = '0' then
            d1 <= tmr0;
        else
            d1 <= option_reg;
        end if;
        
    -- PCL
    when 2 =>
        -- Read low bits of PC
        d1 <= pcl_in;
    
    -- STATUS
    when 3 =>
        d1 <= "00"&status(5 downto 0);
    
    -- FSR
    when 4 =>
        d1 <= fsr;
        
    -- PORTA/TRISA    
    when 5 =>
        if bank = '0' then
            d1 <= "000"&porta_inout;
        else
            d1 <= "000"&trisa(4 downto 0);
        end if;

    -- PORTB/TRISB  
    when 6 =>
        if bank = '0' then
            d1 <= portb_inout;
        else
            d1 <= trisb;
        end if;
    
    -- Not implemented, read as 0
    when 7 =>
        d1 <= "00000000";
    
    -- EEDATA/EECON1
    when 8 =>
        if bank = '0' then
            d1 <= eedata;
        else
            d1 <= eecon1;
        end if;
    
    -- EEADR/EECON2
    when 9 =>
        if bank = '0' then
            d1 <= eeadr;
        else
            d1 <= eecon2;
        end if;
       
    -- PCLATH
    when 10 =>
        -- Not updated automatically from PC
        d1 <= pclath;
   
   -- INTCON
    when 11 =>
        d1 <= intcon;
        
    when others =>
        if bank = '0' then
            d1 <= mem_b0(to_integer(unsigned(addr)));
        else
            d1 <= mem_b1(to_integer(unsigned(addr)));
        end if;
end case;

-- Set outputs if needed
for I in 0 to 4 loop
    -- If output
    if trisa(I) = '0' then
        porta_inout(I) <= porta(I);
    else
        porta_inout(I) <= 'Z';
    end if;
end loop;

for I in 0 to 7 loop
    -- If output
    if trisb(I) = '0' then
        portb_inout(I) <= portb(I);
    else
        portb_inout(I) <= 'Z';
    end if;
end loop;

if reset = '1' then
    option_reg <= "11111111";
    intcon <= "0000000-";
    pclath <= "00000000";
    porta_inout <= "ZZZZZ";
    portb_inout <= "ZZZZZZZZ";
    trisa <= "---11111";
    trisb <= "11111111";
    status <="00011000";
end if;
end process;


                    
portb0_delay: process(clk, portb_inout)
begin
if rising_edge(clk) then
    portb0_delayed <= portb_inout(0);
end if;
end process;

portb0_rising <= not portb0_delayed and portb_inout(0);
portb0_falling <= portb0_delayed and not portb_inout(0);
    
-- Output C flag to ALU for RLF/RRF instructions
status_c <= status(0);
-- PCL is written to when updated
pc_mem_out <= pclath(4 downto 0)&wd;
intcon_out <= intcon;
option_reg_out <= option_reg;
fsr_to_pcl <= '1' when fsr = "00000010" else '0';
end Behavioral;

