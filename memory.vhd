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
           portb_interrupt : out STD_LOGIC);
end memory;

architecture Behavioral of memory is

type fsr_type is array(0 to 14) of std_logic_vector(7 downto 0);

-- Two different banks
-- Access is decided by status(5) bit
signal mem_b0, mem_b1 : mem_type8 := (others => (others => '0'));

-- Special function register
signal sfr : fsr_type;

-- SFR fields
alias TMR0 is sfr(0);
alias OPTION_REG is sfr(1);
alias PCL is sfr(2);
alias STATUS is sfr(3);
alias FSR is sfr(4);
alias PORTA is sfr(5);
alias TRISA is sfr(6);
alias PORTB is sfr(7);
alias TRISB is sfr(8);
alias EEDATA is sfr(9);
alias EECON1 is sfr(10);
alias EEADR is sfr(11);
alias EECON2 is sfr(12);
alias PCLATH is sfr(13);
alias INTCON is sfr(14);

alias bank is sfr(3)(5);



begin



-- Memory
process(clk, reset, we, a1, mem_b0, mem_b1, sfr, bank, pcl_in)
variable addr : std_logic_vector(6 downto 0);
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
    
    -- If PORTB interrupt is enabled
    if intcon(3) = '1' then
        -- INTCON(0), RBIF bit. PORTB[4:7] has changed state, must be cleared in software
        -- and with TRISB to compare only input pins
        if (portb_inout(7 downto 4) and trisb(7 downto 4)) /= (portb(7 downto 4) and trisb(7 downto 4)) then
            portb_interrupt <= '1';
        end if;
    end if;
    
    -- On interrupt INTCON(7) GIE is cleared
    if interrupt /= I_NONE then
        intcon(7) <= '0';
    end if;

    -- Set TMR0 overflow bit
    if interrupt = I_TMR0 then
        intcon(2) <= '1';
    end if;
    
    -- Set RB interrupt bit
    if interrupt = I_RB then
        intcon(0) <= '1';
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
                pcl <= wd;
                 
            -- STATUS
            when 3 => 
                status <= "00"&wd(5 downto 0);
            
            -- FSR
            when 4 =>
                fsr <= wd;
                
            -- PORTA/TRISA
            when 5 =>
                if bank = '0' then
                    porta(7 downto 5) <= "---";
                    -- PORTA
                    for I in 0 to 4 loop
                        -- If output
                        if trisa(I) = '0' then
                            porta(I) <= wd(I);
                        else
                            porta(I) <= 'Z';
                        end if;
                    end loop;
                else
                    -- TRISA
                    trisa <= "111"&wd(4 downto 0);
                end if;

            -- PORTB/TRISB
            when 6 =>    
                if bank = '0' then
                    -- PORTB
                    for I in 0 to 7 loop
                        -- If output
                        if trisb(I) = '0' then
                            portb(I) <= wd(I);
                        else
                            portb(I) <= 'Z';
                        end if;
                    end loop;
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
            d1 <= "000"&porta(4 downto 0);
        else
            d1 <= "000"&trisa(4 downto 0);
        end if;

    -- PORTB/TRISB  
    when 6 =>
        if bank = '0' then
            d1 <= portb;
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

if reset = '1' then
    option_reg <= "11111111";
    intcon <= "0000000-";
    pclath <= "00000000";
    porta <= "---ZZZZZ";
    portb <= "ZZZZZZZZ";
    trisa <= "---11111";
    trisb <= "11111111";
    status <="00011000";
end if;
end process;

porta_inout <= porta(4 downto 0);
portb_inout <= portb;
-- Output C flag to ALU for RLF/RRF instructions
status_c <= status(0);
-- PCL is written to when updated
pc_mem_out <= pclath(4 downto 0)&wd;
intcon_out <= intcon;
option_reg_out <= option_reg;
fsr_to_pcl <= '1' when fsr = "00000010" else '0';
end Behavioral;

