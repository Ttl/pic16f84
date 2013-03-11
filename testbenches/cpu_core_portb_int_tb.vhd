LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
 
ENTITY cpu_core_portb_int IS
END cpu_core_portb_int;
 
ARCHITECTURE behavior OF cpu_core_portb_int IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT cpu_core
    GENERIC( instruction_file : string);
    PORT(
         clk : IN  std_logic;
         reset : IN  std_logic;
         porta : INOUT  std_logic_vector(4 downto 0);
         portb : INOUT  std_logic_vector(7 downto 0);
         pc_out : OUT  std_logic_vector(12 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal reset : std_logic := '0';

 	--Outputs
   signal porta : std_logic_vector(4 downto 0);
   signal portb : std_logic_vector(7 downto 0);
   signal pc_out : std_logic_vector(12 downto 0);

   -- Clock period definitions
   constant clk_period : time := 31.25 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: cpu_core 
   Generic map(instruction_file => "scripts/instructions_portb_int.mif")
   PORT MAP (
          clk => clk,
          reset => reset,
          porta => porta,
          portb => portb,
          pc_out => pc_out
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      reset <= '1';
      portb <= "00000000";
      -- hold reset state for 100 ns.
      wait for 100 ns;	
      reset <= '0';
      wait for clk_period*20;
      portb <= "10000000";
      wait for clk_period;
      portb <= "00000000";
      wait for clk_period*2;
      -- Check that RBI interrupt has been caught, e.g. PC is 0x04 (interrupt vector)
      assert pc_out = std_logic_vector(to_unsigned(4,13)) report "RB interrupt not caught" severity failure;
      wait for clk_period*3;
      portb <= "00000001";
      wait for clk_period*3;
      -- Check that RB0/INT interrupt has been caught, e.g. PC is 0x04 (interrupt vector)
      assert pc_out = std_logic_vector(to_unsigned(4,13)) report "RB0/INT interrupt not caught" severity failure;
      
      wait;
   end process;

END;
