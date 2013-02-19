LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY cpu_core_tb IS
END cpu_core_tb;
 
ARCHITECTURE behavior OF cpu_core_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT cpu_core
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
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: cpu_core PORT MAP (
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
      -- hold reset state for 100 ns.
      wait for 100 ns;	
      reset <= '0';
      wait for clk_period*10;

      -- insert stimulus here 

      wait;
   end process;

END;
