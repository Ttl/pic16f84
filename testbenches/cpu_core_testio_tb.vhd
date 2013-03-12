LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;


-- Testbench for testing processors IO.
-- This test bench reads and writes and also check
-- the correct operation of btfsc instruction
 
ENTITY cpu_core_testio IS
END cpu_core_testio;
 
ARCHITECTURE behavior OF cpu_core_testio IS 
 
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
   Generic map(instruction_file => "scripts/instructions_testio.mif")
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
      porta <= "HHHHH";
      portb <= "HHHHHHHH";
      -- hold reset state for 100 ns.
      wait for 100 ns;	
      reset <= '0';
      wait for clk_period*15;
      assert porta(2 downto 0) = "101" severity failure;
      assert portb(2 downto 0) = "111" severity failure;
      wait for clk_period;
      portb <= "LLHLLLLL";
      wait for clk_period*10;
      assert unsigned(pc_out) > 24 severity failure;
      
      reset <= '1';
      wait for clk_period;
      assert false report "Succesfully completed" severity failure;
   end process;

END;
