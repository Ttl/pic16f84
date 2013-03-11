LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY timer_tb IS
END timer_tb;
 
ARCHITECTURE behavior OF timer_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT timer
    PORT(
         clk : IN  std_logic;
         reset : IN  std_logic;
         option : IN  std_logic_vector(7 downto 0);
         porta4 : IN  std_logic;
         tmr0_overflow : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal reset : std_logic := '0';
   signal option : std_logic_vector(7 downto 0) := (others => '0');
   signal porta4 : std_logic := '0';

 	--Outputs
   signal tmr0_overflow : std_logic;

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: timer PORT MAP (
          clk => clk,
          reset => reset,
          option => option,
          porta4 => porta4,
          tmr0_overflow => tmr0_overflow
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
      -- hold reset state for 100 ns.
      reset <= '1';
      wait for 100 ns;	
      reset <= '0';
      wait for clk_period;
      option <= "11111001";
      porta4 <= '0';
      wait for clk_period*3;
      porta4 <= '1';
      wait for clk_period*3;
      porta4 <= '0';
      wait for clk_period*3;
      porta4 <= '1';
      wait for clk_period*3;
      porta4 <= '0';
      wait for clk_period*3;
      porta4 <= '1';
      wait for clk_period*3;
      porta4 <= '0';
      wait for clk_period*3;
      porta4 <= '1';
      wait for clk_period*3;
      porta4 <= '0';
      wait for clk_period*3;
      porta4 <= '1';
      wait for clk_period*3;
      porta4 <= '0';
      wait for clk_period*3;
      porta4 <= '1';
      wait for clk_period*3;
      porta4 <= '0';
      -- insert stimulus here 

      wait;
   end process;

END;
