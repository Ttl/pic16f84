LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
use work.picpkg.all;
 
ENTITY alu_tb IS
END alu_tb;
 
ARCHITECTURE behavior OF alu_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT alu
    PORT(
         a : IN  std_logic_vector(7 downto 0);
         b : IN  std_logic_vector(7 downto 0);
         ctrl : IN  alu_ctrl;
         r : OUT  std_logic_vector(7 downto 0);
         z : OUT  std_logic;
         c : OUT  std_logic;
         dc : OUT  std_logic
        );
    END COMPONENT;
    
   -- Clock
   signal clk : std_logic;

   --Inputs
   signal a : std_logic_vector(7 downto 0) := (others => '0');
   signal b : std_logic_vector(7 downto 0) := (others => '0');
   signal ctrl : alu_ctrl;

 	--Outputs
   signal r : std_logic_vector(7 downto 0);
   signal z : std_logic;
   signal c : std_logic;
   signal dc : std_logic;
 
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: alu PORT MAP (
          a => a,
          b => b,
          ctrl => ctrl,
          r => r,
          z => z,
          c => c,
          dc => dc
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
      wait for 100 ns;	

      wait for clk_period*10;
      a <= (1=>'1',others => '0');
      b <= (1=>'1',0=>'1',others => '0');
      ctrl <= A_ADD;
      wait for clk_period;
      ctrl <= A_ADDU;
      wait for clk_period;
      ctrl <= A_AND;
      wait for clk_period;
      ctrl <= A_OR;
      wait for clk_period;
      ctrl <= A_XOR;
      wait for clk_period;
 
      a <= (others => '0');
      b <= (others => '0');
      ctrl <= A_ADD;
      wait for clk_period;
      ctrl <= A_ADDU;
      wait for clk_period;
      ctrl <= A_AND;
      wait for clk_period;
      ctrl <= A_OR;
      wait for clk_period;
      ctrl <= A_XOR;
      wait for clk_period; 
      -- insert stimulus here 

      wait;
   end process;

END;
